#baseUrl: window.location.protocol + "//" + window.location.host + window.location.pathname.split("/").slice(0, -1).join("/")
require.config(
  paths:
    ace:'../bower_components/ace/lib/ace'
    text : "../bower_components/requirejs-text/text"
)
require(["ace/ace", 'ace/ext/language_tools', "text!../snippets/cylon.snippets"], (ace,langTools,cylonSnippets)->
  editor = ace.edit("editor")
  snippetManager = ace.require("ace/snippets").snippetManager
  editor.setTheme("ace/theme/solarized_dark")
  editor.getSession().setMode("ace/mode/gherkin")
  editor.setOptions
  enableBasicAutocompletion: true
  enableSnippets: true
  enableLiveAutocompletion: true
#cylonSnippets = snippetManager.parseSnippetFile(cylonSnippets)
#snippetManager.register(cylonSnippets, 'gherkin')

  readFile = (input) ->
    if input.files and input.files[0]
      reader = new FileReader()
      reader.onload = (e) ->
        editor.insert(e.target.result)
        return

      reader.readAsText input.files[0]
    return

  $('#import-file-input').click ->
    $(this).val('')

  $('#import-file-input').change ->
    return  if $(this).val() is ''
    readFile this
    return

  $('#export-button').click ->
    text = editor.getSession().getValue();
    blob = new Blob([text],
      type: 'text/plain;charset=utf-8'
    )
    saveAs blob, 'feature-file.feature'
    return

  $('#yaml-toggle-button').click(e) ->

)