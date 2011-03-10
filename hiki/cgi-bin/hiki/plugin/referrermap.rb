# referrermap.rb  version 1.1
#
# Yet another Referermap plugin for Hiki
#
# You need to install nkf(standard library), uconv.
#   http://raa.ruby-lang.org/list.rhtml?name=uconv
#
# {{refferermap}}
#  or
# {{referer_map}}
#
# See the Website[1] for more details.
# [1] http://ponx.s5.xrea.com/hiki/ja/refermap.html (ja)
#
# Copyright (C) 2003,2004 Masao Mutoh <mutoh@highway.ne.jp>
# You can redistribute it and/or modify it under GPL2.
#
# This plugin is based on 00default.rb
#   Copyright (C) 2002-2003 TAKEUCHI Hitoshi <hitoshi@namaraii.com>
#   You can redistribute it and/or modify it under GPL2.
#
# Original logic is from disp_referrer.rb for tDiary
#   Copyright (C) 2002,2003 MUTOH Masao <mutoh@highway.ne.jp>
#   You can redistribute it and/or modify it under GPL2.

require 'uconv'
require 'nkf'

#
# Resources
#

def referrermap_misc
  "Misc."
end

def referrermap_link_from
  "Linked from:"
end

def referrermap_search_from
  "Searched from:"
end

def referrermap_page_name(name)
  "<h3>#{name}</h3>\n"
end

def referrermap_category(name)
  "<h4>#{name}</h4>\n"
end

#
# Main
#
eval(<<TOPLEVEL_CLASS, TOPLEVEL_BINDING)
def Uconv.unknown_unicode_handler(unicode)
  if unicode == 0xff5e
    "¡Á"
  else
    raise Uconv::Error
  end
end
TOPLEVEL_CLASS

# Deny user agents.
deny_user_agents = ["googlebot", "Hatena Antenna", "moget@goo.ne.jp"]
if @options['referrermap.deny_user_agents']
  deny_user_agents += @options['referrermap.deny_user_agents']
end
@referrermap_antibots = Regexp::new("(" + deny_user_agents.join("|") + ")")

def referrermap_antibot?
  @referrermap_antibots =~ @cgi.user_agent
end

@options['referrermap.x'] ||= " x"
@options["referrermap.size"] ||= 80

