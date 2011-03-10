#
# news_en.rb
# 
# English resource file for News pages plugin.
#
# Copyright (C) 2003 Masao Mutoh <mutoh@highway.ne.jp>
#   You can redistribute it and/or modify it under GPL2.
#
# This plugin is based on bbs.rb
#   Copyright (C) 2002-2003 TAKEUCHI Hitoshi <hitoshi@namaraii.com>
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
  "\n\n((<Read more...|URL:#{$cgi_name}?#{name}>))\n"
end


