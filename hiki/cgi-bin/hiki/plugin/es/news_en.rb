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
  'Tu nombre'
end
                                                                                
def news_subject_label
  'Asunto'
end
                                                                                
def news_post_label
  'Enviar'
end
                                                                                
def news_anonymous_label
  'Anonimo'
end
                                                                                
def news_notitle_label
  '(Sin titulo)'
end

def news_read_more(name)
  "\n\n((<Leer mas...|URL:#{$cgi_name}?#{name}>))\n"
end


