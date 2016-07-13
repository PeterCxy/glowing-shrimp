Component = require './component.coffee'
dialogPolyfill = require 'dialog-polyfill'

module.exports = class Login extends Component
  constructor: (@element, @templateUrl = '/template/login.hbs') ->
    super

  update: ->
    context = {}
    @element.innerHTML = @template context
    componentHandler.upgradeElements @element
    @restore()

    # Setup the listeners
    @element.querySelector('#ok').onclick = @login.bind this

  restore: ->
    # Restore values in local storage
    details = localStorage.getItem 'login_details'
    if details?
      details = JSON.parse details
      if details.hostname?
        box = @element.querySelector('#hostname')
        box.value = details.hostname
        box.parentNode.className += ' is-dirty' # Change MDL Text Input state
      if details.port?
        box = @element.querySelector('#port')
        box.value = details.port
        box.parentNode.className += ' is-dirty' # Change MDL Text Input state
      if details.ssl?
        box = @element.querySelector('#ssl')
        if details.ssl isnt box.checked
          box.click()

  save: (details) ->
    delete details.password
    localStorage['login_details'] = JSON.stringify details

  show: ->
    dialog = @element.querySelector 'dialog'
    if not dialog.showModal?
      dialogPolyfill.registerDialog dialog
    dialog.showModal()

  login: ->
    details = 
      hostname: @element.querySelector('#hostname').value.trim()
      port: @element.querySelector('#port').value.trim()
      password: @element.querySelector('#password').value
      ssl: @element.querySelector('#ssl').checked

    if details.hostname is ''
      @element.querySelector('#hostname').focus()
      return
    if details.port is '' or isNaN(parseInt details.port)
      @element.querySelector('#port').focus()
      return

    # TODO: Actually login

    @save(details)
