Component = require './component.coffee'

module.exports = class Drawer extends Component
  constructor: (@element, @templateUrl = '/template/drawer.hbs') ->
    super
    @buffers = []

  update: (buffers = @buffers) ->
    @buffers = buffers
    context = 
      buffers: @buffers
    @element.innerHTML = @template context