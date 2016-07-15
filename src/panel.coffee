weechat = require './weechat.coffee'
Component = require './component.coffee'

LINES_PER_PAGE = 30
module.exports = class Panel extends Component
  constructor: (@element, @templateUrl = 'template/panel.hbs') ->
    super
    @bufferLines = {}
    @currentBuffer = null
    @noMore = false

  update: (scrollToBottom = true) ->
    console.log @bufferLines[@currentBuffer]
    context =
      lines: @bufferLines[@currentBuffer]
    @element.innerHTML = @template context
    componentHandler.upgradeElements @element

    # Scroll to bottom
    if scrollToBottom
      container = @element.querySelector '#lines'
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