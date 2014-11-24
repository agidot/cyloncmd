require.config paths:
  ace: "../lib/ace"
  text: "../lib/requirejs/text"

require [
  "ace/ace"
  "ace/ext/language_tools"
], (ace, langTools) ->
  editor = ace.edit("gherkin-editor")
  editor.setTheme "ace/theme/twilight"
  editor.getSession().setMode "ace/mode/cylon"
  document = editor.getSession().getDocument()
  editor.setOptions
    enableBasicAutocompletion: true
    enableSnippets: true
    enableLiveAutocompletion: true
  langTools.snippetCompleter.getDocTooltip = false;
  console.log 'editor'
  console.log editor

  stripTrailingSlash = (str) ->
    return str.substr(0, str.length - 1)  if str.substr(-1) is '/'
    str
  readFile = (input) ->
    if input.files and input.files[0]
      reader = new FileReader()
      reader.onload = (e) ->
        editor.insert e.target.result
        return

      reader.readAsText input.files[0]
    return

  $("#yaml-toggle-button").click ->
    $(this).toggleClass('active')
    $(".editor-panel").toggleClass('two-view')
    return

  $("#import-file-input").click ->
    $(this).val ""
    return

  $("#import-file-input").change ->
    return  if $(this).val() is ""
    readFile this
    return

  $("#export-button").click ->
    text = editor.getSession().getValue()
    blob = new Blob([text],
      type: "text/plain;charset=utf-8"
    )
    saveAs blob, "feature-file.feature"
    return

  chrome.runtime.onMessage.addListener (request, sender, sendResponse) ->
    console.log (if sender.tab then 'from a content script:' + sender.tab.url else 'from the extension')
    processIncomingMessage request, sender, sendResponse
    return
      

  Page = (tabId, url, name) ->
    @tabId = tabId
    @elements = []
    @name = name
    @url = url
    @active = false
    @elementCount = 0
    return

  pages = []
  pageCount = 0
  bg = chrome.extension.getBackgroundPage()
  tobeSent = {}
  headerHeight = 100

  addElement = (pageIndex, element) ->
    page = pages[pageIndex]
    element.elementId = '' + pageIndex + '-' + page.elements.length
    page.elements.push element
    console.log element.elementId

    pageURL = page.url
    elements = page.elements
    if element.comment is undefined
      element.comment = ''
    html = ''

    html += '<li class="element-item">
              <div class="btn-group">
                <button type="button" class="element element-text-button btn btn-primary elementBtn" title="' + element.name + '" data-toggle="modal" data-target="#elementModal" data-element-id="'+ element.elementId + '">
                  <span class="element-text">' + element.name + '</span>
                </button><button type="button" class="element element-control">
                  <i class="fa fa-long-arrow-up"></i>
                </button><button type="button" class="element element-control remove-element-button">
                  <i class="fa fa-remove"></i>
                </button>
              </div>
            </li>';

    console.log html
    pageElement =  $('.page-object').eq(pageIndex)
    pageElement.find('.elements').append html
    elementDom = pageElement.find('.element-item').eq(elements.length-1)
    elementDom.find('.element-text-button').mouseenter((e)->
      chrome.tabs.sendMessage page.tabId,
        msg: 'changeStyleAtXpath'
        Xpath: element.Xpath
        url: pageURL
    ).mouseleave (e)->
        chrome.tabs.sendMessage page.tabId,
          msg: 'recoverStyleAtXpath'
          Xpath: element.Xpath
          url: pageURL
    elementDom.find('.remove-element-button').click (e) ->
      chrome.tabs.sendMessage page.tabId,
        msg: 'removeStyleAtXpath'
        Xpath: element.Xpath
        url: pageURL
      elements.splice pageIndex, 1
      elementDom.remove()

  deactivatePage = (index) ->
    pages[index].active = false
  activatePage = (index) ->
    pages[index].active = true
  addPage = (tabId, pageURL, pageTitle) ->
    pageURL = stripTrailingSlash(pageURL)
    pageCount++
    page = new Page(tabId, pageURL, pageTitle)
    pages.push page
    html = ''
    console.log pages.length-1

    html += '<div class="panel-group page-object" id="page-object-' + (pages.length-1) + '">
              <div class="panel panel-default">
                <div class="panel-heading" role="tab" id="headingOne">
                  <div class="panel-title">
                    <a data-toggle="collapse" class="page-number" href="#elements-' + (pages.length-1) + '">
                      #' + pages.length + ' Page Name
                    </a>

                    <a href="#" class="pull-right remove-page-button">
                      <i class="fa fa-close remove-button"></i>
                    </a>
                  </div>
                </div>
                <div id="elements-' + (pages.length-1) + '" class="panel-collapse collapse in">
                    <div class="panel-body">
                        <ul class="elements"></ul>
                    </div>
                </div>
              </div>
          </div>';

    console.log html
    $('#yaml-editor').append html
    pageElement = $('#page-object-'+ (pages.length-1))
    console.log pageElement
    pageElement.find('.remove-page-button').click (e) ->
      console.log 'lafefe'
      if page.active
        chrome.tabs.sendMessage page.tabId,
          msg: 'removeAllStyles'
      pages.splice pages.length-1
      pageElement.remove()
      pageElements = $('.page-object')
      i = 0
      while i < pages.length
        $('.page-number').eq(i).text '#' + (i + 1) + ' Page Name'
        i++

  processIncomingMessage = (request, sender, sendResponse) ->
    console.log sender.tab.url
    senderURL = stripTrailingSlash(sender.tab.url)
    if request.msg is 'addElement'
      sendResponse msg: 'success'
      element = request.element
      console.log element
      haveTabId = false
      console.log pages
      for index of pages
        console.log 'kak'
        console.log pages[index].url
        console.log senderURL
        if pages[index].tabId is sender.tab.id and pages[index].url is senderURL
          console.log index
          addElement index, element
          haveTabId = true
      unless haveTabId
        console.log sender.tab.id
        console.log senderURL
        console.log sender.tab.title
        page = addPage(sender.tab.id, senderURL, sender.tab.title)
        addElement pages.length - 1, element
    else if request.msg is 'newPage'
      sendResponse msg: 'startExtension'
      if tobeSent[sender.tab.id]
        chrome.tabs.sendMessage sender.tab.id,
          msg: 'findXpaths'
          Xpaths: tobeSent[sender.tab.id]

        delete tobeSent[sender.tab.id]

        return
      for k of pages
        deactivatePage k  if pages[k].tabId is sender.tab.id and pages[k].url isnt senderURL  if pages[k].active
    else if request.msg is 'checkXpath'
      console.log 'checkXpath ' + request.Xpath + ' found = ' + request.found
      for i of pages
        if pages[i].tabId is sender.tab.id and pages[i].url is senderURL
          j = 0

          while j < pages[i].elements.length
            if pages[i].elements[j].Xpath is request.Xpath
              elementsDom = $('.page-object').eq(i).find('.element-no')
              if request.found
                elementsDom.eq(j).css 'color', 'green'
              else
                elementsDom.eq(j).css 'color', 'red'
            j++
    return

  clearPages = (callback, arg) ->
    pages = []
    pageCount = 0
    tobeSent = {}
    chrome.tabs.query {}, (tabs) ->
      for i of tabs
        chrome.tabs.sendMessage tabs[i].id,
          msg: 'removeAllStyles'
      $('#container').html ''
      callback arg  if callback
      return

    return
  chrome.tabs.onRemoved.addListener (tabId, removeInfo) ->
    for i of pages
      deactivatePage i  if pages[i].tabId is tabId  if pages[i].active
    return


  $ ->
    $('#clear-all-button').click (e) ->
      clearPages()
      return

    $('.elements li').click (e) ->
      $('.elements li').removeClass 'active'
      $(this).addClass 'active'
      return
    console.log('awgweg')
    $('#elementModal').on 'show.bs.modal', (event)-> 
      console.log 'awegawhar'
      button = $(event.relatedTarget) 
      console.log 'efwegewgg'
      elementId = button.data('element-id')
      pageIndex = parseInt elementId.split('-')[0]
      elementId = parseInt elementId.split('-')[1]
      console.log 'pageIndex ' + pageIndex + ' elementId ' + elementId
      element = pages[pageIndex].elements[elementId]
      modal = $(this)
      console.log modal
      modal.find('.modal-title').text(element.Xpath)
      modal.find('.modal-body input').val(element.name)
      modal.find('.modal-body textarea').val(element.comment)
      modal.find('.modal-footer .btn-primary').unbind('click')
      modal.find('.modal-footer .btn-primary').click( ->
        element.name = modal.find('.modal-body input').val()
        element.comment = modal.find('.modal-body textarea').val()
        console.log '' + element.name
        button.text element.name
        modal.modal 'hide'
        return
      )
      return
    return
  return
    
