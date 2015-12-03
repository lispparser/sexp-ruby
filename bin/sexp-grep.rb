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

require "sexp-ruby"
require "sexp-ruby/reader"

def sexp_grep(filename, reader, path)
  if path.empty?
    return []
  else
    if reader.name != path[0]
      return []
    else
      rest_path = path[1..-1]
      if rest_path.empty?
        results = [reader.root]
      else
        results = reader.find_many(rest_path)
      end
      if not results.empty? then
        results.each{|sx|
          if sx.length == 1
            puts "#{filename}:#{sx.pos}: #{sx}"
          else
            str = sx[1..-1].map{|s| s.to_s }.join(" ")
            puts "#{filename}:#{sx.pos}: #{str}"
          end
        }
      end
    end
  end
end


if ARGV.length < 2 then
  puts "Usage: #{__FILE__} EXPRESSION FILES..."
else
  expression = ARGV[0].split

  ARGV[1..-1].each{|i|
    begin
      text = File.new(i).read()
      reader = SExp::Reader.from_string(text)

      sexp_grep(i, reader, expression)
    rescue RuntimeError
      puts "#{i}:#{$!}"
    end
  }
end

# EOF #
