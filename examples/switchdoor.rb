#!/usr/bin/ruby -w

require "value.rb"
require "parser.rb"
require "reader.rb"
require "schema.rb"

# Script to rewrite (switchdoor ...) to (switchdoor-switch ...) and (switchdoor-door ...)
def rewrite_sexpr(sexpr)
  case sexpr
  when SExpr::List
    case sexpr[0].to_s
    when "switchdoor"
      sexpr.strip()
      reader = SExpr::Reader.new(sexpr)

      switch_reader = reader.read_section("switch")
      switch_pos = switch_reader.read_real_array("position")

      door_reader = reader.read_section("door")
      door_pos = door_reader.read_real_array("position")
      door_height = door_reader.read_integer_array("height")

      id = "id#{rand(2**32)}"

      return [SExpr::List.new([SExpr::Symbol.new("switchdoor-switch"),
                               SExpr::Whitespace.new("\n      "),
                               SExpr::List.new([SExpr::Symbol.new("target-id"),
                                                SExpr::String.new(id)]),
                               SExpr::Whitespace.new("\n      "),
                               SExpr::List.new([SExpr::Symbol.new("position")] +
                                               switch_pos.map{|i| SExpr::Integer.new(i)})]),
              SExpr::Whitespace.new("\n    "),
              SExpr::List.new([SExpr::Symbol.new("switchdoor-door"),
                               SExpr::Whitespace.new("\n      "),
                               SExpr::List.new([SExpr::Symbol.new("id"),
                                                SExpr::String.new(id)]),
                               SExpr::Whitespace.new("\n      "),
                               SExpr::List.new([SExpr::Symbol.new("height"),
                                                SExpr::Integer.new(door_height)]),
                               SExpr::Whitespace.new("\n      "),
                               SExpr::List.new([SExpr::Symbol.new("position")] +
                                               door_pos.map{|i| SExpr::Integer.new(i)})])]
    else
      lst = SExpr::List.new([])
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
    tree = SExpr::SExpr.parse(File.new(filename).read(), true, true)
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
