#!/home/enmail/bin/luajit
--[[
  notes:
    19 Jan 2016:
      * http://techcrunch.com/2012/05/07/a-closer-look-at-chorus-the-next-generation-publishing-platform-that-runs-vox-media/
      * http://www.annotism.com/quintype/2015/06/30/what-is-quintype
    mobile-publishing-platform:
      * publishers:
        + editorial
          writers: text, images, audio, video (create/edit/format)
          curate: approval-before-publish process
          social-media updates
          schedule articles-for-publishing (specific dates/times)
        + advertising
          metrics/stats
          ad-campaigns: run them on reader-network, track, monitor and report.
      * readers:
        + profile (age, sex, location, reading-habit-categorization)
      * article
        + permalink
        + metadata (can change over time)

usrid
  (role: writer, reader, moderator-section)
  draft, edit, publish (approve/reject)

article:
  text and non-writing elements (images, tags, categories)

editorial:
  track each article/story via. data/analytics


editorial-tools: assignments, editing, workflow
publish-in-various-formats: mobile, tablet, desktop
native apps - android/ios
analytics for ad-campaigns, scheduling, topic suggestion
sem/seo optimization
social-media integration
auto categorization for content
archive and library management

]]--

local md2html = function(text)
  --not-the-fastest-but-one-of-the-simplest
  -- https://gist.github.com/paulcuth/8967731
  local trim = function(str) return str:match '^[%s\n]*(.-)[%s\n]*$' end
  local parseParagraph = function(line)
    local trimmed = trim(line)
    if 
      string.find(trimmed, '^</?ul')
      or string.find(trimmed, '^</?ol')
      or string.find(trimmed, '^</?li')
      or string.find(trimmed, '^</?h')
      or string.find(trimmed, '^</?p')
      or string.find(trimmed, '^</?bl') 
    then
      return '\n'..line..'\n'
    end
    return string.format('\n<p>%s</p>\n', trimmed)
  end
  local parseUnorderedList = function(item) return string.format('\n<ul>\n\t<li>%s</li>\n</ul>', trim(item)) end
  local parseOrderedList = function(item) return string.format('\n<ol>\n\t<li>%s</li>\n</ol>', trim(item)) end
  local parseBlockquote = function(item) return string.format('\n<blockquote>%s</blockquote>', trim(item)) end
  local parseHeader = function(chars, header)
	  local level = #chars
	  return string.format('<h%d>%s</h%d>', level, trim(header), level)
  end
  local rules = {
    { '(#+)(.-%\n)', parseHeader 					},	-- headers
    { '%[(.-)%]%((.-)%)', '<a href="%2">%1</a>'		},	-- links
    { '%*%*([^%\n]-)%*%*', '<strong>%1</strong>'	},	-- bold *
    { '__([^%\n]-)__', '<strong>%1</strong>'		},	-- bold _
    { '%*([^%\n]-)%*', '<em>%1</em>'				},	-- emphasis *
    { '_([^%\n]-)_', '<em>%1</em>'					},	-- emphasis _
    { '~~([^%\n]-)~~', '<del>%1</del>'				},	-- del
    { ':"([^%\n]-)":', '<q>%1</q>'					},	-- quote
    { '`([^%\n]-)`', '<code>%1</code>'				},	-- inline code
    { '```(.-)```', '<code>%1</code>'				},	-- code block
    { '%\n%*([^%\n]*)', parseUnorderedList			},	-- ul lists
    { '%\n[0-9]+%.([^%\n]*)', parseOrderedList		},	-- ol lists
    { '%\n%-%-%-%-%-%-*', '\n<hr />'				},	-- horizontal rule
    { '%\n&gt;([^%\n]*)', parseBlockquote			},	-- blockquotes &gt;
    { '%\n>([^%\n]*)', parseBlockquote				},	-- blockquotes >
    { '%\n([^%\n]+)%\n', parseParagraph 			},	-- add paragraphs
    { '</ul>%s*<ul>%\n', ''							},	-- fix extra ul
    { '</ol>%s*<ol>%\n', ''							},	-- fix extra ol
    { '</blockquote>%s*<blockquote>', '</br>'		},	-- fix extra blockquote
  }
  --[[
    add-new-rules - ex. smiley
    {':%)', '<img src="smiley.png" />'}
  ]]--
  text = '\n'..text..'\n'
  for i = 1, #rules do text = string.gsub(text, unpack(rules[i])) end
	return trim(text)
