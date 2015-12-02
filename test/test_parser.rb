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

require "sexp-ruby/parser"
require "sexp-ruby"

class TestParser < Test::Unit::TestCase
  def test_parser
    sx_str = "(section (var1 5) (var2 10))"
    lexer = SExpr::Lexer.new(sx_str)
    tokens = lexer.tokenize()
    # puts ">>>>>>>>>>", tokens.inspect
  end

  def test_boolean
    sxs = SExpr::parse("  #f #t  ")
    assert_true(sxs[0].is_a?(SExpr::Boolean))
    assert_true(sxs[1].is_a?(SExpr::Boolean))
    assert_equal(false, sxs[0].value)
    assert_equal(true, sxs[1].value)
  end

  def test_integer
    sxs = SExpr::parse(" 12 43")
    assert_true(sxs[0].is_a?(SExpr::Integer))
    assert_equal(12, sxs[0].value)
    assert_true(sxs[1].is_a?(SExpr::Integer))
    assert_equal(43, sxs[1].value)
  end

  def test_real
    sxs = SExpr::parse("1.125")
    assert_true(sxs[0].is_a?(SExpr::Real))
    assert_equal(1.125, sxs[0].value)
  end

  def test_string
    sxs = SExpr::parse("  \"Hello World\"  ")
    assert_true(sxs[0].is_a?(SExpr::String))
    assert_equal("Hello World", sxs[0].value)
  end

  def test_symbol
    sxs = SExpr::parse("  HelloWorld  ")
    assert_true(sxs[0].is_a?(SExpr::Symbol))
    assert_equal("HelloWorld", sxs[0].value)
  end

  def test_list
    sxs = SExpr::parse("  (1 2 3)  ")
    assert_true(sxs[0].is_a?(SExpr::List))
    assert_equal(3, sxs[0].length)
  end

  def test_roundtrip
    content = File.new("test/level-syntax.scm").read()
    sx = SExpr::parse(content, true, true)
    result = sx.map{|s| s.to_s}.join
    assert_equal(content, result)
  end
end

# EOF #
