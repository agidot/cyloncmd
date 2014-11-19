require.config({
    paths: {
      ace: '../bower_components/ace/lib/ace/'
    }
});

define(['ace/mode/gherkin_highlight_rules','exports','ace/mode/text'],function(highlightRules, exports,textMode) {

    var oop = require("ace/lib/oop");
    // defines the parent mode
    var TextMode = textMode.Mode;
    var GherkinHighlightRules = highlightRules.GherkinHighlightRules;

    var Mode = function() {
        this.HighlightRules = GherkinHighlightRules;
    };
    
    oop.inherits(Mode, TextMode);

    (function() {
        // configure comment start/end characters
        this.lineCommentStart = "#";
        this.$id = "cylon/modes/cylon";
        
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
    }).call(Mode.prototype);

    exports.Mode = Mode;
});