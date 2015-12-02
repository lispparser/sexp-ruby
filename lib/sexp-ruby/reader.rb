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

require_relative "value.rb"
require_relative "parser.rb"
require_relative "../sexp-ruby.rb"

module SExpr
  class Reader
    def Reader.from_string(str)
      lst = SExpr::parse(str)
      if lst.length() == 1 then
        return Reader.new(lst[0])
      else
        raise "Error: Reader expected exactly one s-expression, got #{lst.length}"
      end
    end

    attr_reader :name, :pos, :root

    def initialize(sexpr)
      if not sexpr.is_a?(List) then
        raise "#{sexpr.pos}: Error: Reader expected List, got #{sexpr.class}"
      elsif sexpr.length() == 0 then
        raise "#{sexpr.pos}: Error: Reader expected List with one or more elements"
      else
        @root  = sexpr
        @name  = sexpr[0].value
        @pos   = sexpr[0].pos
        @sexpr = sexpr[1..-1]
      end
    end

    def find_many(path)
      if path.empty? then
        raise "find_by_path: path must not be empty"
      else
        elements = []

        # Find all matching elements
        @sexpr.each{|el|
          if not el.is_a?(List) then
            raise "#{el.pos}: Error: Reader expected List, got #{el.class}"
          elsif el.length() == 0 then
            raise "#{el.pos}: Error: Reader expected List with one or more elements"
          elsif not el[0].is_a?(Symbol) then
            raise "#{el.pos}: Error: Reader expected Symbol, got #{el.class}"
          else
            if el[0].value == path[0] then
              elements << Reader.new(el)
            end
          end
        }

        if path.length == 1 then
          return elements.map{|reader| reader.root}
        else
          results = []
          elements.each{|reader|
            results += reader.find_many(path[1..-1])
          }
          return results
        end
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
      if not el then
        return nil
      elsif el.length() != 2 then
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

    def read_string_array(name)
      el = find(name)
      if not el then
        return nil
      else
        if not el[1..-1].inject(true){|memo, i| memo and i.is_a?(String)} then
          raise "#{el.pos}: Error expected a String array: #{el.to_sexpr}"
        else
          return el[1..-1].map{|i| i.value }
        end
      end
    end

    def read_integer_array(name)
      el = find(name)
      if not el then
        return nil
      else
        if not el[1..-1].inject(true){|memo, i| memo and i.is_a?(Integer)} then
          raise "#{el.pos}: Error expected a Integer array: #{el.to_sexpr}"
        else
          return el[1..-1].map{|i| i.value }
        end
      end
    end

    def read_real_array(name)
      el = find(name)
      if not el then
        return nil
      else
        if not el[1..-1].inject(true){|memo, i| memo and (i.is_a?(Real) or i.is_a?(Integer))} then
          raise "#{el.pos}: Error expected a Real array: #{el.to_sexpr}"
        else
          return el[1..-1].map{|i| i.value }
        end
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

    def read_boolean(name)
      el = find(name)
      if not el then
        return nil
      elsif el.length() != 2 then
        raise "#{el.pos}: Error expected exactly one boolean, got #{el.to_s}"
      elsif not el[1].is_a?(Boolean) then
        raise "#{el.pos}: Error expected a Boolean, got #{el.class}"
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
