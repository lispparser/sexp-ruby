#!/usr/bin/ruby -w

require "sexpr.rb"
require "parser.rb"
require "reader.rb"
require "schema.rb"

# Script to rewrite (switchdoor ...) to (switchdoor-switch ...) and (switchdoor-door ...)
def rewrite_sexpr(sexpr)
  case sexpr
  when SExpr::List
    case sexpr[0].to_s
    when "position"
      sexpr.strip()
      return SExpr::List.new([SExpr::Symbol.new('position'),
                              SExpr::Integer.new(sexpr[1].to_s.to_i - 1),
                              SExpr::Integer.new(sexpr[2].to_s.to_i - 1),
                              SExpr::Integer.new(sexpr[3].to_s.to_i)])
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
