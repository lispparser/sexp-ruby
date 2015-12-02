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

module SExpr
  class Token
    attr_reader :type, :text, :line, :column

    def initialize(type, text, line, column)
      @type = type
      @text = text
      @line = line
      @column = column
    end

    def inspect
      return "[#{@type.inspect}, #{@text.inspect}, #{@line}, #{@column}]"
    end
  end

  class TextIO
    attr_reader :text, :line, :column, :pos

    def initialize(text)
      @text = text
      @line   = 1
      @column = 1
      @pos = 0
    end

    def peek()
      return @text[@pos]
    end

    def advance()
      # Line/Column counting
      if peek() == "\n" then
        @line   += 1
        @column  = 1
      else
        @column += 1
      end

      @pos += 1
    end

    def eof?
      return !(@pos < @text.length)
    end
  end

  class Lexer
    def initialize(text)
      @io = TextIO.new(text)

      @statefunc = method(:look_for_token)

      @last_c = nil
      @tokens = []

      @token_start = @io.pos

      @advance = true
    end

    def tokenize()
      while not @io.eof? do
        c = @io.peek()

        @statefunc.call(c)

        if @advance then
          @last_c = c

          @io.advance
        else
          @advance = true
        end
      end

      @statefunc.call(nil)

      return @tokens
    end

    def look_for_token(c)
      if c == nil
        # eof
      elsif is_digit(c) or is_sign(c) or c == "." then
        @statefunc = method(:parse_integer_or_real)
      elsif c == "\"" then
        @statefunc = method(:parse_string)
      elsif c == "#" then
        @statefunc = method(:parse_boolean)
      elsif is_letter(c) or is_special_initial(c) then
        @statefunc = method(:parse_symbol)
      elsif is_whitespace(c) then
        @statefunc = method(:parse_whitespace)
      elsif c == ";" then
        @statefunc = method(:parse_comment)
      elsif c == ")" then
        submit(:list_end, true)
      elsif c == "(" then
        submit(:list_start, true)
      else
        raise "#{@io.line}:#{@io.column}: unexpected character #{c.inspect}"
      end
    end

    def parse_integer_or_real(c)
      if is_digit(c) then
      # ok
      elsif c == ?. then
        @statefunc = method(:parse_real)
      else
        if @token_start == @io.pos - 1 and not is_digit(@io.text[@token_start]) then
          raise "#{@io.line}:#{@io.column}: '#{@io.text[@token_start].chr}' must be followed by digit"
        else
          submit(:integer, false)
        end
      end
    end

    def parse_boolean(c)
      if c == "t" or c == "f" then
        submit(:boolean, true)
      else
        raise "#{@line}:#{@column}: expected 'f' or 't', got '#{c.chr}"
      end
    end

    def parse_real(c)
      if ("0".."9").member?(c) then
      # ok
      else
        submit(:real, false)
      end
    end

    def parse_symbol(c)
      if is_letter(c) or is_digit(c) or is_special_subsequent(c) or is_special_initial(c) then
      # ok
      else
        submit(:symbol, false)
      end
    end

    def parse_string(c)
      if (c == "\"" and @last_c != "\\") then
        submit(:string, true)
      end
    end

    def parse_whitespace(c)
      if not is_whitespace(c) then
        submit(:whitespace, false)
      end
    end

    def parse_comment(c)
      if c == "\n" then
        submit(:comment, true)
      end
    end

    def submit(type, include_current_character)
      @statefunc = method(:look_for_token)

      if include_current_character then
        current_token = @io.text[@token_start..(@io.pos)]
        @token_start = @io.pos+1
      else
        current_token = @io.text[@token_start..(@io.pos-1)]
        @token_start = @io.pos
        @advance = false
      end

      # FIXME: line:column refers to the end of the token, not the start

      case type
      when :string
        @tokens << Token.new(:string,
                             current_token[1..-2].
                               gsub("\\n", "\n").
                               gsub("\\\"", "\"").
                               gsub("\\t", "\t"),
                             @io.line, @io.column)
      when :list_start
        @tokens << Token.new(:list_start, current_token, @io.line, @io.column)
      when :list_end
        @tokens << Token.new(:list_end, current_token, @io.line, @io.column)
      else
        @tokens << Token.new(type, current_token, @io.line, @io.column)
      end
    end

    def is_digit(c)
      return ("0".."9").member?(c)
    end

    def is_letter(c)
      return (("a".."z").member?(c) or ("A".."Z").member?(c))
    end

    def is_whitespace(c)
      return [" ", "\n", "\t"].member?(c)
    end

    def is_special_initial(c)
      return ["!", "$", "%", "&", "*", "/", ":", "<", "=", ">", "?", "^", "_", "~"].member?(c)
    end

    def is_special_subsequent(c)
      return ["+", "-", ".", "@"].member?(c)
    end

    def is_sign(c)
      return ["+", "-"].member?(c)
    end
  end
end

# EOF #
