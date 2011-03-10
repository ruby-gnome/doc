#
# news.rb
# 
# News pages plugin for Hiki
#
# {{new_entry_box(cols = 70, rows = 10)}}
#   - Entry box on hiki. Create a new page and call this plugin.
#
# {{news(n = 10, depth = 0)}}
#   - Show news. Create a new page and call this plugin.
#      n: Show numbers of news.
#      depth: header line's depth. 
#
#
# Copyright (C) 2003 Masao Mutoh <mutoh@highway.ne.jp>
#
# This plugin is based on bbs.rb
#   Copyright (C) 2002-2003 TAKEUCHI Hitoshi <hitoshi@namaraii.com>
#

#
# Language resources
#
def news_name_label
  'Your name'
end

def news_subject_label
 'Subject'
end

def news_post_label
 'Submit'
end

def news_anonymous_label
 'Anonymous George'
end

def news_notitle_label
 '(No title)'
end

def news_read_more(name)
 "\n\n((<Read more...|URL:#{$cgi_namw}?#{name}>))\n"
end

 
#
# Overridable Format
#

def news_title(date, num)
  date.strftime("News (%Y-%m-%d No.#{num})")
end

def news_content(subject, name, date, msg)
  depth = @options['rd.header_depth'] ?  @options['rd.header_depth'] : 1
  %Q[#{"=" * depth} #{subject}
((*Posted by #{name} on #{date.strftime("%Y-%m-%d (%a) %X")}*))

#{msg}
]
end

def news_a_news(news, name, lines, depth)
  head = depth > 0 ? "=" * depth : ""
  lcnt = 0
  ret = ""
  lines.each do |l|
    if lcnt < 4
      lcnt += 1
      ret << head if /^=/ =~ l
      ret << l if /^= / !~ l
    else
      break if /^\s*$/ =~ l
      ret << "=" if /^=/ =~ l
      ret << l
    end
  end
  ret << news_read_more(name)
end

def news_entry_box(cols = 70, rows = 10)
  <<EOS
<form action="#{$cgi_name}" method="post">
  <div>
    #{news_name_label}: <input type="text" name="name" size="10">
    #{news_subject_label}: <input type="text" name="subject" size="40"><br>
    <textarea cols="#{cols}" rows="#{rows}" name="msg" size="40"></textarea><br>
    <input type="submit" name="comment" value="#{news_post_label}">
    <input type="hidden" name="c" value="plugin">
    <input type="hidden" name="p" value="#{@page}">
    <input type="hidden" name="plugin" value="news_post">
  </div>
</form>
EOS
end

#
# Main logic.
# Don't touch me ;)
#
def news_post
  unless @user
    page = ::Hiki::Page.new(@cgi, @conf)
    page.contents = {}
    page.process(self)
    page.out('status' => "403 Forbidden")
    return
  end

  params     = @cgi.params
  name       = params['name'][0].size == 0 ? news_anonymous_label : params['name'][0].strip
  subject    = (params['subject'][0].size == 0 ? news_notitle_label : params['subject'][0]).strip
  msg        = params['msg'][0].strip

  return '' if msg.strip.size == 0

  #
  # Detail
  #
  num = 0
  lines = true
  date = Time.now.gmtime
  while(lines)
    num += 1
    detailpage = date.strftime("News_%Y%m%d_#{num}")
    lines = @db.load(detailpage)
  end
  title = news_title(date, num)

  md5hex = @db.md5hex(detailpage)

  if save(detailpage, news_content(subject, name, date, msg), md5hex, true)
    @db.set_attribute(detailpage, [[:title, title]])
    redirect(@cgi, @conf.base_url + hiki_url(detailpage))
  else
    page = ::Hiki::Page.new(@cgi, @conf)
    page.contents = {}
    page.process(self)
    page.out('status' => "403 Forbidden")
  end
end

def news(n = 10, depth = 0)
  return "" if $NEWS_LOCK
  $NEWS_LOCK = true
  n = n > 0 ? n : 0
  newslist = @db.page_info.select{|item|
    /^News_\d\d\d\d/ =~ item.keys[0] 
  }
  newslist.sort!{|a, b|
    b.keys[0] <=> a.keys[0]
  }

  ret = ""
  cnt = 0
  newslist.each do |news|
    name = news.keys[0]
    content = @db.load(name)
    next if content.nil?
    break if (cnt += 1) > n
    ret << news_a_news(news, name, content, depth)
  end

  tokens = @conf.parser.new(@conf).parse(ret)
  formatter = @conf.formatter.new(tokens, @db, self, @conf)
  formatter.to_s
end

#
# Override recent plugin.
#
=begin
def recent( n = 20 )
  n = n > 0 ? n : 0

  l = @db.page_info.sort do |a, b|
    b[b.keys[0]][:last_modified] <=> a[a.keys[0]][:last_modified]
  end

  s = ''
  c = 0
  ddd = nil
  
  l.each do |a|
    break if (c += 1) > n
    name = a.keys[0]
    p = a[name]
    
    tm = p[:last_modified] 
    cur_date = tm.strftime(msg_date_format)

    if ddd != cur_date
      s << "</ul>\n" if ddd
      s << "<h5>#{cur_date}</h5>\n<ul>\n"
      ddd = cur_date
    end
    t = page_name(name)
    if /^News \(/ !~ t
      an = hiki_anchor(name.escape, t)
      s << "<li>#{an}</li>\n"
    end
  end
  s << "</ul>\n"
  s
end
=end
