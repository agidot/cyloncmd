define(function(require, exports, module) {
  "user strict";
  var oop = require("../lib/oop");
  var TextMode = require("./text").Mode;
  var CylonHighlightRules = require("./cylon_highlight_rules").CylonHighlightRules;
  var CylonCompletions = require("./cylon_completions").CylonCompletions;
  var Mode = function() {
    this.HighlightRules = CylonHighlightRules;
    this.$completer = new CylonCompletions();
  };

  oop.inherits(Mode, TextMode);

  (function() {
    this.lineCommentStart = "#";
    this.$id = "ace/mode/cylon";

    this.getNextLineIndent = function(state, line, tab) {
      var indent = this.$getIndent(line);
      var space2 = "  ";

      var tokenizedLine = this.getTokenizer().getLineTokens(line, state);
      var tokens = tokenizedLine.tokens;

      console.log(state)

      if(line.match("[ ]*\\|")) {
        indent += "| ";
      }

      if (tokens.length && tokens[tokens.length-1].type == "comment") {
        return indent;
      }

      if (state == "start") {
        if (line.match("Scenario:|Feature:|Scenario\ Outline:|Background:")) {
          indent += space2;
        } else if(line.match("(Given|Then).+(:)$|Examples:")) {
          indent += space2;
        } else if(line.match("\\*.+")) {
          indent += "* ";
        }
      }

      return indent;
    };
    this.getCompletions = function(state, session, pos, prefix){
      return this.$completer.getCompletions(state, session, pos, prefix);
    };
  }).call(Mode.prototype);

  exports.Mode = Mode;
});
