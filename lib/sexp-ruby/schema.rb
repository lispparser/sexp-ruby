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
require_relative "reader.rb"
require_relative "parser.rb"

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

      when "vector3i"
        return Vector3iType.new(reader)

      when "size"
        return SizeType.new(reader)

      when "surface"
        return SurfaceType.new(reader)

      when "color"
        return ColorType.new(reader)

      when "enumeration"
        return EnumerationType.new(reader)

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
    attr_reader :deprecated # #t, #f

    def initialize(reader)
      @use  = reader.read_string("use")
      @name = reader.read_string("name")
      @deprecated = reader.read_boolean("deprecated")

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
              if @deprecated then
                Schema.report "#{sexpr.pos}: symbol '#{name}' is deprecated"
              end

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
      Schema.report "#{sexprlst.pos}: AnyType: #{sexprlst.parent.to_sexpr}"
    end
  end

  class SymbolType
    def initialize(reader)
    end

    def validate(sexprlst)
      if sexprlst.length() != 1 then
        Schema.report "#{sexpr.pos}: expected a single Symbol got #{sexpr.to_s}"
      else
        if not sexprlst[0].is_a?(Symbol) then
          Schema.report "#{sexpr.pos}: expected Symbol got #{sexpr[0].class}"
        else
          # ok
        end
      end
    end
  end

  class StringType
    def initialize(reader)
    end

    def validate(sexprlst)
      if sexprlst.length() != 1 then
        Schema.report "#{sexprlst.pos}: expected a single String got #{sexprlst.to_s}"
      else
        if not sexprlst[0].is_a?(String) then
          Schema.report "#{sexprlst.pos}: expected String got #{sexprlst[0].class}"
        else
          # ok
        end
      end
    end
  end

  class BooleanType
    def initialize(reader)
    end

    def validate(sexprlst)
      if sexprlst.length() != 1 then
        Schema.report "#{sexprlst.pos}: expected a single boolean got #{sexprlst.to_s}"
      else
        if not sexprlst[0].is_a?(Boolean) then
          Schema.report "#{sexprlst.pos}: expected Boolean got #{sexprlst[0].to_sexpr}"
        else
          # ok
        end
      end
    end
  end

  class EnumerationType
    def initialize(reader)
      @values = reader.read_string_array("values")
      if not @values then
        raise "#{reader.pos}: Error: 'values' not specified"
      end
    end

    def validate(sexprlst)
      if sexprlst.length() != 1 then
        Schema.report "#{sexprlst.pos}: expected a single String got #{sexprlst.to_sexpr}"
      else
        if not sexprlst[0].is_a?(String) then
          Schema.report "#{sexprlst.pos}: expected String got #{sexprlst[0].class}"
        else
          if not @values.member?(sexprlst[0].value) then
            Schema.report "#{sexprlst.pos}: '#{sexprlst[0].value}' not a member of [#{@values.map{|i| i.inspect}.join(", ")}]"
          else
            # ok
          end
        end
      end
    end
  end

  class Vector2iType
    def initialize(reader)
    end

    def validate(sexprlst)
      if sexprlst.length() != 2 then
        Schema.report "#{sexprlst.pos}: expected a two Integer got #{sexprlst.to_s}"
      else
        if not sexprlst[0].is_a?(Integer) or not sexprlst[1].is_a?(Integer) then
          Schema.report "#{sexprlst.pos}: expected two Integer got #{sexprlst.map{|i| i.class}.join(", ")}"
        else
          # ok
        end
      end
    end
  end

  class Vector3iType
    def initialize(reader)
    end

    def validate(sexprlst)
      if sexprlst.length() != 3 then
        Schema.report "#{sexprlst.pos}: expected a three Integer got #{sexprlst.to_s}"
      else
        if not sexprlst[0].is_a?(Integer) or
            not sexprlst[1].is_a?(Integer) or
            not sexprlst[2].is_a?(Integer)
        then
          Schema.report "#{sexprlst.pos}: expected three Integer got #{sexprlst.map{|i| i.class}.join(", ")}"
        else
          # ok
        end
      end
    end
  end

  class SizeType
    def initialize(reader)
    end

    def validate(sexprlst)
      if sexprlst.length() != 2 then
        Schema.report "#{sexprlst.pos}: expected a two Integer got #{sexprlst.to_s}"
      else
        if not sexprlst[0].is_a?(Integer) or not sexprlst[1].is_a?(Integer) then
          Schema.report "#{sexprlst.pos}: expected two Integer got #{sexprlst.to_sexpr}"
        elsif sexprlst[0].value < 0 or sexprlst[1].value < 0 then
          Schema.report "#{sexprlst.pos}: size values must be >= 0: got #{sexprlst.to_sexpr}"
        else
          # ok
        end
      end
    end
  end

  class ColorType
    def initialize(reader)
    end

    def validate(sexprlst)
      if sexprlst.length() != 4 then
        Schema.report "#{sexprlst.pos}: expected a four Real got #{sexprlst.to_s}"
      else
        if  not (sexprlst[0].is_a?(Integer) or sexprlst[0].is_a?(Real)) or
            not (sexprlst[1].is_a?(Integer) or sexprlst[1].is_a?(Real)) or
            not (sexprlst[2].is_a?(Integer) or sexprlst[2].is_a?(Real)) or
            not (sexprlst[3].is_a?(Integer) or sexprlst[3].is_a?(Real))
        then
          Schema.report "#{sexprlst.pos}: expected three Real got #{sexprlst.to_sexpr}"
        elsif not (sexprlst[0].value >= 0 and sexprlst[0].value <= 1.0 and
                   sexprlst[1].value >= 0 and sexprlst[1].value <= 1.0 and
                   sexprlst[2].value >= 0 and sexprlst[2].value <= 1.0 and
                   sexprlst[3].value >= 0 and sexprlst[3].value <= 1.0) then
          Schema.report "#{sexprlst.pos}: Color values must be within [0,1] got #{sexprlst.to_sexpr}"
        else
          # ok
        end
      end
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
      @min = reader.read_real("min")
      @max = reader.read_real("max")
    end

    def validate(sexpr)
      if sexpr.length() != 1 then
        Schema.report "#{sexpr.pos}: expected a single real got #{sexpr.to_s}"
      else
        if not (sexpr[0].is_a?(Real) or sexpr[0].is_a?(Integer)) then
          # FIXME: Should we make Integer optional?
          Schema.report "#{sexpr.pos}: expected real got #{sexpr[0].class}"
        else
          if @max and sexpr[0].value > @max then
            Schema.report "#{sexpr[0].pos}: real out of range: min=#{@min} max=#{@max} real=#{sexpr[0].value}"
          elsif @min and sexpr[0].value < @min then
            Schema.report "#{sexpr[0].pos}: real out of range: min=#{@min} max=#{@max} real=#{sexpr[0].value}"
          else
            # everything ok
          end
        end
      end
    end
  end

  # A list of ((key value) ...)
  class MappingType
    def initialize(reader)
      @children = reader.read_section("children").sections.map{|el| Element.new(el) }
    end

    def validate(sexpr)
      sexpr.each{ |el|
        child = @children.find{|i| i.name == el[0].value } # FIXME: Works, but why? Shouldn't String and Symbol clash
        if not child then
          Schema.report "#{el.pos}: invalid element '#{el[0].value}'"
          Schema.report "  - allowed elements are: #{@children.map{|i| i.name}.join(", ")}"
        else
          # puts "MappingType Child: ok: #{el[0].value} #{child}"
          # FIXME: Add validation of (use "required") types
          child.validate(el)
        end
      }
    end
  end

  # A list of elements, duplicates are allowed, optional items are possible
  # ((foo 5) (bar 10) (baz "foo") ...)
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
        if not sexpr[0].is_a?(List) then
          Schema.report "#{sexpr.pos}: expected List, got #{sexpr.to_sexpr}"
        elsif not sexpr[0].empty? then
          Schema.report "#{sexpr.pos}: expected List, got #{sexpr.to_sexpr}"
        elsif not sexpr[0][0].is_a?(Symbol) then
          Schema.report "#{sexpr.pos}: expected Symbol as first element, got #{sexpr.to_sexpr}"
        else
          el = @children.find{ |el| sexpr[0][0].value == el.name }
          if not el then
            Schema.report "#{sexpr.pos}: invalid child element: #{sexpr[0].to_sexpr}"
          else
            # everything ok
          end
        end
      else
        Schema.report "Expected exactly one subtag"
      end
    end
  end

end

# EOF #
