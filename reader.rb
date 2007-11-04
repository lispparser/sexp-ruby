#  SExpr - A simple Ruby library for parsing and validating sexpr.rb
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

require "sexpr.rb"

module SExpr
  class Reader 
    def Reader.parse(str)
      lst = SExpr.parse(str)
      if lst.length() == 1 then
        return Reader.new(lst[0])
      else
        raise "Error: Reader expected exactly one s-expression, got #{lst.length}"
      end
    end
    
    attr_reader :name, :pos

    def initialize(sexpr)
      if not sexpr.is_a?(List) then
        raise "#{sexpr.pos}: Error: Reader expected List, got #{sexpr.class}"
      elsif sexpr.length() == 0 then
        raise "#{sexpr.pos}: Error: Reader expected List with one or more elements"
      else
        @name  = sexpr[0].value
        @pos   = sexpr[0].pos
        @sexpr = sexpr[1..-1]
      end        
    end

    def find_by_path(path)
      if path.empty? then
        raise "find_by_path: path must not be empty"
      else
        el = find(path[0])
        if el then
          if path.length() == 1 then
            return el
          else
            reader = Reader.new(el)
            return reader.find_by_path(path[1..-1])
          end
        else
          return nil
        end
      end
    end

    def find(name)
      if name.is_a?(Array) then
        return find_by_path(name)
      else
        @sexpr.each{|el|
          if not el.is_a?(List) then
            raise "#{el.pos}: Error: Reader expected List, got #{el.class}"
          elsif el.length() == 0 then
            raise "#{el.pos}: Error: Reader expected List with one or more elements"
          elsif not el[0].is_a?(Symbol) then
            raise "#{el.pos}: Error: Reader expected Symbol, got #{el.class}"
          else
            if el[0].value == name then
              return el
            end
          end
        }
        return nil
      end
    end

    def read_integer(name)
      el = find(name)
      if not el then
        return nil
      elsif el.length() != 2 then
        raise "#{el.pos}: Error expected exactly one integer, got #{el.to_s}"
      elsif not el[1].is_a?(Integer) then
        raise "#{el.pos}: Error expected a Integer, got #{el.class}"
      else
        return el[1].value
      end
    end

    def read_real(name)
      el = find(name)
      if el.length() != 2 then
        raise "#{el.pos}: Error expected exactly one integer, got #{el.to_s}"
      elsif (not el[1].is_a?(Real)) and (not el[1].is_a?(Integer)) then
        raise "#{el.pos}: Error expected a Real, got #{el.class}"
      else
        return el[1].value
      end      
    end

    def read_string(name)
      el = find(name)
      if not el then
        return nil
      elsif el.length() != 2 then
        raise "#{el.pos}: Error expected exactly one integer, got #{el.to_s}"
      elsif not el[1].is_a?(String) then
        raise "#{el.pos}: Error expected a String, got #{el.class}"
      else
        return el[1].value
      end
    end

    def read_symbol(name)
      el = find(name)
      if not el then
        return nil
      elsif el.length() != 2 then
        raise "#{el.pos}: Error expected exactly one symbol, got #{el.to_s}"
      elsif not el[1].is_a?(String) then
        raise "#{el.pos}: Error expected a Symbol, got #{el.class}"
      else
        return el[1].value
      end      
    end

    def read_section(name)
      el = find(name)
      if el then
        return Reader.new(el)
      else
        return nil
      end
    end

    def sections()
      return @sexpr.map{|el| Reader.new(el) }
    end
  end
end

# EOF #
