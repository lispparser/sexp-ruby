#!/usr/bin/ruby -w

require "sexpr.rb"
require "reader.rb"

if ARGV.empty?() then
  reader = SExpr::Reader.parse("(pingus-level (head) (bla 5))")
  puts reader.name
  puts reader.read_integer(["bla"])
else
  ARGV.each{|filename|
    reader = SExpr::Reader.parse(File.new(filename).read())       
    # puts reader.name
    print "Version: "
    puts reader.read_integer(["version"])
    print "Title: "
    puts reader.read_string(["head", "levelname"]).inspect
    print "Description: "
    puts reader.read_string(["head", "description"]).inspect
    
    puts reader.find(["head", "actions"])
  }
end

# EOF #
