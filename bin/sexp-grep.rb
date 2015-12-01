#!/usr/bin/ruby -w

# sexp-ruby - A simple Ruby library for parsing and validating s-expressions
# Copyright (c) 2007-2015 Ingo Ruhnke <grumbel@gmail.com>
#
# This software is provided 'as-is', without any express or implied
# warranty. In no event will the authors be held liable for any damages
# arising from the use of this software.
#
# Permission is granted to anyone to use this software for any purpose,
# including commercial applications, and to alter it and redistribute it
# freely, subject to the following restrictions:
#
# 1. The origin of this software must not be misrepresented; you must not
#    claim that you wrote the original software. If you use this software
#    in a product, an acknowledgment in the product documentation would be
#    appreciated but is not required.
# 2. Altered source versions must be plainly marked as such, and must not be
#    misrepresented as being the original software.
# 3. This notice may not be removed or altered from any source distribution.

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
