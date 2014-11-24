(function() {
  require.config({
    paths: {
      ace: "../lib/ace",
      text: "../lib/requirejs/text"
    }
  });

  require(["ace/ace", "ace/ext/language_tools"], function(ace, langTools) {
    var Page, activatePage, addElement, addPage, bg, clearPages, deactivatePage, document, editor, headerHeight, pageCount, pages, processIncomingMessage, readFile, stripTrailingSlash, tobeSent;
    editor = ace.edit("editor");
    editor.setTheme("ace/theme/twilight");
    editor.getSession().setMode("ace/mode/cylon");
    document = editor.getSession().getDocument();
    editor.setOptions({
      enableBasicAutocompletion: true,
      enableSnippets: true,
      enableLiveAutocompletion: true
    });
    langTools.snippetCompleter.getDocTooltip = false;
    console.log('editor');
    console.log(editor);
    stripTrailingSlash = function(str) {
      if (str.substr(-1) === '/') {
        return str.substr(0, str.length - 1);
      }
      return str;
    };
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
    $("#yaml-toggle-button").click(function() {
      $(".editor-panel").toggleClass('two-view');
    });
    $("#import-file-input").click(function() {
      $(this).val("");
    });
    $("#import-file-input").change(function() {
      if ($(this).val() === "") {
        return;
      }
      readFile(this);
    });
    $("#export-button").click(function() {
      var blob, text;
      text = editor.getSession().getValue();
      blob = new Blob([text], {
        type: "text/plain;charset=utf-8"
      });
      saveAs(blob, "feature-file.feature");
    });
    chrome.runtime.onMessage.addListener(function(request, sender, sendResponse) {
      console.log((sender.tab ? 'from a content script:' + sender.tab.url : 'from the extension'));
      processIncomingMessage(request, sender, sendResponse);
    });
    Page = function(tabId, url, name) {
      this.tabId = tabId;
      this.elements = [];
      this.name = name;
      this.url = url;
      this.active = false;
      this.elementCount = 0;
    };
    pages = [];
    pageCount = 0;
    bg = chrome.extension.getBackgroundPage();
    tobeSent = {};
    headerHeight = 100;
    addElement = function(pageIndex, element) {
      var elements, html, page, pageURL;
      page = pages[pageIndex];
      element.elementId = '' + pageIndex + '-' + page.elements.length;
      page.elements.push(element);
      console.log(element.elementId);
      pageURL = page.url;
      elements = page.elements;
      if (element.comment === void 0) {
        element.comment = '';
      }
      html = '';
      html += '<button type="button" class="btn btn-primary elementBtn" data-toggle="modal" data-element-id="' + element.elementId + '" data-target="#elementModal">' + element.name + '</button>';
      console.log(html);
      return $('.page-object').eq(pageIndex).append(html);
    };
    deactivatePage = function(index) {
      return pages[index].active = false;
    };
    activatePage = function(index) {
      return pages[index].active = true;
    };
    addPage = function(tabId, pageURL, pageTitle) {
      var html, page;
      pageURL = stripTrailingSlash(pageURL);
      pageCount++;
      page = new Page(tabId, pageURL, pageTitle);
      pages.push(page);
      html = '';
      console.log(pages.length - 1);
      html += '<div class="page-object" id="page-object-' + (pages.length - 1) + '"> <h4 class = "page-number"> page #' + pages.length + '</h4></div>';
      console.log(html);
      return $('#yaml-editor-panel').append(html);
    };
    processIncomingMessage = function(request, sender, sendResponse) {
      var element, elementsDom, haveTabId, i, index, j, k, page, senderURL;
      console.log(sender.tab.url);
      senderURL = stripTrailingSlash(sender.tab.url);
      if (request.msg === 'addElement') {
        sendResponse({
          msg: 'success'
        });
        element = request.element;
        console.log(element);
        haveTabId = false;
        console.log(pages);
        for (index in pages) {
          console.log('kak');
          console.log(pages[index].url);
          console.log(senderURL);
          if (pages[index].tabId === sender.tab.id && pages[index].url === senderURL) {
            console.log(index);
            addElement(index, element);
            haveTabId = true;
          }
        }
        if (!haveTabId) {
          console.log(sender.tab.id);
          console.log(senderURL);
          console.log(sender.tab.title);
          page = addPage(sender.tab.id, senderURL, sender.tab.title);
          addElement(pages.length - 1, element);
        }
      } else if (request.msg === 'newPage') {
        sendResponse({
          msg: 'startExtension'
        });
        if (tobeSent[sender.tab.id]) {
          chrome.tabs.sendMessage(sender.tab.id, {
            msg: 'findXpaths',
            Xpaths: tobeSent[sender.tab.id]
          });
          delete tobeSent[sender.tab.id];
          return;
        }
        for (k in pages) {
          if (pages[k].active) {
            if (pages[k].tabId === sender.tab.id && pages[k].url !== senderURL) {
              deactivatePage(k);
            }
          }
        }
      } else if (request.msg === 'checkXpath') {
        console.log('checkXpath ' + request.Xpath + ' found = ' + request.found);
        for (i in pages) {
          if (pages[i].tabId === sender.tab.id && pages[i].url === senderURL) {
            j = 0;
            while (j < pages[i].elements.length) {
              if (pages[i].elements[j].Xpath === request.Xpath) {
                elementsDom = $('.page-object').eq(i).find('.element-no');
                if (request.found) {
                  elementsDom.eq(j).css('color', 'green');
                } else {
                  elementsDom.eq(j).css('color', 'red');
                }
              }
              j++;
            }
          }
        }
      }
    };
    clearPages = function(callback, arg) {
      pages = [];
      pageCount = 0;
      tobeSent = {};
      chrome.tabs.query({}, function(tabs) {
        var i;
        for (i in tabs) {
          chrome.tabs.sendMessage(tabs[i].id, {
            msg: 'removeAllStyles'
          });
        }
        $('#container').html('');
        if (callback) {
          callback(arg);
        }
      });
    };
    chrome.tabs.onRemoved.addListener(function(tabId, removeInfo) {
      var i;
      for (i in pages) {
        if (pages[i].active) {
          if (pages[i].tabId === tabId) {
            deactivatePage(i);
          }
        }
      }
    });
    $(function() {
      $('#clear-all-button').click(function(e) {
        clearPages();
      });
      $('.elements li').click(function(e) {
        $('.elements li').removeClass('active');
        $(this).addClass('active');
      });
      console.log('awgweg');
      $('#elementModal').on('show.bs.modal', function(event) {
        var button, element, elementId, modal, pageIndex;
        console.log('awegawhar');
        button = $(event.relatedTarget);
        console.log('efwegewgg');
        elementId = button.data('element-id');
        pageIndex = parseInt(elementId.split('-')[0]);
        elementId = parseInt(elementId.split('-')[1]);
        console.log('pageIndex ' + pageIndex + ' elementId ' + elementId);
        element = pages[pageIndex].elements[elementId];
        modal = $(this);
        console.log(modal);
        modal.find('.modal-title').text(element.Xpath);
        modal.find('.modal-body input').val(element.name);
        modal.find('.modal-body textarea').val(element.comment);
        modal.find('.modal-footer .btn-primary').unbind('click');
        modal.find('.modal-footer .btn-primary').click(function() {
          element.name = modal.find('.modal-body input').val();
          element.comment = modal.find('.modal-body textarea').val();
          console.log('' + element.name);
          button.text(element.name);
          modal.modal('hide');
        });
      });
    });
  });

}).call(this);
