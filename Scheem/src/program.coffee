

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




# Ctrl+L to type lambda characters

CodeMirror.keyMap.default['Ctrl-L'] = (cm) -> cm.replaceSelection "λ", 'end'


# Start with example program

cm_editor.setValue examples.fib.source

# Display example programs as options

for id, ex of examples
    $btn = $("<li data-example='#{ id }'><a>#{ ex.name }</a></li>")
    $('#examples').append($btn)
    $btn.click ->
        cm_editor.setValue examples[$(this).data('example')].source


# Compile program


newAlert = (type, text) ->
    $("<div class='alert alert-#{ type }'>#{ text }</div>")

showAlert = (container, $alert) ->

    $con = $(container)
    $con.children().slideUp 100, -> $(this).remove()

    $con.prepend $alert.hide()
    $alert.slideDown(100)


evaluate = (source)->

    try
        val = e p source
        showAlert '#output-area', newAlert 'success', val

    catch ex
        if ex.name is 'SyntaxError'
            exStr = "<strong>Syntax error</strong>: " + String(ex).replace("SyntaxError: ", "Expected one of:\n  ").replace(/\,/g, '\n  ')
            showAlert '#output-area', newAlert 'error', exStr

        else
            exStr = "<strong>Scheem error</strong>: " + String(ex)
            showAlert '#output-area', newAlert 'error', exStr




sub 'code-update', (msg) -> evaluate msg


# Activate Bootstrap interface enhancements

$('.dropdown-toggle').dropdown()






