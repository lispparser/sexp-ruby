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

require "sexp-ruby/reader"

require "test/unit"

class TestReader < Test::Unit::TestCase

  def test_simple
    reader = SExp::Reader.from_string("(pingus-level (head) (bla 5))")
    assert_equal("pingus-level", reader.name)
    assert_equal(5, reader.read_integer(["bla"]))
  end

  def test_from_file
    reader = SExp::Reader.from_file("test/level.scm")
    assert_equal("pingus-level", reader.name)
    assert_equal(3, reader.read_integer(["version"]))
    assert_equal("Miner's heaven", reader.read_string(["head", "levelname"]))
    assert_equal(nil, reader.read_integer(["not-there"]))
  end

end

# EOF #
