
# MUS to NOTE compiler (final extended version)

noteToMidi = (note) ->

    notesMap = [ 'C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B' ]

    noteChar = note.replace(/\d/g, '')
    octave   = note.replace(/\D/g, '')

    return 12 + 12 * octave + notesMap.indexOf(noteChar.toUpperCase())


compile = (musSource) ->

    mySong = []

    # Helper function to abstract difference between 'note' and 'rest',
    # also prevents mutating original data

    extend = (base, aug) ->
        newObj = {}
        newObj[k] = v for k, v of base
        newObj[k] = v for k, v of aug
        newObj

    # Recursively compile mus into note

    comp = (expr, time, song) ->

        switch expr.tag

            when 'repeat'
                for i in [0...expr.count]
                    time = comp expr.section, time, song
                time

            when 'seq'
                comp(expr.right, comp(expr.left, time, song), song)

            when 'par'
                Math.max comp(expr.left, time, song), comp(expr.right, time, song)

            when 'note'
                song.push extend expr, { start : time, pitch : noteToMidi(expr.pitch) }
                time + expr.dur

            when 'rest'
                song.push extend expr, { start : time }
                time + expr.dur

            else
                throw "MusSyntaxError: unknown token " + expr.tag
                time

    comp(musSource, 0, mySong)

    return mySong


module.exports = compile
