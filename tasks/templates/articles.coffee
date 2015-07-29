path = require 'path'
fs = require 'fs'
util = require 'file-utils'
matter = require 'gray-matter'
swig = require 'swig'
marked = require 'marked'
{ exec } = require 'child_process'
mkdirp = require 'mkdirp'

util.option 'logger', require('./fileutils-logger')
marked.setOptions smartypants: true

render = require './render'
site = require './site'

articlePath = (file) ->
  file.split('_').join('/')

articleDate = (file) ->
  [year, month, day] = file.split('_')
  new Date(year, month, day)

outputDir = (file) ->
  'build/blog/' + articlePath(file)

addCaptions = (content) ->
  content.replace /<img src="[^"]+" alt="([^"]+)">/g, '$&<span class="caption">$1</span>'

articleData = (file, content) ->
  article = matter content
  article.data.content = addCaptions marked(article.content)
  article.data.outputDir = outputDir file.replace(/\.md$/, '')
  article.data.url = 'blog/' + articlePath(file.replace(/\.md$/, ''))
  article.data.date = articleDate file
  article.data.coverThumb = createCoverThumb file, article.data.cover
  article.data

copyAssets = (file, filePath) ->
  output = outputDir file
  util.recurse filePath, (absPath, root, subdir, filename) ->
    util.copy absPath, path.normalize("#{output}/#{subdir ? ''}/#{filename}")

createCoverThumb = (file, cover) ->
  return unless cover
  thumbName = cover.replace /\.([a-z]+)$/i, '_thumb.$1'
  outputDirname = outputDir file
  mkdirp outputDirname, (err) ->
    console.error(err) if err
    output = "#{outputDirname}/#{thumbName}"
    input = "articles/#{file.replace(/\.md$/, '')}/#{cover}"
    options = '-resize "200x200>" -gravity center -extent 200x200'
    exec "gm convert #{input} #{options} #{output}", (err, stdout, stderr) ->
      console.error(err) if err
  thumbName

renderArticle = (data) ->
  locals =
    article: data
    site: site
    title: "#{data.title} - #{site.title}"
  content = swig.renderFile "templates/blogpost.html", locals
  render.static "#{data.outputDir}/index.html", content, locals
  render.fragment "#{data.outputDir}.fragment.html", content, locals

module.exports = buildArticles = ->
  articles = []
  fs.readdirSync('articles').sort().reverse().forEach (file) ->
    filePath = "articles/#{file}"
    if util.isDir filePath
      copyAssets file, filePath
    else if /\.md$/.test file
      data = articleData file, util.read(filePath)
      articles.push data
      renderArticle data
  articles
