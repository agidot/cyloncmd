define(function(require, exports, module) {

var oop = require("../lib/oop");
var GherkinHighlightRules = require("./gherkin_highlight_rules").GherkinHighlightRules;
var stringEscape =  "\\\\(x[0-9A-Fa-f]{2}|[0-7]{3}|[\\\\abfnrtv'\"]|U[0-9A-Fa-f]{8}|u[0-9A-Fa-f]{4})";

var CylonHighlightRules = function() {
    // Get Gherkin rules
    this.$rules = new GherkinHighlightRules().getRules();

	// need to include constant ints
    var newRules = {
        start : [{
            token: 'comment',
            regex : 'element'
        }]
    };

    this.addRules(newRules, "new-");
}

oop.inherits(CylonHighlightRules, GherkinHighlightRules);

exports.CylonHighlightRules = CylonHighlightRules;
});