(function() {
  require.config({
    paths: {
      ace: '../bower_components/ace/lib/ace',
      text: "../bower_components/requirejs-text/text"
    }
  });

  require(["ace/ace", 'ace/ext/language_tools', "text!../snippets/cylon.snippets"], function(ace, langTools, cylonSnippets) {
    var editor, readFile, snippetManager;
    editor = ace.edit("editor");
    snippetManager = ace.require("ace/snippets").snippetManager;
    editor.setTheme("ace/theme/solarized_dark");
    editor.getSession().setMode("ace/mode/gherkin");
    editor.setOptions;
    ({
      enableBasicAutocompletion: true,
      enableSnippets: true,
      enableLiveAutocompletion: true
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
    $('#export-button').click(function() {
      var blob, text;
      text = editor.getSession().getValue();
      blob = new Blob([text], {
        type: 'text/plain;charset=utf-8'
      });
      saveAs(blob, 'feature-file.feature');
    });
    return $('#yaml-toggle-button').click(e)(function() {});
  });

}).call(this);
