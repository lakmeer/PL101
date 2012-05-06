
#!/bin/sh

mocha -u tdd test/tests.coffee --compilers coffee:coffee-script --watch -R list

