

#
# Interpreter helper functions
#

isEmpty = (obj) -> return !obj? or obj.length < 1

contains = (list, target) ->
    for k, v of list
        if k is target then return yes
    return no

bool = (test) -> if test then '#t' else '#f'



# Debugging output flag

DEBUG = off



#
# Initial Environment
#

initEnv =

    'add'      : (args...) -> args.reduce (r, a) -> r + a
    'subtract' : (args...) -> args.reduce (r, a) -> r - a
    'multiply' : (args...) -> args.reduce (r, a) -> r * a
    'divide'   : (args...) -> args.reduce (r, a) -> r / a

    'cons' : (l, r) -> [ l ].concat r
    'car'  : (list) -> list[0]
    'cdr'  : (list) -> list.shift(); list

    'eq' : (a, b) -> bool a is b
    'gt' : (a, b) -> bool a >  b
    'lt' : (a, b) -> bool a <  b

    'neq' : (a, b) -> bool a isnt b
    'gte' : (a, b) -> bool a >= b
    'lte' : (a, b) -> bool a <= b



# Aliases

initEnv['+']  = initEnv.add
initEnv['-']  = initEnv.subtract
initEnv['*']  = initEnv.multiply
initEnv['/']  = initEnv.divide

initEnv['=']  = initEnv.eq
initEnv['>']  = initEnv.gt
initEnv['<']  = initEnv.lt

initEnv['!='] = initEnv.neq
initEnv['>='] = initEnv.gte
initEnv['<='] = initEnv.lte








#
# Environment Helpers
#

lookup = (env, name) ->

    if isEmpty(env)
        if contains initEnv, name
            return initEnv[name]
        else
            return null

    if contains env.bindings, name
        return env.bindings[name]

    return lookup env.outer, name


store = (env, name, value) ->

    if lookup(env, name) isnt null
        throw new Error "variable #{ name } already defined"

    env.bindings[name] = value


update = (env, name, value) ->

    if lookup(env, name) is null
        throw new Error "variable #{ name } not yet defined"

    if contains env.bindings, name
        return env.bindings[name] = value

    return update env.outer, name, value


new_binding = (env, name, value) ->

    env.outer = { bindings : env.bindings, outer : env.outer }
    env.bindings = {}
    env.bindings[name] = value


#
# Create default environment (builtins etc)
#

defEnv = { bindings : {}, outer : {} }



#
# Eval function return result of evaluating parse tree of Scheem expression
#

e = (expr, env = { bindings : {} }) ->

    if DEBUG is on then console.log "\r>> expr =", expr

    # Numbers evaluate to themselves
    if typeof expr is 'number' then return expr

    # Dereference variables
    if typeof expr is 'string'
        return lookup env, expr


    # Look at head of list for operation
    switch expr[0]

        # Program structure

        when 'begin', 'program'
            stepValues = for i in [1...expr.length]
                e expr[i], env
            stepValues[stepValues.length-1]


        # Environment

        when 'define', 'def'
            store env, expr[1], e expr[2], env
            expr[2]

        when 'set!'
            update env, expr[1], e expr[2], env
            expr[2]

        when 'let-one'
            localScope = { bindings : {}, outer : env }
            localScope.bindings[expr[1]] = e(expr[2], env)
            e(expr[3], localScope)


        # Meta operations

        when 'quote'
            expr[1]


        # Conditionals

        when 'if'
            if e(expr[1], env) is '#t'
                e expr[2], env
            else
                e expr[3], env


        # Functions

        when 'lambda-one'
            (arg) ->
                captureEnv = { bindings : {}, outer : env }
                captureEnv.bindings[expr[1]] = arg
                e(expr[2], captureEnv)


        when 'lambda', 'λ'
            (args...) ->
                captureEnv = { bindings : {}, outer : env }
                for lvar, ix in expr[1]
                    captureEnv.bindings[lvar] = args[ix]
                e(expr[2], captureEnv)


        # Unrecognised operator

        else
            fn = e(expr[0], env)
            if fn is null then throw new Error "Unknown operator: #{ expr[0] }"
            args = expr.map (subexpr) -> e(subexpr, env)
            args.shift()
            fn.apply null, args




# Sneak-peek function

getEnv = (expr, env={}) ->
    storeEnv = env
    e(expr, storeEnv)
    storeEnv



# Multi-environment Export

if module?
    module.exports = e
    module.exports.getEnv = getEnv

else
    window.Interpreter =
        eval : e
        peek : getEnv

