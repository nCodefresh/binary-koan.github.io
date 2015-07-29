express = require 'express'

{ tasks, watch } = require './tasks/loader'
templates = require './tasks/templates'

tasks
  clean: 'rimraf build/*'
  public: 'ncp assets/public build'

  mkjsdir: 'mkdirp build/scripts'
  browserify: 'browserify assets/scripts/main.js -o build/scripts/main.js'
  js: ['mkjsdir', 'browserify']

  css: 'lessc assets/styles/main.less build/styles/main.css'
  cssmin: 'lessc assets/styles/main.less build/styles/main.css --clean-css'
  copyless: 'ncp assets/styles build/styles'

  templates: templates

  build: ['clean', 'public', 'js', 'cssmin', 'templates']

  pushghpages: '$ git subtree push --prefix build origin master'
  deploy: ['build', 'pushghpages']

watch
  'assets/public': 'public'
  'assets/scripts': 'js'
  'assets/styles': ['css', 'copyless']
  '.': [
    'templates', filter: (f) ->
      /^articles\b/.test(f) || /^pages\b/.test(f) || /^templates\b/.test(f)
  ]

task 'server', ->
  invoke 'clean'
  invoke 'watch'
  console.log 'Server listening on port 8080'
  express().use(express.static('build')).listen(8080)
