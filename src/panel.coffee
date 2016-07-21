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
    @currentBufferTitle = null
    @noMore = false

  initialize: ->
    super
      .then => @partial = Handlebars.compile templates['template/msg.hbs']
      .then =>
        @setupListeners()
        @setupSnackbar()

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
      @setupButtons()
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
        container.scrollTop = container.scrollHeight
      else
        total = container.scrollHeight - container.clientHeight
        if (cur / total) > 0.9 or container.scrollHeight <= (container.clientHeight * 1.2)
          container.scrollTop = container.scrollHeight

  switchTo: (id, title) ->
    return if id is @currentBuffer
    document.querySelector('#toolbar-title').innerHTML = title
    @currentBuffer = id
    @currentBufferTitle = title
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

  setupButtons: ->
    sendButton = @element.querySelector '#action-send'
    textBox = @element.querySelector '#input-box'
    sendButton.onclick = =>
      return if not @currentBuffer?
      weechat.sendMessage @currentBuffer, textBox.value
      textBox.value = ''
    textBox.onkeypress = (ev) =>
      if ev.keyCode is 13
        sendButton.click()

  setupSnackbar: ->
    document.querySelector('#toolbar-title').onclick = =>
      @element.querySelector('#snackbar-title').MaterialSnackbar.showSnackbar
        message: @currentBufferTitle
        timeout: 5000
