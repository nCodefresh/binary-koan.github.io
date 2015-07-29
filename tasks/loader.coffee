{ execSync } = require 'child_process'
{ watchTree } = require 'watch'

addTask = (name, content) ->
  if content instanceof Array
    addArrayTask name, content
  else if typeof(content) == 'string'
    addCommandTask name, content
  else if typeof(content) == 'function'
    addFunctionTask name, content
  else
    throw "Invalid task type for #{name}"

addArrayTask = (name, tasks) ->
  task name, ->
    for t in tasks
      invoke(t)

addCommandTask = (name, content) ->
  if /^\$ /.test content
    content = content.slice 2
  else
    content = process.cwd() + '/node_modules/.bin/' + content
  task name, ->
    result = execSync content
    if result.error
      console.log "Error when running task #{name}:"
      console.log result.error
    else if result.status
      console.log "Error when running task #{name}:"
      console.log result.stderr
    else
      console.log "Task #{name} finished."

addFunctionTask = (name, content, options) ->
  task name, ->
    content()
    console.log "Task #{name} finished."

watcher = (dir, options, tasks) ->
  ->
    watchTree dir, options, ->
      console.log "Invoking #{tasks.join(', ')} ..."
      invoke(t) for t in tasks

watchersFor = (dirs) ->
  watchers = []
  for dir, task of dirs
    options = {}
    if task instanceof Array
      if typeof(task[task.length - 1]) == 'object'
        [task, options] = [task.slice(0, -1), task[task.length - 1]]
    else
      task = [task]
    watchers.push watcher(dir, options, task)
  watchers

module.exports =
  tasks: (tasks) ->
    for name, content of tasks
      addTask name, content

  watch: (dirs) ->
    watchers = watchersFor dirs
    task 'watch', ->
      for watcher in watchers
        watcher()