end

local master = {
skel = [[<!DOCTYPE html>
<html lang="en">
<head>
<meta charset=utf-8" />
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<link rel="shortcut icon" href="/favicon.ico">
<link rel="icon" type="image/png" href="/favicon.png">
<link rel="apple-touch-icon" href="/apple-touch-icon.png">
<link rel="stylesheet" href="/site.min.css" media="all">
<title>மின்அம்பலம்</title>
</head>
<body>
<div class="container">

<div class="row tac">
<h1 class="tdn"><a href="/">மின்அம்பலம்</a></h1>
<a href="/"><img src="/apple-touch-icon.png" width="144" height="144"></a>
<div class="row"><strong><a href="/politics">அரசிய்ல்</a> | <a href="/culture">கலாசாரம்</a> | <a href="/currentaffairs">அன்ராடம்</a></strong></div>
</div>

<div class="row"><h2>விரைவில்...</h2></div>'

<div class="footer">2016 &copy; காப்புரிமை  மின்அம்பலம் அமைப்பு.</div>
</div> <!--container-->
</body></html>]],
defauthor = 'மின்அம்பலம் எழுத்தாளர்',
next = "மேலும்",
week = "வாரம்",
day = "கிழமை",
yesterday = "நேற்று",
tomorrow = 'நாளை',  
weekdays = {"ஞாயிறு", "திங்கள்", "செவ்வாய்", "புதன்", "வியாழன்", "வெள்ளி", "சனி"},
months = {"ஜனவரி", "பிப்ரவரி", "மார்ச்", "ஏப்ரல்", "மே", "ஜுன்", "ஜூலை", "ஆகஸ்ட்", "செப்டம்பர்", "அக்டோபர்", "நவம்பர்", "டிசம்பர்"},
lastweek = "போன வாரம்",
soon = 'விரைவில்',
authoridx = {'டி.அருள் எழிலன்', 'எகலைவன்', 'என்.செந்தில் குமார்', 'எம்.பி காசி', 'நாகேந்திரன்', 'எம்.குணவதி','பி.வைத்தீஸ்வரன்', 'செ.விவேக்','செ.செயரஞ்சன்', 'பிரியா', 'கண்மணி', 'ஸ்னேகா'},
authors = {aru='டி.அருள் எழிலன்', eag='எகலைவன்', sen='என்.செந்தில் குமார்'},
tags = {'அரசிய்ல்','கலாசாரம்', 'அன்ராடம்'},
previous = 'முந்திய',
next = 'அடுத்து',
more = 'மேலும்',
}

