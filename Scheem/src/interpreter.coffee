

#
# Interpreter helper functions
#



# Debugging output flag

DEBUG = off



#
# Environment Helpers
#

lookup = (env, name) ->

    if !env? then return null

    for v of env.vars
        if v is name then return env.vars[name]

    return lookup env.outer, name


store = (env, name, value) ->

    if lookup(env, name) isnt null
        throw new Error "variable #{ name } already defined"

    env.vars[name] = value


update = (env, name, value) ->

    if lookup(env, name) is null
        throw new Error "variable #{ name } not yet defined"

    for v of env.vars
        if v is name then env.vars[name] = value


new_binding = (env, name, value) ->

    env.outer = { vars : env.vars, outer : env.outer }
    env.vars = {}
    env.vars[name] = value


#
# Create default environment (builtins etc)
#

defEnv = { vars : {}, outer : null }



#
# Eval function return result of evaluating parse tree of Scheem expression
#

e = (expr, env = { vars : {} }) ->

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


        # Numeric operations

        when '+'
            e(expr[1], env) + e(expr[2], env)

        when '-'
            e(expr[1], env) - e(expr[2], env)

        when '*'
            e(expr[1], env) * e(expr[2], env)

        when '/'
            e(expr[1], env) / e(expr[2], env)


        # Meta operations

        when 'quote'
            expr[1]


        # List operations

        when 'cons'
            [e expr[1], env].concat e expr[2], env

        when 'car'
            e(expr[1])[0]

        when 'cdr'
            list = e(expr[1], env)
            list.shift()
            list


        # Conditionals

        when 'if'
            if e(expr[1], env) is '#t'
                e expr[2], env
            else
                e expr[3], env

        when '='
            if e(expr[1], env) is e(expr[2], env) then '#t' else '#f'

        when '>'
            if e(expr[1], env) >  e(expr[2], env) then '#t' else '#f'

        when '<'
            if e(expr[1], env) <  e(expr[2], env) then '#t' else '#f'


        # Unrecognised operator

        else
            throw new Error "Unknown operator: #{ expr[0] }"
            0



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

