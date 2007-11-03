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
require "reader.rb"
require "parser.rb"

module SExpr
  class Schema
    def initialize(schema)
      if schema.is_a?(SExpr) then
        @schema = schema
      else 
        @schema = SExpr.parse(schema)
        if @schema.length() == 1 then
          @schema = @schema[0]
        else
          raise "Expected exactly one SExpr, got #{@schema.length}"
        end
      end

      parse_scheme(@schema)
    end

    def parse_scheme(schema)
      reader = Reader.new(schema)
      if reader.name != "element" then
        raise "Expected 'element' tag, got '#{reader.name}'"
      else
        @root = Element.new(reader)
      end
    end

    def validate(sexpr)
      
    end
  end

  class Element
    attr_reader :name  # name of the expected element
    attr_reader :use   # required, optional, forbidden
    attr_reader :type  # ListType, IntegerType, ...

    def initialize(reader)
      @use  = reader.read_string("use")
      @name = reader.read_string("name")
    end
    
    def validate(sexpr)
      if not sexpr.is_a?(List) then
        raise "#{sexpr.pos}: expected list, got #{sexpr.class}"
      else
        if sexpr.value.empty() then
          raise "#{sexpr.pos}: expected a non-empty List"
        else
          if not sexpr[0].is_a?(Symbol) then
            raise "#{sexpr.pos}: expected a symbol, got #{sexpr[0].class}"
          else
            if sexpr[0].value != @name then
              raise "#{sexpr.pos}: expected symbol '#{name}', got #{sexpr[0].value}"
            else
              # ok, now check type and/or validate children
              type.validate(sexpr[1..-1])
            end
          end            
        end
      end
    end
  end

  class IntegerType
    def validate(sexpr)
      if sexpr.length() != 1 then
        raise "#{sexpr.pos}: expected a single integer got #{sexpr.to_s}"
      else
        if not sexpr[0].is_a?(SExpr::Integer) then
          raise "#{sexpr.pos}: expected integer got #{sexpr[0].class}"
        else
          # ok
        end
      end
    end
  end

  class RealType
    def validate(sexpr)
      if sexpr.length() != 1 then
        raise "#{sexpr.pos}: expected a single real got #{sexpr.to_s}"
      else
        if not sexpr[0].is_a?(SExpr::Real) then
          raise "#{sexpr.pos}: expected integer got #{sexpr[0].class}"
        else
          # ok
        end
      end
    end
  end

  # A list of ((key value) ...) 
  class MappingType
    
  end
  
  # A list of other elements ((foo 5) (bar 10) (baz "foo") ...)
  class SequenceType
    
  end
  
  class ChoiceType
    
  end
end

# EOF #
