

# Helpers

window.debounce = (delay, fn) ->
    timer = 0
    (args...) ->
        clearTimeout timer
        timer = setTimeout(
            -> fn.apply this, args
            delay
        )


handlers = {}

window.sub = (channel, handler) ->
        if !handlers[channel]? then handlers[channel] = []
        handlers[channel].push handler

window.pub = (channel, message) ->
        unless !handlers[channel]?
            handle message for handle in handlers[channel]

