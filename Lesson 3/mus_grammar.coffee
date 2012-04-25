
#
# Lesson 3
#


#
# Unit Testing Tools
#

# Testing Requirements

assert = require 'assert'
test   = require 'testrunner'


# Create parser from grammar file

parse = require('pegparser') 'peg/mus.peg'


#
# INCOMPLETE
#


test "raw numbers", ->
    assert.equal parse(  '0', 'num'), 0
    assert.equal parse(  '1', 'num'), 1
    assert.equal parse(  '2', 'num'), 2
    assert.equal parse( '10', 'num'), 10
    assert.equal parse('100', 'num'), 100
    assert.equal parse('500', 'num'), 500

test "raw note values", ->
    assert.equal parse('a1', 'tone'), 'a1'
    assert.equal parse('d2', 'tone'), 'd2'

test "raw rest char", ->
    assert.equal parse('_', 'rest'), '_'

test "single note syntax", ->
    assert.deepEqual parse('a4:200', 'note'), { tag : 'note', pitch : 'a4', dur : 200 }
    assert.deepEqual parse('g4:123', 'note'), { tag : 'note', pitch : 'g4', dur : 123 }

test "note sequence", ->
    assert.deepEqual(
        parse('c4:300 e4:300 g4:300', 'seq')
        tag : 'seq'
        left : { tag : 'note', pitch : 'c4', dur : 300 }
        right :
            tag : 'seq'
            left : { tag : 'note', pitch : 'e4', dur : 300 }
            right : { tag : 'note', pitch : 'g4', dur : 300 }
    )






test.run()



