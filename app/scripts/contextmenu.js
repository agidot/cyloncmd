(function() {
  define([], function() {
    var ContextMenu;
    ContextMenu = (function() {
      var self;

      self = ContextMenu;

      function ContextMenu(editor) {
        self.editor = editor;
      }

      ContextMenu.prototype.removeAll = function() {
        return chrome.contextMenus.removeAll();
      };

      ContextMenu.prototype.create = function(value, element1, element2) {
        var title;
        if (value == null) {
          value = "...";
        }
        if (element1 == null) {
          element1 = "...";
        }
        if (element2 == null) {
          element2 = "...";
        }
        chrome.contextMenus.create({
          type: "normal",
          title: "Given...",
          contexts: ["all"],
          id: "GIVEN"
        });
        chrome.contextMenus.create({
          type: "normal",
          title: "When...",
          contexts: ["all"],
          id: "WHEN"
        });
        chrome.contextMenus.create({
          type: "normal",
          title: "Then...",
          contexts: ["all"],
          id: "THEN"
        });
        chrome.contextMenus.create({
          type: "normal",
          title: 'dsfsd',
          id: "WHEN_ENTER_TO",
          parentId: "WHEN",
          contexts: ["all"]
        });
        console.log(value, element1);
        title = "user enters '" + value + "' to the [" + element1 + "]";
        console.log(title);
        return chrome.contextMenus.update("WHEN_ENTER_TO", {
          'title': title,
          onclick: function() {
            self.editor.navigateLineStart();
            self.editor.splitLine();
            if (value === "...") {
              return self.editor.insert("When user enters '${1:value}' to the [${2:element}]");
            } else {
              return self.editor.insert(title);
            }
          }
        }, function() {
          return console.log('df');
        });
      };

      return ContextMenu;

    })();

    /*
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
     */
    return ContextMenu;
  });

}).call(this);
