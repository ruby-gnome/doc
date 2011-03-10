# status.rb for Hiki/RD+ version 1.2
#
# Copyright (C) 2003,2004 Masao Mutoh <mutoh@highway.ne.jp>
#
# You can redistribute it and/or modify it under the terms of
# the Ruby's licence.
#

def status(title, versions_or_str, str = nil)
  rows = ""
  versions = ["Status"]
  if versions_or_str.kind_of? String
    str = versions_or_str
  else
    versions = versions_or_str
  end

  target = versions.size + 2
  str.each_line do |line|
    if line !~ /^\s*$/
      data = line.split("|")
      if data[target] =~ /Obsolete|x/
        class_name = "obsolete"
      elsif data[target] =~ /^O/
        class_name = "done"
      elsif data[target] =~ /^\#/
        class_name = "notcomplete"
      elsif data[target] =~ /-$/
        class_name = "notyet"
      end

      data.each do |v|
        rows << "<td class=\"#{class_name}\">#{v}</td>"
      end

      (4 + versions.size - data.size).times do
        rows << "<td class=\"#{class_name}\"><br/></td>"
      end
        
      rows << "</tr>\n"
    end
  end

  version_th = versions.collect{|v| "<th>#{v}</th>"}.join
  %Q[<table border="1" cellspacing="0"
        summary="This table charts is the status of #{title}">
       <caption>The status of #{title}</caption>
       <tr><th>Table of contents</th><th>Class/Module Name</th><th>C Type</th>#{version_th}<th>Comments</th></tr>
       #{rows}
     </table>
     <div>
     <dl style="font-size: smaller">
       <li><b>'-'</b>: not implemented yet.</li>
       <li><b>'*'</b>: implemented but some methods/constants are not conforming to rules of Ruby-GNOME2.</li>
       <li><b>'#'</b>: some methods/constants are implemented but incomplete.</li>
       <li><b>'O'</b>: done.</li>
       <li><b>'x'</b>: Obsolete or Don't implement</li>
     </dl>
     </div>
    ]
end

