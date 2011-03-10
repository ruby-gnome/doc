def image(file_name, position = "right", page = @page)
  alt = file_name.escapeHTML
  url = 
  if /(.*):(.*)/ =~ file_name
    if $1 == "http"
      url = file_name
    elsif $1 == "en"
      #FIXME call InterWikiName ?
      url = "http://ruby-gnome2.sourceforge.jp/" + cmdstr('plugin', "plugin=attach_download;p=#{page.escape};file_name=#{$2}")

    end
  else
    url = @conf.cgi_name + cmdstr('plugin', "plugin=attach_download;p=#{page.escape};file_name=#{file_name}")
  end
  %Q[<img class="#{position}" alt="#{alt}" src="#{url}")}"></img>]
end

def image_right(file_name, page = @page)
  image(file_name, "right", page)
end

def image_left(file_name, page = @page)
  image(file_name, "left", page)
end

def br
  %Q[<br clear="all" />]
end

def show_attached_files
  s = ""
  if (files = attach_page_files).size > 0
    s << %Q!<p>Attached Files: \n!
    files.each do |file_name|
      s << " [#{attach_anchor(file_name)}] "
    end
    s << "</p>\n"
  end
  s
end
