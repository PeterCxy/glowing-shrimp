weechat = require './weechat.coffee'
Handlebars = require 'handlebars'
Component = require './component.coffee'
{templates} = require './templates_loader.coffee'

LINES_PER_PAGE = 30
module.exports = class Panel extends Component
  constructor: (@element, @templateUrl = 'template/panel.hbs') ->
    super
    @bufferLines = {}
    @currentBuffer = null
    @noMore = false

  initialize: ->
    super
      .then => @partial = Handlebars.compile templates['template/msg.hbs']
      .then => @setupListeners()

  setupListeners: ->
    weechat.on 'bufferNewLine', (msg) =>
      return if not (msg? and msg.length > 0)

      msg[0].content.forEach (it) =>
        if not @bufferLines[it.buffer]?
          @bufferLines[it.buffer] = []
        @bufferLines[it.buffer].push it # TODO: Notifications and unread counts
        if @currentBuffer is it.buffer
          @update true, true, it

  update: (scrollToBottom = true, scrollIfBottom = false, newLine = null) ->
    cur = 0
    container = @element.querySelector '#lines'

    if container isnt null
      cur = container.scrollTop

    if not newLine?
      context =
        lines: @bufferLines[@currentBuffer]
      @element.innerHTML = @template context
      componentHandler.upgradeElements @element
    else
      # Just add the new line
      context = newLine
      @element.querySelector('#lines-container').innerHTML += @partial context
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