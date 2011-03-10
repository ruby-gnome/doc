#!/usr/bin/ruby

paths = [File.expand_path(File.join(File.dirname(__FILE__), ".."))]

paths.each do |path|
  $LOAD_PATH.unshift(path)
end

load "#{paths[0]}/attach.cgi"

