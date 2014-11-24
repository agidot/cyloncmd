(function() {
  window.Element = (function() {
    function Element(element, Xpath) {
      this.element = element;
      if (Xpath) {
        this.Xpath = Xpath;
      } else {
        this.Xpath = this.getElementXPath(element);
      }
      this.name = this.getElementDefaultName(element);
    }

    Element.prototype.getElementDefaultName = function(element) {
      return $(element).text().replace(/^\s+|\s+$/g, '').substring(0, 50);
    };

    Element.prototype.getElementTreeXPath = function(element) {
      var index, pathIndex, paths, sibling, tagName;
      paths = [];
      while (element && element.nodeType === 1) {
        index = 0;
        sibling = element.previousSibling;
        while (sibling) {
          if (sibling.nodeType === Node.DOCUMENT_TYPE_NODE) {
            break;
          }
          if (sibling.nodeName === element.nodeName) {
            ++index;
          }
          sibling = sibling.previousSibling;
        }
        tagName = element.nodeName.toLowerCase();
        pathIndex = (index ? '[' + (index + 1) + ']' : '');
        paths.splice(0, 0, tagName + pathIndex);
        element = element.parentNode;
      }
      if (paths.length) {
        return '/' + paths.join('/');
      } else {
        return null;
      }
    };

    Element.prototype.getElementXPath = function(element) {
      if (element && element.id) {
        return '//*[@id=\"' + element.id + '\"]';
      } else {
        return this.getElementTreeXPath(element);
      }
    };

    return Element;

  })();

}).call(this);
