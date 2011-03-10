# link plugin for Hiki version 1.1
#
# Create links(previous, next, up, home) on Hiki
#
# Usage:
# link(prev_page_id, up_page_id, start_page_id, next_page_id)
#
# Sample:
# {{link("PrevPageID", "UpPageID", "StartPageID", "NextPageID")}}
#
# See http://ponx.s5.xrea.com/hiki/ja/hiki_link.html for more details.
# 
# Copyright (C) 2004 Masao Mutoh <mutoh@highway.ne.jp>
#
# You can redistribute it and/or modify it under GPL2.
#

#
# For language(or some customizable) resources
#

@options['link.image_prev']  ||= "/images/prev.png"
@options['link.image_up']    ||= "/images/up.png"
@options['link.image_start'] ||= "/images/start.png"
@options['link.image_next']  ||= "/images/next.png"

def link_common(key, page_id)
  return unless page_id
  title = page_name(page_id)
  img = %Q[<img src="#{@options['link.image_' + key]}" title="#{title}" alt="#{title}" border="0" />]
  @link_text += %Q[<span class="link-#{key}">#{hiki_anchor(page_id, img)}</span>\n]
  @link_header += %Q[  <link rel="#{key}" href="#{hiki_url(page_id)}" title="#{title}" />\n]
end

#
# Plugin
#
def link(prev_page_id, up_page_id, start_page_id, next_page_id)
  @link_header = ""
  @link_text = %Q[<div class="link">] 
  link_common("prev", prev_page_id)
  link_common("up", up_page_id)
  link_common("start", start_page_id)
  link_common("next", next_page_id)
  @link_text += "</div>"
end

add_header_proc {
  @link_header
}

add_page_attribute_proc{
  @link_text
}
