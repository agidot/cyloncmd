require.config paths:
  ace: "../lib/ace"
  text: "../lib/requirejs/text"

require [
  "ace/ace"
  "ace/ext/language_tools"
], (ace, langTools) ->
  editor = ace.edit("editor")
  editor.setTheme "ace/theme/twilight"
  editor.getSession().setMode "ace/mode/cylon"
  document = editor.getSession().getDocument()
  editor.setOptions
    enableBasicAutocompletion: true
    enableSnippets: true
    enableLiveAutocompletion: true
  langTools.snippetCompleter.getDocTooltip = false;

  chrome.contextMenus.create
    type: "normal"
    title: "Given..."
    contexts: ["all"]
    id: "GIVEN"

  chrome.contextMenus.create
    type: "normal"
    title: "When..."
    contexts: ["all"]
    id: "WHEN"

  chrome.contextMenus.create
    type: "normal"
    title: "Then..."
    contexts: ["all"]
    id: "THEN"

  chrome.contextMenus.create
    type: "normal"
    title: "user enters '...' to the [...]"
    id: "WHEN_ENTER_TO"
    parentId: "WHEN"
    contexts: ["all"]
    onclick: ->
      editor.navigateLineStart()
      editor.splitLine()
      editor.insert "When user enters '${1:value}' to the [${2:element}]"

  chrome.contextMenus.create
    type: "normal"
    title: "user enters date '...' to the [...]"
    id: "WHEN_ENTER_DATE"
    contexts: ["all"]
    parentId: "WHEN"

  chrome.contextMenus.create
    type: "normal"
    title: "user clears value on the [...]"
    id: "WHEN_CLEAR_VALUE"
    contexts: ["all"]
    parentId: "WHEN"

  chrome.contextMenus.create
    type: "normal"
    title: "user clicks the [...]"
    id: "WHEN_CLICK"
    contexts: ["all"]
    parentId: "WHEN"

  chrome.contextMenus.create
    type: "normal"
    title: "user unchecks the [...]"
    id: "WHEN_UNCHECK"
    contexts: ["all"]
    parentId: "WHEN"

  chrome.contextMenus.create
    type: "normal"
    title: "user moves mouse over the [...]"
    id: "WHEN_MOVE_MOUSE_OVER"
    contexts: ["all"]
    parentId: "WHEN"

  chrome.contextMenus.create
    type: "normal"
    title: "user uploads file '...' to the [...]"
    id: "WHEN_UPLOAD_FILE"
    contexts: ["all"]
    parentId: "WHEN"

  readFile = (input) ->
    if input.files and input.files[0]
      reader = new FileReader()
      reader.onload = (e) ->
        editor.insert e.target.result
        return

      reader.readAsText input.files[0]
    return

  $("#yaml-toggle-button").click ->
    $(".editor-panel").toggleClass('two-view')
    return

  $("#import-file-input").click ->
    $(this).val ""
    return

  $("#import-file-input").change ->
    return  if $(this).val() is ""
    readFile this
    return

  $("#export-button").click ->
    text = editor.getSession().getValue()
    blob = new Blob([text],
      type: "text/plain;charset=utf-8"
    )
    saveAs blob, "feature-file.feature"
    return

  return