Gem::Specification.new do |s|
  s.name        = 'sexp-ruby'
  s.version     = '0.1.0'
  s.date        = '2015-12-01'
  s.summary     = "A simple Ruby library for parsing and validating s-expressions"
  s.description = "sexp-ruby is a Ruby library for parsing a subset of s-expressions, " +
                  "namely cons aren't handled and replaced by more convenient lists. So " +
                  "something like:\n" +
                  "\n" +
                  "    (foo (bar baz))\n" +
                  "\n" +
                  "is parsed properly, but something like:\n" +
                  "\n" +
                  "    (foo . ((bar . (baz . ())) . ()))\n" +
                  "\n" +
                  "isn't handled and gives a syntax error, even so they would be " +
                  "equivalent in a full sexp-ruby style parser.\n" +
                  "\n" +
                  "sexp-ruby isn't meant to be fast, but meant to be as verbose as " +
                  "possible, meaning it can give you the line and column of a given " +
                  "sexp-ruby and parse comments and whitespace as well if required.\n" +
                  "\n" +
                  "Beside the basic parser sexp-ruby also contains a xschema-like " +
                  "verifier in the form of sexp::Schema and a simple helper in the form " +
                  "of sexp::Reader that gives XPath like features."
  s.authors     = ["Ingo Ruhnke"]
  s.email       = 'grumbel@gmail.com'
  s.files       = Dir.glob("{bin,lib}/**/*.rb")
  s.homepage    = 'https://github.com/lispparser/sexp-ruby'
  s.license     = 'zlib'
end