@referrermap_table = []
@referrermap_deny_table = [
  'http://ecstatic.bytch.org.*',
  'http://www.sexrabbit.de.*',
  'http://5-59.com.*',
  'http://www.sex-teens-versaut.de.*',
  'http://127.*',
  'http://192.*',
  'http://10.*',
  'http://www.wholesale4.com/',
  'http://www.saulem.com/',
  'http://www.trafficswarm.com/',
]
@referrermap_search_table = [
  [["Google","http://www.google.com/"],
    ["^http://.*(216.239|google).*q=cache:([^:]*):(.*?)(\s|\\+)([^&]*).*", "cache:\\5"],
    ["^http://.*(216.239|google).*q=([^&]*).*", "\\2"]],
  [["Yahoo!","http://www.yahoo.co.jp/"],
    ["^http://.*.yahoo.*?p=([^&]*).*", "\\1"],
    ["^http://srd.yahoo.co.jp/.*", ""]],
  [["Infoseek","http://www.infoseek.co.jp/"],
    ["^http://.*infoseek.*?qt=([^&]*).*", "\\1"]],
  [["Lycos","http://www.lycos.co.jp/"],
    ["^http://.*lycos.*/.*?(query|q)=([^&]*).*", "\\2"]],
  [["goo","http://www.goo.ne.jp/"],
    ["^http://.*goo.ne.jp/.*?MT=([^&]*).*", "\\1"],
    ["^http://search.goo.ne.jp/click.jsp.DEST.*", ""]],
  [["@nifty", "http://www.nifty.com/"],
    ["^http://(search|asearch|www).nifty.com/.*?(q|Text)=([^&]*).*", "\\3"]],
  [["OCN", "http://www.ocn.ne.jp/"],
    ["^http://ocn.excite.co.jp/search.gw.*search=([^&]*).*", "\\1"]],
  [["excite", "http://www.excite.co.jp/"],
    ["^http://.*excite.*?(search|s)=([^&]*).*", "\\2"]],
  [["msn", "http://www.msn.co.jp/home.htm"],
    ["^http://.*search.msn.*?[\?&](q|MT)=([^&]*).*", "\\2"]],
  [["BIGLOBE", "http://www.biglobe.ne.jp/"],
    ["^http://cgi.search.biglobe.ne.jp/cgi-bin/search.*?(q|key)=([^&]*).*", "\\2"]],
  [["Telecom Search", "http://www.odn.ne.jp/"],
    ["^http://search.odn.ne.jp/LookSmartSearch.jsp.*(key|QueryString)=([^&]*).*", "\\2"]],
  [["Netscape", "http://google.netscape.com/"],
    ["^http://.*.netscape.com/.*(query|q|search)=([^&]*).*", "\\2"]],
  [["DION Search", "http://www.dion.ne.jp/"],
    ["^http://dir.dion.ne.jp/LookSmartSearch.jsp.*(key|QueryString)=([^&]*).*", "\\2"]],
  [["Metcha Search","http://bach.scitec.kobe-u.ac.jp/"],
    ["^http://bach.scitec.kobe-u.ac.jp/cgi-bin/metcha.cgi?q=([^&]*).*", "\\1"]],
  [["AOL", "http://www.aol.com/"],
    ["^http://.*aol.com/.*query=([^&]*).*", "\\1"]],
  [["Fresheye", "http://www.fresheye.com/"],
    ["^http://.*fresheye.*kw=([^&]*).*", "\\1"]],
  [["AlltheWeb","http://www.alltheweb.com/"],
    ["^http://www.alltheweb.com/.*?q=([^&]*).*", "\\1"]],
  [["TOCC/Search","http://www.tocc.co.jp/"],
    ["^http://www.tocc.co.jp.*QRY=([^&]*).*", "\\1"]],
  [["EarthLink","http://www.earthlink.net/"],
    ["^http://.*earthlink.*q=([^&]*).*", "\\1"]],
  [["i won_Search","http://home.iwon.com/"],
    ["^http://.*iwon.*searchfor=([^&]*).*", "\\1"]],
  [["metacrawler","http://www.metacrawler.com/"],
      ["^http://.*metacrawler.com/texis/search?q=([^&]*).*", "\\1"]],
  [["DOGPILE","http://www.dogpile.com/"],
    ['^http://.*dogpile.*qkw=([^&]*).*', '\1'],
    ["^http://search.dogpile.com/texis/search.q=([^&]*).*", "\\1"]],
  [["NEXEARCH","http://www.naver.co.jp/"],
    ["^http://search.naver.*query=([^&]*).*", "\\1"]],
  [["Altavista","http://www.altavista.com/"],
    ["^http://.*altavista.*q=([^&]*).*", "\\1"]],
  [["overture","http://www.overture.com/"],
    ["^http://overture.*Keywords=([^&]*).*", "\\1"]],
    [["About","http://www.about.com/"],
    ["^http://.*about.*terms=([^&]*).*", "\\1"]],
  [["looksmart","http://www.looksmart.com/"],
    ["^http://www.looksmart.com.*key=([^&]*).*", "\\1"]],
  [["NAVER","http://j2k.naver.com/"],
    ["^http://j2k.naver.com/j2k.php/korean/ponx.s5.xrea.com/bibo/(.date.)?(.*)", "\\2"]],
  [["Metasearch COMMENTON","http://www.dcn.to/~comment/on/"],
    ["^http://www.dcn.to/~comment/cgi-bin/commenton.cgi.*[\?&]q\=([^&]*).*", "\\1"]],
  [["eniro","http://www.eniro.se/"],
    ["^http://www.eniro.se/query.*[\?&]q\=([^&]*).*", "\\1"]],
  [["Wirtualna Polska","http://www.wp.pl/"],
    ["^http://szukaj.wp.pl/szukaj.html?.*szukaj\=([^&]*).*", "\\1"]],
  [["DEVIL FINDER","http://www.devilfinder.com/"],
    ["^http://www.devilfinder.com/find.php.*[\?&]q\=([^&]*).*", "\\1"]],
  [["All the Internet", "http://www.alltheinternet.com/"],
    ['http://www.alltheinternet.com/.*q=([^&]*)', '\1']],
  [["Mamma meta search", "http://www.mamma.com/"],
    ['http://.*mamma.com/Mamma.*query\=([^&]*).*', '\1']],
  [["EO.ST", "http://eo.st/"],
    ["http://eo.st/cgi-bin/meta.cgi.*[\?&]q\=([^&]*).*", '\1']],
  [["copernic", "http://www.copernic.com/"],
    ['^http://.*metaresults.copernic.com.*qkw=([^&]*)', '\1']],
  [["Beaucoup", "http://www.beaucoup.com/"],
    ["^http://.*findtarget.*beaucoup.php.*[\?&]q\=([^&]*).*", '\1']],
  [["OptimumOnline", "http://www.optonline.net/Home"],
    ["^http://msxml.infospace.com/.*[\?&]qkw\=([^&]*).*", '\1']],
  [["WebCrawler", "http://www.webcrawler.com/"],
    ["^http://.*webcrawler.com/.*[\?&]qkw\=([^&]*).*", '\1']],
  [["Surfcorp", "http://surfcorp.com/"],
    ["^http://surfcorp.com/.*[\?&]keywords\=([^&]*).*", '\1']],
]

