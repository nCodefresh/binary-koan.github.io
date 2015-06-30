require 'rubygems'
require 'bundler/setup'

require 'fileutils'
require 'webrick'

Dir.chdir File.dirname(__FILE__)

$config = {
  env: ENV['env'] || 'debug',
  build_path: ENV['out'] || 'build',

  articles_path: 'articles',
  pages_path: 'pages',
  scripts: { 'assets/scripts/main.js' => 'scripts/main.js' },
  styles: { 'assets/styles/main.less' => 'styles/main.css' },
  public_path: 'assets/public'
}

require_relative 'utilities/rake/npm'
require_relative 'utilities/rake/templates'
require_relative 'utilities/rake/assets'
require_relative 'utilities/rake/watch'
require_relative 'utilities/rake/generate'

npm = NpmTask.new
template_builder = TemplatesTask.new
asset_builder = AssetsTask.new
watcher = WatcherTask.new
generate = GeneratorTask.new

#
# Tasks
#

task :default => %w( clean templates assets )
task :watch => %w( default watcher )
task :server => %w( watch webrick )

task :check do
  puts 'Checking dependencies ...'

  npm.check_for_npm
  npm.check_installed 'less', 'less-plugin-clean-css', 'less-plugin-autoprefix', 'webpack'

  puts 'done.'
end

task :clean do
  puts 'Cleaning build dir ...'
  FileUtils.rm_r($config[:build_path]) if File.directory?($config[:build_path])
  puts 'done.'
  puts
end

task :templates do
  puts 'Compiling templates:'

  puts '  Blog articles ...'
  template_builder.build_articles

  puts '  Site pages ...'
  template_builder.build_pages

  puts 'done.'
  puts
end

task :assets do
  puts 'Compiling assets:'

  puts '  Compiling scripts ...'
  asset_builder.compile_scripts
  puts '  Compiling stylesheets ...'
  asset_builder.compile_styles
  puts '  Copying public assets ...'
  asset_builder.copy_public

  puts 'done.'
end

task :watcher do
  puts 'Watching files for changes.'
  watcher.watch_all
  puts
end

task :webrick do
  puts 'Starting server on port 8000.'
  WEBrick::HTTPServer.new(Port: 8000, DocumentRoot: File.join(Dir.pwd, $config[:build_path])).start
end

# Generators

namespace :g do
  task :article do
    generate.article ENV['title'], ENV['date'] || Date.today
  end
end