local function html(body, title, meta)
  --[[
  fb-open-graph meta-tags
  <meta property="og:title" content="The best site">
  <meta property="og:image" content="link_to_image">
  <meta property="og:description" content="description goes here">
  ]]--

  ngx.header["Content-Type"] = 'text/html'
  local footer = '<div class="footer">2016 &copy; காப்புரிமை  மின்அம்பலம் அமைப்பு.</div></div></body></html>'
  local masthead = '<div class="container"><div class="row tac"><h1 class="tdn"><a href="/posts">மின்அம்பலம்</a></h1><a href="/posts"><img src="/apple-touch-icon.png" width="144" height="144"></a></div>'

  local header = '<!DOCTYPE html><html lang="en"><head><meta http-equiv="content-type" content="text/html; charset=utf-8" /><meta name="viewport" content="width=device-width, initial-scale=1.0"><link rel="shortcut icon" href="/favicon.ico"><link rel="icon" type="image/png" href="/favicon.png"><link rel="apple-touch-icon" href="/apple-touch-icon.png"><link rel="stylesheet" href="/site.min.css" media="all">'
  if 'table' == type(meta) then
    local t = {}
    local author=''
    for k,v in pairs(meta) do
      if 'author' == k then
        author = '<meta name="author" content="'..v:gsub('"','')..'">'
      else
        local s = k:gsub(':',' ')..': '..v:gsub(',',' ')
        t[#t+1] = s:gsub('"','')
      end
    end
    header = header..author..'<meta name="Description" content="'..table.concat(t, ', ')..'" />'
  end
  header = header..'<title>மின்அம்பலம்:'..(title or '')..'</title></head><body>'

  body = body or '<div class="row"><h2>விரைவில்...</h2></div>'

  return header..masthead..body..footer
end

function parsemd(fqname, fid)
  local trimstr = function(s, trimlen)
    local slen = s:len()
    if slen <= trimlen then return s end
    --break on word boundary, if possible
    local i = s:find(' ', -(slen-trimlen))
    return s:sub(1,i)..' ...'
  end

  local fh, err = io.open(fqname)
  if not fh then
    return nil, err
  end

  local wcount = 0
  local t = {id=fid, author=master.defauthor, wordcount=0}
  local flines = {}
  local isheader = true
  
  local addfline = function(ln)
    for w in ln:gmatch("[^%s]+") do wcount = wcount + 1 end
    if (not t.title) and ('#' == ln:sub(1,1)) then
      ln = ln:sub(2)
      t.title = trimstr(ln, 140)
      flines[#flines+1] = '<h2>'..ln..'</h2>'
    elseif (not t.description) and ('#' ~= ln:sub(1,1)) then
      t.description = trimstr(ln, 560)
      flines[#flines+1] = '<p>'..ln..'</p>'
    elseif ('##' == ln:sub(1,2)) then
      flines[#flines+1] = '<h3>'..ln:sub(3)..'</h3>'
    else
      flines[#flines+1] = '<p>'..ln..'</p>'
    end
  end

  for ln in fh:lines() do
    ln = ln:match("^%s*(.-)%s*$") --trim leading/trailing whitespace
    if ln:len() > 0 then
      if isheader then
        local k,v = ln:match("(.*)%s*:%s*(.*)")
        if not k then
          isheader = false
          addfline(ln)
        elseif 'author' == k then 
          t.author = v
        elseif 'tags' == k then 
          t.tags = v
        end
      else
        addfline(ln)
      end
    else
      isheader = false
    end
  end
  fh:close()

  flines[1] = flines[1]

  flines[1] = flines[1]..'<div class="subtitle">'..t.author..'</div>'
  local imgfname = fqname:sub(1,fqname:len()-3)..'.jpg'
  local st = os.stat(imgfname)
  if st then
    t.hasimage = true
    flines[2] = '<img src="'..os.date('/%Y/%m/%d/',fid)..'/'..t.id..'.jpg" width="100%">'..flines[2]
  end

  t.html = table.concat(flines)
  if not t.title then t.title = 'unk' end
  t.wordcount=wcount

  return t
  --title, description, author, wordcount, tags, hasimage, html
end

tblposts = nil --global

function update_posts()
  local t = {}
  local path = '2016/01'
  for day in os.dir(path) do
    local dpath = path..'/'..day
    local st = os.stat(dpath)
    if 'directory' == st.type then
      for fname in os.dir(dpath) do
        local ftime = fname:match('(%d+).md')
        if ftime then
          ftime = tonumber(ftime)
          md, err = parsemd(dpath..'/'..fname, ftime)
          if md then t[ftime] = md end
        end
      end
    end
  end
  return t
end

function list(path)
  ngx.header["Content-Type"] = 'text/html'
  if not tblposts then tblposts = update_posts() end

  table.sort(tblposts, function(a,b) return (a.id < b.id) end)

  local plist = {}
  for k,v in pairs(tblposts) do
    local path = os.date('/%Y/%m/%d/',v.id)
    local img = '&nbsp;'
    if v.hasimage then img = '<img src="'..path..v.id..'s.jpg" width="100%">' end
    plist[#plist+1] = '<div class="row card"><div class="two columns">'..
                      img..'</div><div class="ten columns">'..
                      '<a href="/posts?view='..v.id..'">'..v.title..
                      '</a><br/>'..v.author..'</p><p>'..v.description..'</p></div></div>'
  end
  ngx.print(html(table.concat(plist)))
  return ngx.exit(200)
end

function view(articleid)
  ngx.header["Content-Type"] = 'text/html'
  if not tblposts then tblposts = update_posts() end
  local post = tblposts[tonumber(articleid)]
  if post then
    ngx.print(html(post.html, post.title, {author=post.author, tags=post.tags}))
    return ngx.exit(200)
  else
    return ngx.exit(400)
  end
end

if 'GET' == ngx.var.request_method then
  local args = ngx.req.get_uri_args()
  if args['skel'] then
    ngx.print(master.skel)
    return ngx.exit(200)
  end

  if args['view'] then
    return view(args['view'])
  else
    return list(args['list'])
  end
else
  ngx.status = 403
  return ngx.exit(403)
end
