Component = require './component.coffee'
weechat = require './weechat.coffee'

module.exports = class Drawer extends Component
  constructor: (@element, @templateUrl = '/template/drawer.hbs') ->
    super
    @buffers = []
    @rawBuffers = []
    @bufferMap = {}

  initialize: ->
    super
      .then =>
        @update()
        @setup()

  update: (buffers = @buffers) ->
    @buffers = buffers
    context = 
      buffers: @buffers
    @element.innerHTML = @template context

  setup: ->
    weechat.on 'bufferListUpdate', (list) =>
      @buffers = []
      @rawBuffers = []
      @bufferMap = {}
      list.forEach @addBuffer
      @update()

  addBuffer: (buf) =>
    buf.full_name = buf.name
    components = buf.full_name.split '.'
    if components[0] is 'server'
      buf.name = components[1]
    @rawBuffers.push buf
    @bufferMap[buf.name] = buf

    # Parent-child relationships
    if components.length > 1 and @bufferMap[components[0]]?
      buf.name = components[1...].join '.'
      parent = @bufferMap[components[0]]
      if not parent.childs
        parent.childs = []
      parent.childs.push buf
    else
      @buffers.push buf