Login = require './login.coffee'
Drawer = require './drawer.coffee'
Panel = require './panel.coffee'

class App
  constructor: ->
    @login = new Login document.querySelector '#login'
    @login.initialize()
      .catch (err) -> console.error err
      .then =>
        @drawer = new Drawer document.querySelector '#drawer'
        @drawer.initialize()
      .then =>
        @login.update()
        @login.show()
      .then =>
        @panel = new Panel document.querySelector '.page-content'
        @panel.initialize()

window.App = new App