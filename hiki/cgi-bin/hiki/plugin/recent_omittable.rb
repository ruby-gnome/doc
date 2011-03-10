#
# recent_omittable.rb
# 
# Show recent updated pages except reserved pages.
# In default, News* files aren't shown.
#
# This plugin override recent plugin in 00default.rb.
#
# {{recent(n = 20, except_prefix = 'News'}}
#
# Copyright (C) 2003 Masao Mutoh <mutoh@highway.ne.jp>
#
# This plugin is based on 00default.rb
#   Copyright (C) 2002-2003 TAKEUCHI Hitoshi <hitoshi@namaraii.com>
#

def recent(n = 20, except_prefix = 'News')
  n = n > 0 ? n : 0

  l = @db.page_info.reject do |info|
    /\A#{except_prefix}/ =~ info.keys[0]# or !@db.exist?(info.keys[0])
  end.sort_by do |info|
    info[info.keys[0]][:last_modified]
  end.reverse[0, n]

  s = ''
  c = 0
  ddd = nil
  
  l.each do |a|
    name = a.keys[0]
    p = a[name]
    
    tm = p[:last_modified] 
    cur_date = tm.strftime(@conf.msg_date_format)

    if ddd != cur_date
      s << "</ul>\n" if ddd
      s << "<h5>#{cur_date}</h5>\n<ul>\n"
      ddd = cur_date
    end
    t = page_name(name)
    an = hiki_anchor(name.escape, t)
    s << "<li>#{an}</li>\n"
  end
  s << "</ul>\n"
  s
end
