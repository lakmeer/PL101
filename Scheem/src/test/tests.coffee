
# Assertion lib

Chai   = require 'chai'

assert = Chai.assert
expect = Chai.expect


# Create parser from updated grammar file

parseScheem = require('pegparser') 'peg/scheem.peg'
evalScheem  = require('interpreter')


# Gonna get sick of typing these

p = parseScheem
e = evalScheem



# Run Tests

suite "Parser Extensions -", ->

    test 'return real numbers instead of tokens', ->
        assert.deepEqual p('(+ 2 4)'), [ '+', 2, 4 ]
        assert.notDeepEqual p('(+ 2 4)'), [ '+', '2', '4' ]

    test 'handle number detection edge cases', ->
        assert.equal p('1'), 1
        assert.equal p('0'), 0
        assert.equal p('001'), 1
        assert.equal p('000'), 0

    test 'detect decimal notation', ->

        assert.equal p('1.0'), 1
        assert.equal p('1.1'), 1.1
        assert.equal p('0.0'), 0
        assert.equal p('0.1'), 0.1

        assert.equal p('1234.4321'), 1234.4321

    test 'detect negative numbers', ->

        assert.deepEqual p('(10 -10)'), [ 10, -10 ]
        assert.equal p('-1'), -1
        assert.equal p('-1.5'), -1.5



suite 'Arithmetic -', ->

    test 'add some numbers', ->
        assert.equal e(p(" (+ 1 4)        ")), 5
        assert.equal e(p(" (+ 10 234)     ")), 244
        assert.equal e(p(" (+ 0 (+ 1 2))  ")), 3

    test 'subtract some numbers', ->
        assert.equal e(p(" (- 2 2)        ")), 0
        assert.equal e(p(" (- 2 -1)       ")), 3
        assert.equal e(p(" (- 5 (- 20 5)) ")), -10

    test 'multiplication', ->
        assert.equal e(p(" (* 2 3)        ")), 6
        assert.equal e(p(" (* 2 (* 2 2))  ")), 8

    test 'division', ->
        assert.equal e(p(" (/ 2 4)        ")), 0.5
        assert.equal e(p(" (/ 2 (/ 4 2))  ")), 1

    test 'more complicated expression', ->
        assert.equal e(p(" (/ (+ 20 (* (+ 1 1) (/ (* 10 4) 2))) 6) ")), 10



suite 'Lists -', ->

    test 'create lists with cons', ->
        assert.deepEqual e(p(" (cons 1 2)        ")), [ 1, 2 ]
        assert.deepEqual e(p(" (cons '(1 3) 2)   ")), [ [ 1, 3], 2 ]
        assert.deepEqual e(p(" (cons 1 '((1 2))) ")), [ 1, [ 1, 2 ] ]

    test 'retreive list head with car', ->
        assert.deepEqual e(p(" (car '(1 2 3))    ")), 1
        assert.deepEqual e(p(" (car (cons 2 3))  ")), 2
        assert.deepEqual e(p(" (car '(3 2 1 0))  ")), 3

        assert.notDeepEqual e(p(" (car '(3 2 1 0)) ")), [ 3 ]

    test 'retreive list tail with cdr', ->
        assert.deepEqual e(p(" (cdr '(1 2 3))    ")), [ 2, 3 ]
        assert.deepEqual e(p(" (cdr (cons 2 3))  ")), [ 3 ]
        assert.deepEqual e(p(" (cdr '(3 2 1 0))  ")), [ 2, 1, 0 ]

        assert.notDeepEqual e(p(" (cdr '(3 2)) ")), 2


