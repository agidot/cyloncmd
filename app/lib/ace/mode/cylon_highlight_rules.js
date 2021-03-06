define(function(require, exports, module) {

var oop = require("../lib/oop");
var GherkinHighlightRules = require("./gherkin_highlight_rules").GherkinHighlightRules;
var stringEscape =  "\\\\(x[0-9A-Fa-f]{2}|[0-7]{3}|[\\\\abfnrtv'\"]|U[0-9A-Fa-f]{8}|u[0-9A-Fa-f]{4})";

var CylonHighlightRules = function() {
    // Get Gherkin rules
    //this.$rules = new GherkinHighlightRules().getRules();

    // need to include constant ints
    this.$rules = {
        start : [{
            token: 'constant.numeric',
            regex: "(?:(?:[1-9]\\d*)|(?:0))"
        }, {
            token : "comment",
            regex : "#.*$"
        }, {
            token : "keyword",
            regex : "Feature:|Background:|Scenario:|Scenario\ Outline:|Examples:|Given|When|Then|And|But|\\*",
        }, {
            token : "variable",
            regex : '\\[(.*?)\\]'
        }, {
            token : "string",
            regex : '\'(.*?)\''
        }, {
            token : "string",           // multi line """ string start
            regex : '"{3}',
            next : "qqstring3"
        }, {
            token : "string",           // " string
            regex : '"',
            next : "qqstring"
        }, {
            token : "keyword",
            regex : "@[A-Za-z0-9_-]+",
            next : "start"
        }, {
            token : "comment",
            regex : "<.+>"
        }, {
            token : "comment",
            regex : "\\| ",
            next : "table-item"
        }, {
            token : "comment",
            regex : "\\|$",
            next : "start"
        }],
        "qqstring3" : [ {
            token : "constant.language.escape",
            regex : stringEscape
        }, {
            token : "string", // multi line """ string end
            regex : '"{3}',
            next : "start"
        }, {
            defaultToken : "string"
        }],
        "qqstring" : [{
            token : "constant.language.escape",
            regex : stringEscape
        }, {
            token : "string",
            regex : "\\\\$",
            next  : "qqstring"
        }, {
            token : "string",
            regex : '"|$',
            next  : "start"
        }, {
            defaultToken: "string"
        }],
        "table-item" : [{
            token : "string",
            regex : "[A-Za-z0-9 ]*",
            next  : "start"
        }],
    };

    //this.addRules(newRules, '');
}

oop.inherits(CylonHighlightRules, GherkinHighlightRules);

exports.CylonHighlightRules = CylonHighlightRules;
});
