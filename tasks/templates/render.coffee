swig = require 'swig'
util = require 'file-utils'
util.option 'logger', require('./fileutils-logger')

module.exports =
  static: (filename, content, locals) ->
    locals.content = content
    util.write filename, swig.renderFile('templates/pagetypes/static.html', locals)

  fragment: (filename, content, locals) ->
    locals.content = content
    util.write filename, swig.renderFile('templates/pagetypes/fragment.html', locals)
