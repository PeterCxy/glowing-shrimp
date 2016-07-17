weechat = require './weechat.coffee'
Component = require './component.coffee'

LINES_PER_PAGE = 30
module.exports = class Panel extends Component
  constructor: (@element, @templateUrl = 'template/panel.hbs') ->
    super
    @bufferLines = {}
    @currentBuffer = null
    @noMore = false

  initialize: ->
    super
      .then => @setupListeners()

  setupListeners: ->
    weechat.on 'bufferNewLine', (msg) =>
      return if not (msg? and msg.length > 0)

      msg[0].content.forEach (it) =>
        if not @bufferLines[it.buffer]?
          @bufferLines[it.buffer] = []
        @bufferLines[it.buffer].push it
        if @currentBuffer is it.buffer
          @update true, true # TODO: Just add the element to the bottom

  update: (scrollToBottom = true, scrollIfBottom = false) ->
    cur = 0
    container = @element.querySelector '#lines'

    if container isnt null
      cur = container.scrollTop

    context =
      lines: @bufferLines[@currentBuffer]
    @element.innerHTML = @template context
    componentHandler.upgradeElements @element

    container = @element.querySelector '#lines'
    container.scrollTop = cur # TODO: Keep the scrollbar to the current element
    # Scroll to bottom
    if scrollToBottom
      if not scrollIfBottom
        container.scrollTo 0, container.scrollHeight
      else
        total = container.scrollHeight - container.clientHeight
        if (cur / total) > 0.9 or container.scrollHeight <= (container.clientHeight * 1.2)
          container.scrollTo 0, container.scrollHeight

  switchTo: (id, title) ->
    return if id is @currentBuffer
    document.querySelector('#toolbar-title').innerHTML = title
    @currentBuffer = id
    @noMore = false
    if not @bufferLines[@currentBuffer]?
      @bufferLines[@currentBuffer] = []
    if @bufferLines[@currentBuffer].length < LINES_PER_PAGE
      @loadMore()
    else
      @update()

  loadMore: ->
    originalLength = @bufferLines[@currentBuffer].length
    weechat.fetchBufferLines @currentBuffer, originalLength + LINES_PER_PAGE
      .then (list) =>
        list.reverse()
        @bufferLines[@currentBuffer] = list

        if list.length - originalLength < LINES_PER_PAGE
          @noMore = true
      .then => @update()