REG_CHAR_UTF8 = /&#[0-9]+;/
def referrermap_replace_url(regval, ref)
  ret = CGI.unescape(ref)
  if @reg_char_utf8 =~ ref
    ret.gsub!(REG_CHAR_UTF8){|v|
      Uconv.u8toeuc([$1.to_i].pack("U"))
    }
  else
    begin
      ret = Uconv.u8toeuc(ret)
    rescue Uconv::Error
      ret = NKF::nkf('-e', ret)
    end
  end

  if regval
    regexp = Regexp.new(regval[0], Regexp::IGNORECASE)
    ret.gsub!(regexp, regval[1])
  end
  ret
end

def referrermap_show_a_page_referrer(refs, maxcols, referrermap_table)
  s = "<ul>\n"
  result = Array.new
  referrermap_table.each do |title, *table|
    a_row = Array.new
    sum = 0
    etc_sum = 0 

    all_num = maxcols
    table.each do |regval|
      break if refs.size < 1
      reg = Regexp.new(regval[0], Regexp::IGNORECASE)
      a_row_ref = refs.select{|item| reg =~ item[0]}
      if a_row_ref and a_row_ref.size > 0
        if all_num < 0 or all_num > a_row_ref.size
          a_row_max = a_row_ref.size
        else
          a_row_max = all_num
        end
        
        refs -= a_row_ref
        a_row += a_row_ref[0...a_row_max].collect{|item|
          sum += item[1]
          query = "<a href=\"#{CGI.escapeHTML(item[0])}\">"
          str = referrermap_replace_url(regval, item[0])
          str = "/" if str.size == 0
          query << CGI.escapeHTML(str) << "</a>"
          query << @options['referrermap.x'] << item[1].to_s if item[1] > 1
          [item[1], query]
        }
        if a_row_ref.size >= a_row_max 
          a_row_ref[a_row_max...a_row_ref.size].each {|item|
            sum += item[1]
              etc_sum += item[1]
          }
        end
      end
    end
    
    a_row.sort!{|a, b| (a[1].to_i <=> b[1].to_i)}
    
    a_row = a_row[0...all_num] if a_row and a_row.size > all_num and all_num > 0
    div = ":"
    if etc_sum > 0
      if all_num > 0
        a_row << [0, "<span class=\"referrer-etc\">#{referrermap_misc}</span>#{@options['referrermap.x']}#{etc_sum}"]
      else
        a_row << [0, " "]
        div = ""
      end
    end
    if a_row and a_row.size > 0
      result << [sum, %Q[<li>#{sum} <a href="#{CGI.escapeHTML(title[1])}">#{CGI.escapeHTML(title[0])}</a> #{div} #{a_row.collect{|item| item[1]}.join(", ")}</li>\n]]
    end
  end
  [refs, result]
end 

def referrermap_create_ul(title, ary)
  return "" if ary.size == 0
  ary.sort!{|a,b| - (a[0] <=> b[0])}
  ary.collect!{|item| item[1]} if ary
  result = referrermap_category(title)
  result << "<ul>\n"
  result << ary.join if ary 
  result << "</ul>\n"
end

def referrermap
  s = ''
begin
  path = referer_path
  return '' if referrermap_antibot? or ! test(?e, path)

  maxcols = @options["referrermap.cols"] ||= 10

  if @options["referrermap.table"]
    @referrermap_table += @options["referrermap.table"]
  end

  if @options["referrermap.search_table"]
    @referrermap_search_table += @options["referrermap.search_table"]
  end

  if @options["referrermap.deny_table"]
    @referrermap_deny_table += @options["referrermap.deny_table"]
  end

  s = ""
  Dir.entries(path).sort {|a, b| a.unescape <=> b.unescape}.each do |f|
    next if /(?:^\.)|(?:~$)/ =~ f
    next unless @db.exist?(f.unescape)
    db = PTStore::new("#{path}/#{f}".untaint)
    p = File.basename(f)
    refs = referers(db)

    refs = refs.select{|item|
      ret = true
      @referrermap_deny_table.each{|regexp|
        if /#{regexp}/ =~ item[0]
          ret = false
          break
        end
      }
      ret
    }
    refs, search_result = referrermap_show_a_page_referrer(refs, maxcols, @referrermap_search_table)
    refs, main_result =  referrermap_show_a_page_referrer(refs, maxcols, @referrermap_table)
    main_result = Array.new unless main_result
    refs.each do |url, sum|
      ary = CGI.unescape(url).split(//)
      if ary.size > @options["referrermap.size"]
        name = ary[0...@options["referrermap.size"]].join
        name << " ..."
      else
        name = ary.join
      end
      name = referrermap_replace_url(nil, replace_url(name))
      main_result << [sum, %Q[<li>#{sum} <a href="#{CGI.escapeHTML(url)}">#{name}</a>\n]]
    end
    if main_result.size > 0 or search_result.size > 0
      s << referrermap_page_name(hiki_anchor(p, page_name(p.unescape)))
      s << referrermap_create_ul(referrermap_link_from, main_result)
      s << referrermap_create_ul(referrermap_search_from, search_result)
    end
  end
  s
rescue Exception
  s << $!
  s << "<pre>#{$!.backtrace.join("\n")}</pre>"
end

end

def referer_map
  referrermap
end
