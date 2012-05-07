#
# Project make process specification
#

project =

    # Uses uglify to minify output if true
    minify : false

    # Disable CoffeeScript safety context
    bare : false

    # Specify directories or files to monitor for file writes
    monitor : [
        "src"
        "build/project.coffee"
    ]

    # Target file contains resulting compiled code
    target : "bin/scheem.js"

    # List of source files, in concatenation order
    source : [

        # Libs
        "lib/jquery.js"
        "lib/codemirror/codemirror.js"
        "lib/codemirror/modes/scheem.js"

        # JS Source
        "src/peg/scheem.js"
        "src/bootstrap.dropdown.js"

        # Coffee Source
        "src/helpers.coffee"
        "src/interpreter.coffee"
        "src/program.coffee"

    ]
