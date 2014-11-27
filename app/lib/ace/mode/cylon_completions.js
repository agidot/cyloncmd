define(function(require, exports, module){
  "use strict";


  var CylonCompletions = function(){

  };
  (function(){
    this.keywords = {};
    this.keywords['page'] = [];
    this.keywords['element'] = [];
    this.keywords['keyword'] = ['Given ','When ','Then ', 'Scenario: ', 'Feature: '];
    this.getCompletions = function(state, session, pos, prefix) {
      var keys = []
      for(var key in this.keywords){
        keys = keys.concat(this.keywords[key].map(function(element){
          return{
            value : element,
            meta: key,
            score: Number.MAX_VALUE
          }
        }));
      }
      console.log(keys);
      return keys;
    };

  }).call(CylonCompletions.prototype);

  exports.CylonCompletions = CylonCompletions;

})


