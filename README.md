sexp-ruby
=========

sexp-ruby is a Ruby library for parsing a subset of s-expressions,
namely cons/pairs aren't handled, instead everything is treated as a
list/arrray. In practical terms that means something like this:

    (foo (bar baz))

is parsed properly, but something like:

    (foo . ((bar . (baz . ())) . ()))

isn't handled and gives a syntax error.

sexp-ruby isn't meant to be fast, but instead focuses on being as
verbose as possible, meaning it builds a complete DOM'ish tree and can
give the line and column of a given s-expression and parse comments
and whitespace as well, thus allowing structural modifications of
s-expression files while preserving the formating.

Beside the basic parser sexp-ruby also contains a xschema-like
verifier in the form of sexp::Schema and a simple helper in the form
of sexp::Reader that gives XPath like features.

