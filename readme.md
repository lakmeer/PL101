PL101
=====

Coursework, homework and whatever else for Nathan's University course PL101.
My work is implemented in Coffeescript, and run with the npm binary 'coffee'
instead of node. 

Installing npm 'coffee':

    $ sudo npm install coffee-script -g

Handy rapid iteration tip for Vim users:

    " Run current coffeescript file
    :map <F5> :!coffee %<CR>


Lesson 1
--------

Nothing here yet (I started late).


Lesson 2
--------

Source for all lesson exercises, and MUS to NOTE compiler.
Modularised the MUS compiler to a node module callable as `compile = require 'compiler'`.


Lesson 3
--------

Grammar files for all the lesson exercises, with tests. Got distracted making a simple test runner around `assert` for unit testing.
Scheem homework completed, with unit tests for them. Extended my Scheem to support whole programs (as opposed to single expressions) cos I thought it was more interesting. Short Scheem program defined in the tests as example.

Started making MUS grammar, can currently pass sequences of notes as `c4:200 e4:200 g4:200` etc. Outputs MUS-compatible seq-list.


