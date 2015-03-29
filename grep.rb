#!/usr/bin/ruby -w

require "sexpr.rb"
require "parser.rb"
require "schema.rb"

if ARGV.length < 2 then
  puts "Usage: grep.rb EXPRESSION FILES..."
else
  expression = ARGV[0].split
  ARGV[1..-1].each{|i|
    begin
      reader = SExpr::Reader.parse(File.new(i).read())
      results = reader.find_many(expression)
      if not results.empty? then
        results.each{|result|
          puts "#{i}:#{result.pos}: #{result.to_sexpr}"
        }
      end
    rescue RuntimeError
      puts "#{i}:#{$!}"
    end
  }
end

# EOF #
