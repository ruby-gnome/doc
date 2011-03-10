# option.rb version 1.0
#
# See http://ponx.s5.xrea.com/hiki/ja/hiki_option.html.
#
# Copyright (C) 2003 Masao Mutoh
# You can redistribute it and/or modify it under GPL2.
#
OPTION_PAGE = "options"
begin
  options = @db.load(OPTION_PAGE)
  if options
    unless /\AError/ =~ options
      eval(options)
    end
  end
rescue Exception
  md5hex = @db.md5hex(OPTION_PAGE)
  data = "Error!\n"
  data << $!.to_s
  data << "\n#{$!.backtrace.join("\n")}\n-------------------(remove above, please)----\n"
  data << options
#  @db.save(OPTION_PAGE, data, md5hex)
  save(OPTION_PAGE, data, md5hex)
end
