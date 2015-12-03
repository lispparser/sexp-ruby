#!/usr/bin/ruby -w

require "value.rb"
require "parser.rb"
require "reader.rb"
require "schema.rb"

# Script to rewrite (switchdoor ...) to (switchdoor-switch ...) and (switchdoor-door ...)
def rewrite_sexpr(sexpr)
  case sexpr
  when SExp::List
    case sexpr[0].to_s
    when "switchdoor"
      sexpr.strip()
      reader = SExp::Reader.new(sexpr)

      switch_reader = reader.read_section("switch")
      switch_pos = switch_reader.read_real_array("position")

      door_reader = reader.read_section("door")
      door_pos = door_reader.read_real_array("position")
      door_height = door_reader.read_integer_array("height")

      id = "id#{rand(2**32)}"

      return [SExp::List.new([SExp::Symbol.new("switchdoor-switch"),
                               SExp::Whitespace.new("\n      "),
                               SExp::List.new([SExp::Symbol.new("target-id"),
                                                SExp::String.new(id)]),
                               SExp::Whitespace.new("\n      "),
                               SExp::List.new([SExp::Symbol.new("position")] +
                                               switch_pos.map{|i| SExp::Integer.new(i)})]),
              SExp::Whitespace.new("\n    "),
              SExp::List.new([SExp::Symbol.new("switchdoor-door"),
                               SExp::Whitespace.new("\n      "),
                               SExp::List.new([SExp::Symbol.new("id"),
                                                SExp::String.new(id)]),
                               SExp::Whitespace.new("\n      "),
                               SExp::List.new([SExp::Symbol.new("height"),
                                                SExp::Integer.new(door_height)]),
                               SExp::Whitespace.new("\n      "),
                               SExp::List.new([SExp::Symbol.new("position")] +
                                               door_pos.map{|i| SExp::Integer.new(i)})])]
    else
      lst = SExp::List.new([])
      sexpr.each{|i|
        el = rewrite_sexpr(i)
        if el
          if el.is_a?(Array)
            lst.concat(el)
          else
            lst.append(el)
          end
        end
      }
      return lst
    end
  else
    return sexpr
  end
end

ARGV.each { |filename|
  puts "Processing: #{filename}"
  begin
    tree = SExp::SExp.parse(File.new(filename).read(), true, true)
    fout = File.new(filename, "w")
    tree.each{|i|
      sexpr = rewrite_sexpr(i)
      if sexpr
        # sexpr.strip()
        sexpr.write(fout)
      end
    }
    fout.close()
  rescue
    puts "fatal error"
  end
}

# EOF #
