path = require 'path'
fs = require 'fs'
util = require 'file-utils'
matter = require 'gray-matter'
swig = require 'swig'

render = require './render'
site = require './site'

pageIdFrom = (path) ->
  id = path.replace(/\.[a-z]+$/i, '').replace(/[^a-zA-Z0-9]/g, '-')
  id = 'index' unless id.length > 0
  id

titleFrom = (title) ->
  if title then "#{title} - #{site.title}" else site.title

module.exports = buildPages = (articles=[])->
  fs.readdirSync('pages').forEach (file) ->
    if /\.(html|xml)$/.test file
      page = matter util.read("pages/#{file}")
      locals =
        page: page.data
        pageId: pageIdFrom(file)
        articles: articles
        site: site
        title: titleFrom(page.data.title)
      content = swig.render page.content, filename: "templates/#{file}", locals: locals
      if file == 'index.html'
        render.static 'build/index.html', content, locals
        render.fragment 'build/index.fragment.html', content, locals
      else if /\.html$/.test file
        file = file.replace /\.html$/, ''
        render.static path.normalize("build/#{file}/index.html"), content, locals
        render.fragment "build/#{file}.fragment.html", content, locals
      else
        fs.writeFileSync "build/#{file}", content
      
