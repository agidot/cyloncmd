define [] , ->
  Page = (tabId, url, name, comment) ->
    @tabId = tabId
    @elements = []
    @name = name
    @url = url
    @active = false
    @elementCount = 0
    @Id = -1
    @comment = comment
  return Page
