(function() {
  require.config({
    paths: {
      ace: '../lib/ace',
      text: '../lib/requirejs/text'
    }
  });

  require(["ace/ace", 'ace/ext/language_tools', "text!../snippets/cylon.snippets"], function(ace, langTools, cylonSnippets) {
    var document, editor, readFile, snippetManager;
    editor = ace.edit("editor");
    snippetManager = ace.require("ace/snippets").snippetManager;
    editor.setTheme("ace/theme/solarized_dark");
    editor.getSession().setMode("ace/mode/gherkin");
    document = editor.getSession().getDocument();
    editor.setOptions({
      enableBasicAutocompletion: true,
      enableSnippets: true,
      enableLiveAutocompletion: true
    });
    cylonSnippets = snippetManager.parseSnippetFile(cylonSnippets);
    snippetManager.register(cylonSnippets, 'gherkin');
    chrome.contextMenus.create({
      type: 'normal',
      title: 'Given...',
      contexts: ['all'],
      id: 'GIVEN'
    });
    chrome.contextMenus.create({
      type: 'normal',
      title: 'When...',
      id: 'WHEN'
    });
    chrome.contextMenus.create({
      type: 'normal',
      title: 'Then...',
      id: 'THEN'
    });
    chrome.contextMenus.create({
      type: 'normal',
      title: 'user enters \'...\' to the [...]',
      id: 'WHEN_ENTER_TO',
      parentId: 'WHEN',
      onclick: function() {
        return editor.insert('When user enters \'${1:value}\' to the [${2:element}]');
      }
    });
    chrome.contextMenus.create({
      type: 'normal',
      title: 'user enters date \'...\' to the [...]',
      id: 'WHEN_ENTER_DATE',
      parentId: 'WHEN'
    });
    chrome.contextMenus.create({
      type: 'normal',
      title: 'user clears value on the [...]',
      id: 'WHEN_CLEAR_VALUE',
      parentId: 'WHEN'
    });
    chrome.contextMenus.create({
      type: 'normal',
      title: 'user clicks the [...]',
      id: 'WHEN_CLICK',
      parentId: 'WHEN'
    });
    chrome.contextMenus.create({
      type: 'normal',
      title: 'user unchecks the [...]',
      id: 'WHEN_UNCHECK',
      parentId: 'WHEN'
    });
    chrome.contextMenus.create({
      type: 'normal',
      title: 'user moves mouse over the [...]',
      id: 'WHEN_MOVE_MOUSE_OVER',
      parentId: 'WHEN'
    });
    chrome.contextMenus.create({
      type: 'normal',
      title: 'user uploads file \'...\' to the [...]',
      id: 'WHEN_UPLOAD_FILE',
      parentId: 'WHEN'
    });
    readFile = function(input) {
      var reader;
      if (input.files && input.files[0]) {
        reader = new FileReader();
        reader.onload = function(e) {
          editor.insert(e.target.result);
        };
        reader.readAsText(input.files[0]);
      }
    };
    $('#import-file-input').click(function() {
      return $(this).val('');
    });
    $('#import-file-input').change(function() {
      if ($(this).val() === '') {
        return;
      }
      readFile(this);
    });
    return $('#export-button').click(function() {
      var blob, text;
      text = editor.getSession().getValue();
      blob = new Blob([text], {
        type: 'text/plain;charset=utf-8'
      });
      saveAs(blob, 'feature-file.feature');
    });
  });

}).call(this);
