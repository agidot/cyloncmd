require.config paths:
  ace: "../lib/ace"
  text: "../lib/requirejs/text"

require [
  "ace/ace"
  "ace/ext/language_tools"
  "ace/mode/cylon_completions"
  "./page"
], (ace, langTools, cylon_completions,Page) ->

  self = this

  editor = ace.edit("gherkin-editor")
  editor.setTheme "ace/theme/twilight"
  editor.getSession().setMode "ace/mode/cylon"
  console.log cylon_completions
  keywords = new cylon_completions.CylonCompletions().keywords
  document = editor.getSession().getDocument()
  editor.setOptions
    enableBasicAutocompletion: true
    enableSnippets: true
    enableLiveAutocompletion: true
  langTools.snippetCompleter.getDocTooltip = false;

  stripTrailingSlash = (str) ->
    return str.substr(0, str.length - 1)  if str.substr(-1) is '/'
    str

  chrome.runtime.onMessage.addListener (request, sender, sendResponse) ->
    console.log (if sender.tab then 'from a content script:' + sender.tab.url else 'from the extension')
    processIncomingMessage request, sender, sendResponse
    return

    return

  self.pages = []
  pageCount = 0
  bg = chrome.extension.getBackgroundPage()
  tobeSent = {}
  headerHeight = 100

  addElement = (pageIndex, element) ->
    page = pages[pageIndex]
    element.Id = '' + page.Id + '-' + page.elementCount++
    page.elements.push element
    keywords['element'].push(element.name);
    console.log element.Id

    pageURL = page.url
    elements = page.elements
    if element.comment is undefined
      element.comment = ''
    html = ''

    html += '<li class="element-item">
              <div class="btn-group">
                <a href="#" class="element element-text-button btn btn-primary elementBtn" title="' + element.name + '" data-toggle="modal" data-target="#elementModal" data-element-id="'+ element.Id + '">
                  <span class="element-text">' + element.name + '</span>
                </a><a href="#" title="Highlight element in page" class="element element-control find-element-button">
                  <i class="fa fa-paint-brush"></i>
                </a><a href="#" title="Insert element to editor" class="element element-control insert-element-button">
                  <i class="fa fa-long-arrow-up"></i>
                </a><a href="#" title="Remove element" class="element element-control remove-element-button">
                  <i class="fa fa-remove"></i>
                </a>
              </div>
            </li>';

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
      elementIndex = $(this).closest('.element-item').index()
      keywordIndex = keywords['element'].indexOf(element.name)
      unless keywordIndex is -1
        keywords['element'].splice keywordIndex,1
      elements.splice elementIndex, 1
      console.log elements
      elementDom.remove()
      chrome.tabs.sendMessage page.tabId,
        msg: 'removeStyleAtXpath'
        Xpath: element.Xpath
        url: pageURL
    elementDom.find('.find-element-button').click (e) ->
      chrome.tabs.sendMessage page.tabId,
        msg: 'findXpath'
        Xpath: element.Xpath
        url: pageURL
    elementDom.find('.insert-element-button').click (e) ->
      editor.insert element.name

  deactivatePage = (index) ->
    self.pages[index].active = false
    $('.page-object').eq(index).find('.element-item').addClass('not-found')
  activatePage = (index) ->
    self.pages[index].active = true
  addPage = (tabId, pageURL, pageTitle, comment = "") ->
    pageURL = stripTrailingSlash(pageURL)
    page = new Page(tabId, pageURL, pageTitle, comment)
    page.Id = pageCount++
    self.pages.push page
    keywords['page'].push(pageTitle)
    html = ''
    console.log self.pages.length-1

    html += '<div class="panel-group page-object" id="page-object-' + page.Id + '">
              <div class="panel panel-default">
                <div class="panel-heading" role="tab" id="headingOne">
                  <div class="panel-title">
                    <a data-toggle="collapse" class="page-number" href="#elements-' + (self.pages.length-1) + '">
                      #' + self.pages.length + ' ' + page.name + '
                    </a>
                    <div class="page-controls pull-right">
                      <a href="#" title="Highlight all elements in page" class="find-elements-button">
                        <i class="fa fa-paint-brush"></i>
                      </a>
                      <a href="#" title="Edit Page" class="edit-page-button" data-toggle="modal" data-target="#pageModal"  data-page-id="'+ page.Id + '">
                        <i class="fa fa-pencil"></i>
                      </a>
                      <a href="#" title="Remove Page" class="remove-page-button">
                        <i class="fa fa-close remove-button"></i>
                      </a>
                    </div>
                  </div>
                </div>
                <div id="elements-' + page.Id + '" class="panel-collapse collapse in">
                    <div class="panel-body">
                        <ul class="elements"></ul>
                    </div>
                </div>
              </div>
          </div>';
    console.log html

    $('#yaml-editor').append html
    pageElement = $('.page-object').eq(self.pages.length-1)
    console.log pageElement
    pageElement.find('.remove-page-button').click (e) ->
      index = $(this).closest('.page-object').index()
      if page.active
        chrome.tabs.sendMessage page.tabId,
          msg: 'removeAllStyles'
      keywordIndex = keywords['page'].indexOf(page.name)
      unless keywordIndex is -1
        keywords['page'].splice keywordIndex,1
      pagesName = page.elements.map((e)->
        return e.name
      )
      console.log keywords['element']
      keywords['element'] = keywords['element'].concat(pagesName).filter((item, index, array) ->
        array.indexOf(item) is array.lastIndexOf(item)
      )
      console.log keywords['element']
      self.pages.splice index, 1
      pageElement.remove()
      pageElements = $('.page-object')
      i = index
      while i < self.pages.length
        $('.page-number').eq(i).text '#' + (i + 1) + ' Page Name'
        i++
    pageElement.find('.find-elements-button').click (e) ->
      index = $(this).closest('.page-object').index()
      Xpaths = []
      for j of page.elements
        Xpaths.push page.elements[j].Xpath
      if page.active
        chrome.tabs.sendMessage page.tabId,
          msg: 'findXpaths'
          Xpaths: Xpaths

        chrome.tabs.update page.tabId,
          active: true
      else
        chrome.windows.create
          url: pageURL
        , (wind) ->
          activatePage index
          page.tabId = wind.tabs[0].id
          tobeSent[wind.tabs[0].id] = Xpaths
          return false
    page.active = true

  processIncomingMessage = (request, sender, sendResponse) ->
    console.log sender.tab.url
    senderURL = stripTrailingSlash(sender.tab.url)
    if request.msg is 'addElement'
      sendResponse msg: 'success'
      element = request.element
      console.log element
      haveTabId = false
      for index of self.pages
        console.log self.pages[index].url
        console.log senderURL
        if self.pages[index].tabId is sender.tab.id and self.pages[index].url is senderURL
          console.log index
          addElement index, element
          haveTabId = true
      unless haveTabId
        console.log sender.tab.id
        console.log senderURL
        console.log sender.tab.title
        page = addPage(sender.tab.id, senderURL, sender.tab.title)
        addElement self.pages.length - 1, element
    else if request.msg is 'newPage'
      sendResponse msg: 'startExtension'
      if tobeSent[sender.tab.id]
        chrome.tabs.sendMessage sender.tab.id,
          msg: 'findXpaths'
          Xpaths: tobeSent[sender.tab.id]
        delete tobeSent[sender.tab.id]

        return
      for k of self.pages
        deactivatePage k  if self.pages[k].tabId is sender.tab.id and self.pages[k].url isnt senderURL  if self.pages[k].active
    else if request.msg is 'checkXpath'
      console.log 'checkXpath ' + request.Xpath + ' found = ' + request.found
      for i of self.pages
        if self.pages[i].tabId is sender.tab.id and self.pages[i].url is senderURL
          j = 0

          while j < self.pages[i].elements.length
            if self.pages[i].elements[j].Xpath is request.Xpath
              elementsDom = $('.page-object').eq(i).find('.element-item')
              if request.found
                elementsDom.eq(j).removeClass('not-found')
              else
                elementsDom.eq(j).addClass('not-found')
            j++
    return

  clearPages = (callback, arg) ->
    keywords['page'] = []
    keywords['element'] = []
    self.pages = []
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
    for i of self.pages
      deactivatePage i  if self.pages[i].tabId is tabId  if self.pages[i].active
    return

  onLoadYAML = (e) ->
    yamlString = e.target.result
    result = yamlString.split('---')
    yamlObject = []
    urls = []
    i = 1

    console.log self.pages
    while i < result.length
      result[i] = '---' + result[i]
      yamlObject.push jsyaml.load(result[i])
      yamlObject[i - 1].page.url = stripTrailingSlash(yamlObject[i - 1].page.url)
      urls.push yamlObject[i - 1].page.url
      addPage null, yamlObject[i - 1].page.url, yamlObject[i - 1].page.name, yamlObject[i - 1].page.comment
      j = 0

      while j < yamlObject[i - 1].elements.length
        element = {}
        element.name = yamlObject[i - 1].elements[j].name
        element.Xpath = yamlObject[i - 1].elements[j].xpath
        if yamlObject[i - 1].elements[j].comment
          element.comment = yamlObject[i - 1].elements[j].comment
        addElement i - 1, element, false
        j++
      i++
    console.log pages
    chrome.windows.create
      url: urls
    , (wind) ->
      for tab of wind.tabs
        elements = pages[tab].elements
        pages[tab].tabId = wind.tabs[tab].id
        Xpaths = []
        for elem of elements
          Xpaths.push elements[elem].Xpath
        tobeSent[wind.tabs[tab].id] = Xpaths
      return
    return


  constructYAML = -> 
    count = 0
    yaml = ''
    for i of self.pages
      yamlObject = {}
      yamlObject.page = {}
      yamlObject.elements = []
      yamlObject.page.name = self.pages[i].name
      yamlObject.page.url = self.pages[i].url
      comment = self.pages[i].comment
      if comment isnt ''
        yamlObject.page.comment = comment
      j = 0
      while j < self.pages[i].elements.length
        element = {}
        element.name = self.pages[i].elements[j].name
        element.xpath = self.pages[i].elements[j].Xpath
        comment = self.pages[i].elements[j].comment
        if comment isnt ''
          element.comment = comment
        yamlObject.elements.push element
        j++
      yamlDumped = jsyaml.safeDump(yamlObject)
      yaml += '---\n' + yamlDumped
      count++
    yaml += '...'
    blob = new Blob([yaml],
      type: 'text/plain;charset=utf-8'
    )
    saveAs blob, 'profile.yaml'
    return

  readYAML = (input) ->
    if input.files and input.files[0]
      reader = new FileReader()
      reader.onload = (e) ->
        clearPages onLoadYAML, e
        return

      reader.readAsText input.files[0]
    return

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

  $("#import-yaml-file-input").click ->
    $(this).val ""
    return

  $("#import-yaml-file-input").change ->
    return  if $(this).val() is ""
    readYAML this
    return

  $("#export-button").click ->
    text = editor.getSession().getValue()
    blob = new Blob([text],
      type: "text/plain;charset=utf-8"
    )
    saveAs blob, "feature-file.feature"
    return

  $("#yaml-export-button").click ->
    constructYAML()
    return
  

  $ ->
    $('#clear-all-button').click (e) ->
      clearPages()
      return

    $('.elements li').click (e) ->
      $('.elements li').removeClass 'active'
      $(this).addClass 'active'
      return

    $('#elementModal').on 'show.bs.modal', (event)-> 
      button = $(event.relatedTarget) 
      elementId = button.data('element-id')
      element = null
      console.log elementId
      for page in self.pages
        for e in page.elements
          if e.Id is elementId
            element = e
      modal = $(this)
      modal.find('.modal-title').text(element.Xpath)
      modal.find('.modal-body input').val(element.name)
      modal.find('.modal-body textarea').val(element.comment)
      modal.find('.modal-footer .btn-primary').unbind('click')
      modal.find('.modal-footer .btn-primary').click( ->
        newElementName = modal.find('.modal-body input').val()
        unless newElementName is element.name
          keywordIndex = keywords['element'].indexOf(element.name)
          unless keywordIndex is -1
            keywords['element'].splice keywordIndex, 1
            keywords['element'].push(newElementName)
          element.name = newElementName
        element.comment = modal.find('.modal-body textarea').val()
        button.text element.name
        modal.modal 'hide'
        return
      )
      return

    $('#pageModal').on 'show.bs.modal', (event)-> 
      button = $(event.relatedTarget)
      pageId = button.data('page-id')
      page = null
      for p in self.pages
        if p.Id is pageId
          page = p
      console.log 'page'
      console.log page
      modal = $(this)
      modal.find('.modal-title').text(page.url)
      modal.find('.modal-body input').val(page.name)
      modal.find('.modal-body textarea').val(page.comment)
      modal.find('.modal-footer .btn-primary').unbind('click')
      modal.find('.modal-footer .btn-primary').click( ->
        newPageName = modal.find('.modal-body input').val()
        unless newPageName is page.name
          keywordIndex = keywords['page'].indexOf(page.name)
          unless keywordIndex is -1
            keywords['page'].splice keywordIndex, 1
            keywords['page'].push(newPageName)
          page.name = newPageName
        page.comment = modal.find('.modal-body textarea').val()
        console.log button.closest('.page-object').find('.page-number').text()
        button.closest('.page-object').find('.page-number').text(page.name)
        modal.modal 'hide'
        return
      )
      return
    return

    
