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
  class Parser
    def initialize()
    end

    def parse(tokens)
      elements = []
      sublists = []

      tokens.each{ |token|
        if token.is_a?(Value) then
          if not sublists.empty? then
            token.parent = sublists.last()
            sublists.last() << token
          else
            elements << token
          end
        elsif token.is_a?(Array) then
          if token[0] == :list_start then
            sublists.push(List.new([], token[1], token[2]))
          elsif token[0] == :list_end then
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
          end
        else
          raise "Parser bug: parse: #{token.inspect}"
        end
      }

      return elements
    end
  end
end

# EOF #
