def news_content(subject, name, date, msg)
  %Q[= News (#{date.strftime("%Y-%m-%d")})
== #{subject}
((*Posted by #{name} on #{date.strftime("%Y-%m-%d (%a) %X")}*))

#{msg}
]
end
