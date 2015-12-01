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

class Array
  def to_sexpr()
    lst = SExpr::List.new([])
    each {|el|
      if el.is_a?(Symbol) then
        lst << SExpr::Symbol.new(el)
      elsif el.is_a?(String) then
        lst << SExpr::String.new(el)
      elsif el.is_a?(Integer) then
        lst << SExpr::Integer.new(el)
      elsif el.is_a?(Float) then
        lst << SExpr::Real.new(el)
      elsif el == true or el == false then
        lst << SExpr::Boolean.new(el)
      elsif el.is_a?(Array) then
        lst << el.to_sexpr()
      end
    }
    return lst
  end
end

# EOF #
