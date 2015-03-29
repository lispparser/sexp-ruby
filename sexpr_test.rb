#!/usr/bin/ruby -w

require "sexpr.rb"
require "parser.rb"

if ARGV.empty?() then
  SExpr::SExpr.parse("(bla pi8ngulevel -.51 a (b +1.5) -5)").each{|el|
    puts el.to_ruby.inspect
  }

else
  ARGV.each{|filename|
    sexpr = SExpr::SExpr.parse(File.new(filename).read())
    sexpr.each{ |el|
      puts el.to_ruby.to_sexpr
      # el.write($stdout)
    }
  }
end

# EOF #
