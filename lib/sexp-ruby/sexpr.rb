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

require "parser.rb"

module SExpr

  class SExpr
    attr_reader   :pos
    attr_accessor :parent

    # FIXME: Implement parent handling
    def initialize(parent = nil, pos = nil)
      @pos    = pos
      @parent = parent
    end

    def self.parse(str, parse_comments = false, parse_whitespace = false)
      parser = Parser.new(str, parse_comments, parse_whitespace)
      return parser.parse()
    end

    def write(out)
      out << to_s()
    end

    def to_ruby()
      return @value
    end

    def strip()
    end

    def to_sexpr()
      out = ""
      write(out)
      return out
    end
  end

  # Boolean
  class Boolean < SExpr
    attr_reader :value

    def initialize(value, parent = nil, pos = nil)
      super(parent, pos)
      @value = value
    end

    def to_s()
      if @value then
        return "#t"
      else
        return "#f"
      end
    end
  end

  # 1025
  class Integer < SExpr
    attr_reader :value

    def initialize(value, parent = nil, pos = nil)
      super(parent, pos)
      @value = value
    end

    def to_s()
      return @value.to_s
    end
  end

  # 5.1
  class Real < SExpr
    attr_reader :value

    def initialize(value, parent = nil, pos = nil)
      super(parent, pos)
      @value = value
    end

    def to_s()
      return @value.to_s
    end
  end

  # "foo"
  class String < SExpr
    attr_reader :value

    def initialize(value, parent = nil, pos = nil)
      super(parent, pos)
      @value = value
    end

    def to_s()
      return @value.inspect
    end

    def write(out)
      out << @value.inspect
    end
  end

  # foo
  class Symbol < SExpr
    attr_reader :value

    def initialize(value, parent = nil, pos = nil)
      super(parent, pos)
      @value = value # FIXME: Is this supposed to be a String or Symbol?
    end

    def to_s()
      return @value.to_s
    end
  end

  # (foo bar baz)
  class List < SExpr
    include Enumerable

    attr_reader :children, :value

    def initialize(value, parent = nil, pos = nil)
      super(parent, pos)
      @value = value
    end

    def concat(el)
      @value.concat(el)
    end

    def append(el)
      @value << el
    end

    def <<(el)
      @value << el
    end

    def [](idx)
      if idx.is_a?(Range) then
        if idx.begin < @value.length then
          return List.new(@value[idx], self, @value[idx.begin].pos)
        else # FIXME: When is this called?
          return List.new(@value[idx], self, self.pos)
        end
      else
        return @value[idx]
      end
    end

    def empty?()
      return @value.empty?()
    end

    def length()
      return @value.length
    end

    def each()
      @value.each{|i|
        yield i
      }
    end

    def strip()
      @value.delete_if{|el| (el.is_a?(Whitespace) or el.is_a?(Comment)) }
      @value.each{|el|
        el.strip()
      }
    end

    def to_s()
      result = "("
      needs_whitespace = false
      @value.each{ |i|
        if (needs_whitespace and !((i.is_a?(Whitespace) or i.is_a?(Comment)))) then
          result += " "
        end

        result += i.to_s

        if (i.is_a?(Whitespace) or i.is_a?(Comment)) then
          needs_whitespace = false
        else
          needs_whitespace = true
        end
      }
      result += ")"
      return result
    end

    def write(out)
      out << to_s()
    end

    def to_ruby()
      return @value.map{|el| el.to_ruby()}
    end
  end

  class Whitespace < SExpr
    def initialize(value, parent = nil, pos = nil)
      super(parent, pos)
      @value = value
    end

    def write(out)
      out << @value
    end

    def to_s()
      return @value
    end
  end

  class Comment < SExpr
    def initialize(value, parent = nil, pos = nil)
      super(parent, pos)
      @value = value
    end

    def write(out)
      out << @value
    end

    def to_s()
      return @value
    end
  end
end

class Array
  def to_sexpr()
    lst = SExpr::List.new([])
    each {|el|
      if el.is_a?(Symbol) then
        lst << SExpr::Symbol.new(el)
      elsif el.is_a?(String) then
        lst << SExpr::String.new(el)
      elsif el.is_a?(Integer) then
        lst << SExpr::Integer.new(el)
      elsif el.is_a?(Float) then
        lst << SExpr::Real.new(el)
      elsif el == true or el == false then
        lst << SExpr::Boolean.new(el)
      elsif el.is_a?(Array) then
        lst << el.to_sexpr()
      end
    }
    return lst
  end
end

# EOF #
