# $Id: hikiconf.rb.sample,v 1.7 2004/09/14 02:21:10 fdiary Exp $
# Copyright (C) 2002-2003 TAKEUCHI Hitoshi <hitoshi@namaraii.com>
if File.expand_path(File.dirname(__FILE__)) =~ /cgi-bin$/
  base_dir = File.expand_path(File.join(File.dirname(__FILE__), ".."))
else
  base_dir = File.expand_path(File.join(File.dirname(__FILE__), "../.."))
end

@data_path       = File.join(base_dir, "data/")
@repos_type      = 'git'
@index_page      = 'http://ruby-gnome2.sourceforge.jp/'
@base_url        = 'http://ruby-gnome2.sourceforge.jp/'
@smtp_server     = 'sourceforge.jp'
@use_plugin      = true
@use_wikiname    = false
@password        = nil
@site_name       = 'Ruby-GNOME2 Project Website'
@author_name     = 'Ruby-GNOME2 Project Team'
@mail_on_update  = true
@mail            = 'ruby-gnome2-cvs@lists.sourceforge.jp'
@theme           = 'ruby-gnome2'
@theme_url       = '/theme'
@theme_path      = File.join(base_dir, "cgi-bin", "hiki", "theme")
@use_sidebar     = true
@main_class      = 'main'
@sidebar_class   = 'sidebar'
@auto_link       = false
@cache_path      = "#{@data_path}/cache"
@style           = 'rd+'
#@mail_from      = 'from@mail.address.hoge'
@hilight_keys    = true
@database_type   = 'flatfile'
@cgi_name        = 'hiki.cgi'
@options         = {}
@plugin_debug    = false
@xmlrpc_enabled  = true
# @options['amazon.aid'] = 'amazon-01' 

@cgi_name = "hiki.cgi"
@options['attach.form'] = "edit"

@use_cache_data = true

@options['referer.omit_url'] = [
 '^http://localhost[:/]',
 '^http://192\.168\.',
 '^http://172\.1[6789]',
 '^http://172\.2[0-9]',
 '^http://172\.3[01]',
 '^http://10\.',
 '^http://10\.',
 '^http://ruby-gnome2\.sourceforge',
 '^http://ruby-gnome2\.sf\.net',
 '^https://ruby-gnome2\.sourceforge',
 '^https://ruby-gnome2\.sf\.net',
 '(search|google|yahoo|lycos|infoseek|goo.ne.jp|excite|odn|Search|aol.com|alltheweb|tocc.co.jp|earthlink|metacrawler|overture)',
]
#$options['rd.header_depth'] = 2

@options['link.image_prev']  = @index_page + "/theme/ruby-gnome2/prev.png"
@options['link.image_next']  = @index_page + "/theme/ruby-gnome2/next.png"
@options['link.image_up']    = @index_page + "/theme/ruby-gnome2/up.png"
@options['link.image_start'] = @index_page + "/theme/ruby-gnome2/start.png"

@options['bayes_filter.use'] = true
@options['bayes_filter.shared_db_path'] = "#{@data_path}/common"
@options['bayes_filter.share_db'] = true

@options['sp.selected'] = [
  "attach.rb",
  "diffmail.rb",
  "edit_user.rb",
  "history.rb",
  "referer.rb",
  "rss.rb",
  "search.rb",
#  "src.rb",
].join("\n")
