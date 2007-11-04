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
      @root.validate(sexpr)
    end

    def Schema.report(str)
      puts str
    end

    def Schema.type_factory(reader)
      case reader.name
      when "mapping"
          return MappingType.new(reader)
          
      when "sequence"
          return SequenceType.new(reader)

      when "choice"
          return SequencType.new(reader)
          
      when "integer"
          return IntegerType.new(reader)
        
      when "real"
          return RealType.new(reader)
        
      when "boolean"
          return BooleanType.new(reader)

      when "string"
          return StringType.new(reader)

      when "symbol"
          return SymbolType.new(reader)

      when "vector2i"
        return Vector2iType.new(reader)

      when "size"
        return SizeType.new(reader)

      when "surface"
        return SurfaceType.new(reader)

      when "color"
          return ColorType.new(reader)

      when "any"
          return AnyType.new(reader)

      else
        raise "#{reader.pos}: unknown type '#{reader.name}'"
      end
    end
  end # Schema

  class Element
    attr_reader :name  # name of the expected element
    attr_reader :use   # required, optional, forbidden
    attr_reader :type  # ListType, IntegerType, ...

    def initialize(reader)
      @use  = reader.read_string("use")
      @name = reader.read_string("name")
      
      type_reader = reader.read_section("type").sections()[0]
      @type = Schema.type_factory(type_reader)
    end
    
    def validate(sexpr)
      if not sexpr.is_a?(List) then
        Schema.report "#{sexpr.pos}: expected list, got #{sexpr.class}"
      else
        if sexpr.value.empty? then
          Schema.report "#{sexpr.pos}: expected a non-empty List"
        else
          if not sexpr[0].is_a?(Symbol) then
            Schema.report "#{sexpr.pos}: expected a symbol, got #{sexpr[0].class}"
          else
            if sexpr[0].value != @name then
              Schema.report "#{sexpr.pos}: expected symbol '#{name}', got #{sexpr[0].value}"
            else
              # puts "Element ok: #{@name}"
              # ok, now check type and/or validate children
              type.validate(sexpr[1..-1])
            end
          end            
        end
      end
    end
  end

  class AnyType
    def initialize(reader)
    end

    def validate(sexprlst)
    end
  end

  class SymbolType
    def initialize(reader)
    end

    def validate(sexprlst)
    end
  end

  class StringType
    def initialize(reader)
    end

    def validate(sexprlst)
    end
  end

  class BooleanType
    def initialize(reader)
    end

    def validate(sexprlst)
    end
  end

  class Vector2iType
    def initialize(reader)
    end

    def validate(sexprlst)
      
    end
  end

  class SizeType
    def initialize(reader)
    end

    def validate(sexprlst)
    end
  end

  class ColorType
    def initialize(reader)
    end

    def validate(sexprlst)
    end
  end

  class SurfaceType
    def initialize(reader)
    end

    def validate(sexprlst)
    end
  end

  class IntegerType
    def initialize(reader)
      # FIXME: add min/max and other possible range restrictions here
      @min = reader.read_integer("min")
      @max = reader.read_integer("max")
    end

    def validate(sexpr)
      if sexpr.length() != 1 then
        Schema.report "#{sexpr.pos}: expected a single integer got #{sexpr.to_s}"
      else
        if not sexpr[0].is_a?(Integer) then
          Schema.report "#{sexpr.pos}: expected integer got #{sexpr[0].class}"
        else
          if @max and sexpr[0].value > @max then
            Schema.report "#{sexpr[0].pos}: integer out of range: min=#{@min} max=#{@max} int=#{sexpr[0].value}"
          elsif @min and sexpr[0].value < @min then
            Schema.report "#{sexpr[0].pos}: integer out of range: min=#{@min} max=#{@max} int=#{sexpr[0].value}"
          else
            # everything ok
          end
        end
      end
    end
  end

  class RealType
    def initialize(reader)
      
    end

    def validate(sexpr)
      if sexpr.length() != 1 then
        Schema.report "#{sexpr.pos}: expected a single real got #{sexpr.to_s}"
      else
        if not (sexpr[0].is_a?(Real) or sexpr[0].is_a?(Integer)) then
          # FIXME: Should we make Integer optional?
          Schema.report "#{sexpr.pos}: expected real got #{sexpr[0].class}"
        else
          # ok
        end
      end
    end
  end

  # A list of ((key value) ...) 
  class MappingType
    def initialize(reader)
      @children = reader.read_section("children").sections.map{|el| Element.new(el) }
    end

    def check(name)
      @children.each{|i|
        if i.name == name then
          return true
        end
      }
      return false
    end

    def validate(sexpr)
      sexpr.each{ |el|
        child = @children.find{|i| i.name == el[0].value } # FIXME: Works, but why? Shouldn't String and Symbol clash
        if not child then
          Schema.report "#{el.pos}: invalid element '#{el[0].value}'"
          Schema.report "  - allowed elements are: #{@children.map{|i| i.name}.join(", ")}"
        else
          # puts "MappingType Child: ok: #{el[0].value} #{child}"
          child.validate(el)
        end
      }
    end
  end
  
  # A list of other elements ((foo 5) (bar 10) (baz "foo") ...)
  class SequenceType
    def initialize(reader)
      @children = reader.read_section("children").sections.map{|el| Element.new(el) }
    end    

    def validate(sexprlst) # sexpr == SExpr::List
      sexprlst.each{ |sexpr|
        el = @children.find{|i| i.name == sexpr[0].value }
        if not el then
          Schema.report "#{name.pos}: SequenceType: element '#{name}' not allowed"
        else
          el.validate(sexpr)
        end
      }
    end
  end

  class ChoiceType
    def initialize(reader)
      @children = reader.read_section("children").sections.map{|el| Element.new(el) }
    end    

    def validate(sexpr)
      if sexpr.length() == 1 then
        # sexpr[0]
      else
        Schema.report "Expected exactly one subtag" 
      end
    end
  end

end

# EOF #
