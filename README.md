sexp-ruby
=========

sexp-ruby is a Ruby library for parsing a subset of s-expressions,
namely cons aren't handled and replaced by more convenient lists. So
something like:

    (foo (bar baz))

is parsed properly, but something like:

    (foo . ((bar . (baz . ())) . ()))

isn't handled and gives a syntax error, even so they would be
equivalent in a full sexp-ruby style parser.

sexp-ruby isn't meant to be fast, but meant to be as verbose as
possible, meaning it can give you the line and column of a given
sexp-ruby and parse comments and whitespace as well if required.

Beside the basic parser sexp-ruby also contains a xschema-like
verifier in the form of sexp::Schema and a simple helper in the form
of sexp::Reader that gives XPath like features.

