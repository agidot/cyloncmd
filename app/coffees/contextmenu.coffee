define [] , ->
  class ContextMenu
    self = this
    constructor: (editor) ->
      self.editor = editor

    removeAll: ->
      chrome.contextMenus.removeAll()

    create:(value = "...", element1 = "...", element2 ="...") ->
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
        title: 'dsfsd'
        id: "WHEN_ENTER_TO"
        parentId: "WHEN"
        contexts: ["all"]
      console.log value , element1
      title = "user enters '" + value + "' to the [" +element1 + "]"
      console.log title
      chrome.contextMenus.update "WHEN_ENTER_TO",
        'title': title,
        onclick: ->
          self.editor.navigateLineStart()
          self.editor.splitLine()
          if value == "..."
            self.editor.insert "When user enters '${1:value}' to the [${2:element}]"
          else
            self.editor.insert title
        ->
          console.log 'df'
  ###
        type: "normal"
        title: "user enters '" + value +"' to the ["+element1+"]"
        parentId: "WHEN"
        contexts: ["all"]
        onclick: ->
          self.editor.navigateLineStart()
          self.editor.splitLine()
          if value == "..."
            self.editor.insert "When user enters '${1:value}' to the [${2:element}]"
          else
            self.editor.insert  "When user enters '" + value +"' to the ["+element1+"]"

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
  ###
  return ContextMenu
