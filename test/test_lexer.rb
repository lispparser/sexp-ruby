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

require "test/unit"

require "sexp-ruby/lexer"

class TestLexer < Test::Unit::TestCase
  def test_tokenize
    sx_str = "(section (var1 5) (var2 10))"
    expected = [[:list_start, "(", 1, 1],
                [:symbol, "section", 1, 9],
                [:whitespace, " ", 1, 10],
                [:list_start, "(", 1, 10],
                [:symbol, "var1", 1, 15],
                [:whitespace, " ", 1, 16],
                [:integer, "5", 1, 17],
                [:list_end, ")", 1, 17],
                [:whitespace, " ", 1, 19],
                [:list_start, "(", 1, 19],
                [:symbol, "var2", 1, 24],
                [:whitespace, " ", 1, 25],
                [:integer, "10", 1, 27],
                [:list_end, ")", 1, 27],
                [:list_end, ")", 1, 28]]
    lexer = SExp::Lexer.new(sx_str)
    result = lexer.tokenize()
    assert_equal(expected.to_s, result.to_s)
  end
end

# EOF #
