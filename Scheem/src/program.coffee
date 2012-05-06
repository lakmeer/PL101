

# Initialisation

$editor = $('#editor-area')



# Example scripts

examples = {}

$('script').filter('[type="text/x-scheem"]').each ->
    $s = $(this)
    examples[$s.attr('id')] =
        source : $s.text().replace(/^\n|\n$/g, '')
        name : $s.data('name')



# Set up evaluator

e = Interpreter.eval
p = Parser.parse



# Set up editor

cm_editor = CodeMirror( document.getElementById('editor-area'),
    mode          : 'scheem'
    theme         : 'theme'
    gutter        : yes
    lineNumbers   : yes
    matchBrackets : yes
    onChange      : debounce(500, (cm) -> pub('code-update', cm.getValue()))
)

cm_output = CodeMirror( document.getElementById('output-area'),
    theme : 'output'
    gutter : yes
    readOnly : yes
    height: 100
)



# Ctrl+L to type lambda characters

CodeMirror.keyMap.default['Ctrl-L'] = (cm) -> cm.replaceSelection "λ", 'end'


# Start with example program

cm_editor.setValue examples.default.source


# Compile program

evaluate = (source)->
    try
        val = e p source
        $('#output-area').removeClass('error')
        cm_output.setValue "Result:\n\n" + String(val)
    catch ex
        $('#output-area').addClass('error')
        if ex.name is 'SyntaxError'
            cm_output.setValue "Syntax error:\n\n" + String(ex).replace("SyntaxError: ", "Expected one of:\n  ").replace(/\,/g, '\n  ')
        else
            cm_output.setValue "Scheem error:\n\n" + String(ex)

sub 'code-update', (msg) -> evaluate msg







