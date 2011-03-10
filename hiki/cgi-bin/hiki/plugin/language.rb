def language(language)
  str = ""
   [["en", "/"],
   ["es", "/es/"],
   ["fr", "/fr/"],
   ["de", "/de/"],
   ["it", "/it/"],
   ["ja", "/ja/"],
   ["pt_BR", "/pt_BR/"]].each do |lang|
    if lang[0] == language
      str << "[#{lang[0]}] "
    else
      str << %Q![<a href="#{lang[1]}">#{lang[0]}</a>] !
    end
  end
  %Q[<span class="language">#{str}</span>]
end

