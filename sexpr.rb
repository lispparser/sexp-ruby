#  SExpr - A simple Ruby library for parsing and validating s-expressions
#  Copyright (C) 2007 Ingo Ruhnke <grumbel@gmx.de>
#
#  This program is free software; you can redistribute it and/or
#  modify it under the terms of the GNU General Public License
#  as published by the Free Software Foundation; either version 2
#  of the License, or (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

require "parser.rb"

module SExpr

  class SExpr
    attr_reader :pos, :parent

    # FIXME: Implement parent handling
    def initialize(pos = nil)
      @pos = pos
    end

    def self.parse(str)
      parser = Parser.new(str)
      return parser.parse()
    end

    def write(out)
      out << to_s()
    end

    def to_ruby()
      return @value
    end
  end

  # Boolean
  class Boolean < SExpr
    attr_reader :value

    def initialize(value, pos = nil)
      super(pos)
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

    def initialize(value, pos = nil)
      super(pos)
      @value = value
    end

    def to_s()
      return @value.to_s
    end
  end

  # 5.1
  class Real < SExpr
    attr_reader :value

    def initialize(value, pos = nil)
      super(pos)
      @value = value
    end

    def to_s()
      return @value.to_s
    end
  end

  # "foo"
  class String < SExpr
    attr_reader :value

    def initialize(value, pos = nil)
      super(pos)
      @value = value
    end

    def to_s()
      return @value.to_s # inspect
    end
    
    def write(out)
      out << @value.inspect
    end
  end

  # foo
  class Symbol < SExpr
    attr_reader :value

    def initialize(value, pos = nil)
      super(pos)
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

    def initialize(value, pos = nil)
      super(pos)
      @value = value
    end

    def append(el)
      @value << el
    end

    def <<(el)
      @value << el
    end

    def [](idx)
      if idx.is_a?(Range) then
        return List.new(@value[idx])
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

    def to_s()
      return "(" + @value.map{|i| i.to_s}.join(" ") + ")"
    end

    def write(out)
      out << "("
      @value.each_with_index{|i, idx|
        i.write(out)
        if (idx != @value.length()-1) then
          out << " "
        end
      }
      out << ")"
    end

    def to_ruby()
      return @value.map{|el| el.to_ruby()}
    end
  end

  def Whitespace
    def initialize(value, pos = nil)
      super(pos)
      @value = value
    end
  end

  def Comment
    def initialize(value, pos = nil)
      super(pos)
      @value = value
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
