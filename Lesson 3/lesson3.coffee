
#
# Lesson 3
#


#
# Unit Testing Tools
#

# Testing Requirements

assert = require 'assert'
test   = require 'testrunner'


# Create parsers from PEG grammar files

parser      = require('pegparser')


parseScheem = parser 'peg/scheem.peg'   # scheem parser


# Exercise 1 - Accept uppercase characters

parseEx1 = parser 'peg/ex1.peg'

test "don't parse empty",        -> assert.throws (-> parseEx1 ""), SyntaxError
test "parse single A",           -> assert.equal parseEx1("A"), "A"
test "parse single M",           -> assert.equal parseEx1("M"), "M"
test "don't parse lowercase d",  -> assert.throws (-> parseEx1 "d"), SyntaxError
test "don't parse double ucase", -> assert.throws (-> parseEx1 "AB"), SyntaxError

test.run()


# Exercise 2 - Accept 2-character country codes (lowercase)

parseEx2    = parser 'peg/ex2.peg'

test "don't parse empty", -> assert.throws (-> parseEx2 ""), SyntaxError
test "parse Canada",      -> assert.equal parseEx2("ca"), "ca"
test "parse Germany",     -> assert.equal parseEx2("de"), "de"
test "don't parse uae",   -> assert.throws (-> parseEx2 "uae"), SyntaxError

test.run()


# Exercise 3 - Accept a word only where all characters are the same case

parseEx3    = parser 'peg/ex3.peg'

test "don't parse empty", -> assert.throws (-> parseEx3 ""), SyntaxError
test "parse dog",         -> assert.equal parseEx3("dog"), "dog"
test "parse DOG",         -> assert.equal parseEx3("DOG"), "DOG"
test "don't parse Dog",   -> assert.throws (-> parseEx3 "Dog"), SyntaxError

test.run()


# Exercise 4 - Wordlist

parseEx4    = parser 'peg/ex4.peg'

test "don't parse empty",     -> assert.throws (-> parseEx4 ""), SyntaxError
test "parse dog",             -> assert.deepEqual parseEx4("dog"), [ "dog" ]
test "parse black dog",       -> assert.deepEqual parseEx4("black dog"), [ "black", "dog" ]
test "parse angry black dog", -> assert.deepEqual parseEx4("angry black dog"), [ "angry", "black", "dog" ]
test "don't parse Gray Dog",  -> assert.throws (-> parseEx4 "Gray dog"), SyntaxError

test.run()


# Exercise 5 - Simple Scheem Parser

test "dont parse empty string", -> assert.throws (-> parseScheem ""), SyntaxError
test "parse atom",              -> assert.equal parseScheem('atom'), 'atom'
test "parse +",                 -> assert.equal parseScheem('+'), '+'
test "parse (+ x 3)",           -> assert.deepEqual parseScheem("(+ x 3)"), [["+", "x", "3"]]
test "parse (+ (1 (f x 3 y))",  -> assert.deepEqual parseScheem("(+ 1 (f x 3 y))"), [["+", "1", ["f", "x", "3", "y"]]]

test.run()


# Exercise 7 - Math expression parser with 'comma' operator

parseMath   = parser 'peg/math.peg'

test "parseMath 1+2",   -> assert.deepEqual parseMath("1+2"),   { tag:"+", left:1, right:2 }
test "parseMath 1+2*3", -> assert.deepEqual parseMath("1+2*3"), { tag:"+", left:1, right:{ tag:"*", left:2, right:3 } }
test "parseMath 1,2",   -> assert.deepEqual parseMath("1,2+3"), { tag:",", left:1, right:{ tag:"+", left:2, right:3 } }
test "parseMath 1,2+3", -> assert.deepEqual parseMath("1,2"),   { tag:",", left:1, right:2 }
test "parse 1*2,3",     -> assert.deepEqual parseMath("1*2,3"), { tag:",", left:{ tag:"*", left:1, right:2 }, right:3 }

test.run()


#
# Extending the Scheem Parser
#
# Homework Exercises
#

# Whitespace

test "multi-space whitespace", ->
    assert.deepEqual parseScheem("(atom    atom)"), [[ "atom", "atom" ]]

test "pad parentheses", ->
    assert.deepEqual parseScheem("( atom atom )"), [[ "atom", "atom" ]]

test "newlines", ->
    assert.deepEqual parseScheem("(atom \n atom)"), [[ "atom", "atom" ]]

test "tabstops", ->
    assert.deepEqual parseScheem("(atom \t atom)"), [[ "atom", "atom" ]]

test "quotes", ->
    assert.deepEqual parseScheem("'(1 2 3)"), [[ "quote", [ 1, 2, 3 ] ]]

test "comments", ->
    assert.deepEqual parseScheem(";; A comment\n(+ 3 5)"), [[ '+', 3, 5 ]]

test "a more complex program", ->

    scheemProgram =
        """
        ;; Add squares of two numbers (probably)

        (def addsq
          (lambda x y
            (+
              (* x x)
              (* y y))))

        ;; Example

        (def z (addsq 4 5))
        """

    expectedOutput = [
        [ "def", "addsq",
        [ "lambda", "x", "y",
        [ "+",
        [ "*", "x", "x" ],
        [ "*", "y", "y" ] ] ] ],
        [ "def", "z",
        [ "addsq", "4", "5" ] ]
    ]

    assert.deepEqual parseScheem(scheemProgram), expectedOutput


test.run()
















