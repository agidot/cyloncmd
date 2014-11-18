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
  cylonSnippets = snippetManager.parseSnippetFile(cylonSnippets)
  snippetManager.register(cylonSnippets, 'gherkin')
)
