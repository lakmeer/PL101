

#
# Course Exercises
#

# Ex 1: Prelude - adds D4 (500ms) to start of MUS expression

prelude = (expr) ->
    tag   : 'seq'
    left  : { tag : 'note', pitch : 'd4', dur : 500 }
    right : expr



# Ex 2: Reverse - given a MUS expression, produce an expression with the same notes in reverse order

reverse = (expr) ->
    if expr.tag is 'note' then return expr

    tag   : expr.tag
    left  : reverse expr.right
    right : reverse expr.left


# Ex 3: Endtime - given a MUS seq, calculate the time in ms to the end of the last note

endTime = (time, expr) ->
    if expr.tag is 'note' then return time + expr.dur

    endTime endTime(time, expr.left), expr.right


# Ex 4: Compiler

# This function evolves into the more sophistacted compiler
# as a result of the extra exercises later on. Finished code
# inside node_modules/compiler.coffee




#
# Compiler Unit Tests
#

# A MUS song to compile. Includes 'par', 'rest', and 'repeat'

mus_song =
  tag : 'seq'
  left :
    tag : 'par'
    left  : { tag: 'note', dur: 250, pitch: 'c3' }
    right : { tag: 'rest', dur: 500 }
  right :
    tag : 'par'
    left  : { tag: 'note', dur: 500, pitch: 'd3' }
    right :
      tag : 'repeat'
      count : 3
      section : { tag: 'note', dur: 100, pitch: 'f4' }



# Compiled version for error checking

note_song = [
    { tag: 'note', dur: 250, start:   0, pitch: '48' }
    { tag: 'rest', dur: 500, start:   0              }
    { tag: 'note', dur: 500, start: 500, pitch: '50' }
    { tag: 'note', dur: 100, start: 500, pitch: '65' }
    { tag: 'note', dur: 100, start: 600, pitch: '65' }
    { tag: 'note', dur: 100, start: 700, pitch: '65' }
]



# Include libs

assert   = require 'assert'
comp_mus = require 'compiler'



# Test compilation of example song

try
    assert.deepEqual comp_mus(mus_song), note_song
    console.log "Compilation successful"

catch err
    console.error "Compilation failed:"
    console.error err

