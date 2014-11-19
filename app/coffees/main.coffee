#baseUrl: window.location.protocol + "//" + window.location.host + window.location.pathname.split("/").slice(0, -1).join("/")
require.config(
  paths:
    ace: '../lib/ace',
    text: '../lib/requirejs/text'
)
require(["ace/ace", 'ace/ext/language_tools', "text!../snippets/cylon.snippets"], (ace,langTools,cylonSnippets)->
  editor = ace.edit("editor")
  snippetManager = ace.require("ace/snippets").snippetManager
  editor.setTheme("ace/theme/solarized_dark")
  editor.getSession().setMode("ace/mode/gherkin")
  document = editor.getSession().getDocument()
  editor.setOptions
    enableBasicAutocompletion: true
    enableSnippets: true
    enableLiveAutocompletion: true
  cylonSnippets = snippetManager.parseSnippetFile(cylonSnippets)
  snippetManager.register(cylonSnippets, 'gherkin')

  chrome.contextMenus.create(
    type : 'normal'
    title : 'Given...'
    contexts : ['all']
    id : 'GIVEN'
  )

  chrome.contextMenus.create(
    type : 'normal'
    title : 'When...'
    id : 'WHEN'
  )
  chrome.contextMenus.create(
    type : 'normal'
    title : 'Then...'
    id : 'THEN'
  )
  chrome.contextMenus.create(
    type : 'normal'
    title : 'user enters \'...\' to the [...]'
    id : 'WHEN_ENTER_TO'
    parentId: 'WHEN'
    onclick : ->
      editor.insert 'When user enters \'${1:value}\' to the [${2:element}]'
  )
  chrome.contextMenus.create(
    type : 'normal'
    title : 'user enters date \'...\' to the [...]'
    id : 'WHEN_ENTER_DATE'
    parentId: 'WHEN'
  )
  chrome.contextMenus.create(
    type : 'normal'
    title : 'user clears value on the [...]'
    id : 'WHEN_CLEAR_VALUE'
    parentId: 'WHEN'
  )
  chrome.contextMenus.create(
    type : 'normal'
    title : 'user clicks the [...]'
    id : 'WHEN_CLICK'
    parentId: 'WHEN'
  )
  chrome.contextMenus.create(
    type : 'normal'
    title : 'user unchecks the [...]'
    id : 'WHEN_UNCHECK'
    parentId: 'WHEN'
  )
  chrome.contextMenus.create(
    type : 'normal'
    title : 'user moves mouse over the [...]'
    id : 'WHEN_MOVE_MOUSE_OVER'
    parentId: 'WHEN'
  )
  chrome.contextMenus.create(
    type : 'normal'
    title : 'user uploads file \'...\' to the [...]'
    id : 'WHEN_UPLOAD_FILE'
    parentId: 'WHEN'
  )

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
)