suite 'Environment -', ->

    test 'dereference variable from environment', ->
        assert.equal e(p("    x    "), { bindings : { x : 10 } }), 10
        assert.equal e(p(" (+ x 1) "), { bindings : { x : 10 } }), 11
        assert.equal e(p(" (* x x) "), { bindings : { x : 10 } }), 100

    test 'store variables with define', ->
        assert.deepEqual e(p(" (begin (define x 200) x) ")), 200
        assert.deepEqual e(p(" (begin (define y '(1 2 3)) y) ")), [ 1, 2, 3 ]

    test 'retreive stored values', ->
        assert.equal e(p(" (begin (define z 42) z) ")), 42
        assert.equal e(p(
            """
              (begin
                (define x 20)
                (define y (* x x))
                y
              )
            """)), 400

    test 'update stored values with set!', ->
        assert.equal e(p(
            """
              (begin
                (def  x 1)
                (set! x 2)
                (set! x 3)
                (set! x 4)
                x
              )
            """)), 4

    test 'local scoping with let-one', ->
        assert.equal e(p(" (let-one x 4 x) ")), 4
        assert.equal e(p(" (begin (let-one x 4 x) x)" )), null

    test 'outer scope intact after scoping with let-one', ->
        assert.equal e(p(" (begin (define x 4) (let-one x 8 x) x) ")), 4
        assert.equal e(p(" (begin (define x 4) (let-one y 8 y) y) ")), null




suite 'Conditionals -', ->

    test 'evaluate whether two things are equal', ->
        assert.equal e(p(" (= 2 2) ")), '#t'
        assert.equal e(p(" (= x x) ")), '#t'

        assert.notEqual e(p(" (= 1 2) ")), '#t'

    test 'evaluate inequality', ->
        assert.equal e(p(" (> 2 1) ")), '#t'
        assert.equal e(p(" (< 1 2) ")), '#t'
        assert.equal e(p(" (< 2 1) ")), '#f'
        assert.equal e(p(" (> 1 2) ")), '#f'

    test 'evaluate results based on test results', ->
        assert.equal e(p(" (if (= 1 1) 3 4) ")), 3
        assert.equal e(p(" (if (= 1 2) 3 4) ")), 4

        assert.equal e(p(" (begin (if (= 2 2) (def x 3) (def x 4)) x)")), 3


suite 'Errors -', ->

    test 'Catch parser-generated syntax errors', ->
        expect(-> e(p(""))).to.throw(SyntaxError)
        expect(-> e(p("'"))).to.throw(SyntaxError)
        expect(-> e(p("()"))).to.throw(SyntaxError)
        expect(-> e(p("1zs"))).to.throw(SyntaxError)
        expect(-> e(p("1'23"))).to.throw(SyntaxError)
        expect(-> e(p("'123x"))).to.throw(SyntaxError)

    test 'Restrict define and set! to proper uses', ->

        expect(-> e(p(" (set! x 1) "))).to.throw('not yet defined')
        expect(-> e(p(" (def x 1) "), { bindings : { x:2 } })).to.throw('already defined')

        expect(-> e(p(
            """
              (program
                (def x 1)
                (def x 2)
                x
              )
            """))).to.throw('already defined')


suite 'Functions -', ->

    test 'lambda-one', ->
        assert.equal e(p(" (lambda-one x (+ x 3)) "))(4), 7
        assert.deepEqual e(p(" (lambda-one x (cons '(1 2 3) x)) "))(4), [[1,2,3],4]

    test 'lambda', ->

        assert.equal e(p(" (lambda (x y) (+ (* x x) (* y y))) "))(2, 3), 13
        assert.equal e(p(" (lambda (w x y z) (+ w x y z)) "))(1, 2, 3, 4), 10

        assert.equal e(p(" (λ (x) (+ 1 x)) "))(1), 2

    test 'a small program using λ', ->

        assert.equal e(p("""
          (program
            (def sumsq
              (λ (x y)
                (+ (* x x)
                   (* y y))))
            (sumsq 10 5)
          )
        """)), 125



suite 'Recursion -', ->

    test 'recursive factorial', ->

        assert.equal e(p("""
          (begin
            (def factorial
              (λ (n)
                (if (= n 1) 1
                    (* n (factorial (- n 1))))))
            (factorial 5)
          )
        """)), 120


    test 'recursive fibonacci with helper functions', ->

        assert.equal e(p("""

          (begin

            (def sub1
              (λ (n) (- n 1)))

            (def sub2
              (λ (n) (- (sub1 n) 1)))

            (def fib
              (λ (n)
                (if (< n 2) n
                    (+ (fib (sub1 n)) (fib (sub2 n))))))

            (fib 10)

          )
        """)), 55
