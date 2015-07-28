module.exports = ->
  articles = require('./templates/articles')()
  require('./templates/pages')(articles)
