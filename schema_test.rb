#!/usr/bin/ruby -w

require "sexpr.rb"
require "parser.rb"
require "schema.rb"

if ARGV.length != 2 then
  puts "Usage: schema_test.rb SCHEMAFILE SCMFILE"
else
  schema = SExpr::Schema.new(File.new(ARGV[0]).read())
  sexpr  = SExpr::SExpr.parse(File.new(ARGV[1]).read())
  # puts schema.inspect
  schema.validate(sexpr[0])
end

# EOF #

