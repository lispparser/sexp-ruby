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
require_relative "lexer.rb"

module SExpr
  class Position
    attr_reader :line, :column

    def initialize(line, column)
      @line = line
      @column = column
    end
  end

  class Parser
    def initialize(comments=false, whitespace=false)
      @parse_comments = comments
      @parse_whitespace = whitespace
    end

    def parse(tokens)
      elements = []
      sublists = []

      tokens.each{ |token|
        case token.type
        when :list_start
          sublists.push(List.new([], pos: Position.new(token.line, token.column)))
        when :list_end
          if sublists.empty? then
            raise "Unexpected List end"
          else
            lst = sublists.pop()
            if not sublists.empty? then
              sublists.last() << lst
            else
              elements << lst
            end
          end
        else
          sx = create_sexp(token)
          if sx == nil
          else
            if not sublists.empty? then
              sx.parent = sublists.last()
              sublists.last() << sx
            else
              elements << sx
            end
          end
        end
      }

      return elements
    end

    def create_sexp(token)
      pretty_pos = Position.new(token.line, token.column)

      case token.type
      when :boolean
        return Boolean.new(token.text == "#t", pretty_pos)

      when :integer
        return Integer.new(Integer(token.text), pretty_pos)

      when :real
        return Real.new(Float(token.text), pretty_pos)

      when :string
        return String.new(token.text, pretty_pos)

      when :symbol
        return Symbol.new(token.text, pretty_pos)

      when :comment
        if @parse_comments then
          return Comment.new(token.text, pretty_pos)
        else
          return nil
        end

      when :whitespace
        if @parse_whitespace then
          return Whitespace.new(token.text, pretty_pos)
        else
          return nil
        end

      else
        raise "Parser Bug: #{type}"
      end
    end
  end
end

# EOF #
