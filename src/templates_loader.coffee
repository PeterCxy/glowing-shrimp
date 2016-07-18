fs = require 'fs'
Handlebars = require 'handlebars'

exports.templates =
  'template/msg.hbs': fs.readFileSync 'template/msg.hbs'
  'template/drawer.hbs': fs.readFileSync 'template/drawer.hbs'
  'template/login.hbs': fs.readFileSync 'template/login.hbs'
  'template/panel.hbs': fs.readFileSync 'template/panel.hbs'

for k, v of exports.templates
  exports.templates[k] = v.toString()
  Handlebars.registerPartial k, exports.templates[k]