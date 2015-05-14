require 'rubygems'
require 'bundler/setup'

require 'fileutils'
require 'webrick'
require 'listen'

require_relative 'utilities/rake/templates'

#
# Environment
#

Dir.chdir File.dirname(__FILE__)

BUILD_ENV = ENV['env'] || 'debug'
BUILD_DIR = ENV['out'] || 'build'

#
# Utility functions
#

def check_npm_command(command, package_name)
  `#{command} --help 2>&1`
rescue Errno::ENOENT
  output = `npm install -g #{package_name}`
  unless $? == 0
    puts
    puts output
    raise '#{package_name} not found; tried to install but it failed.'
  end
end

def compile_css
  source_file = 'assets/styles/main.less'
  build_file = BUILD_DIR + '/styles/main.css'
  extra_args = '--source-map' if BUILD_ENV == 'debug'

  output = `lessc #{source_file} #{build_file} #{extra_args}`
  unless $? == 0
    puts
    puts output
    raise 'Error while running lessc.'
  end
end

def compile_js(mode = nil)
  source_file = 'assets/scripts/main.js'
  build_file = BUILD_DIR + '/scripts/main.js'
  extra_args = '-d' if BUILD_ENV == 'debug'

  source_files = Dir.glob('assets/scripts/*.js').join(' ') + ' ' + source_file

  output = `webpack #{source_files} #{build_file} #{extra_args}`
  unless $? == 0
    puts
    puts output
    raise 'Error while running webpack.'
  end
end

#
# Tasks
#

task :default => %w{ clean templates js css assets }
task :server => %w{ default watch }

task :clean do
  print 'Cleaning build dir ... '
  FileUtils.rm_r(BUILD_DIR) if File.directory?(BUILD_DIR)
  puts 'done.'
  puts
end

task :templates do
  puts 'Compiling templates:'
  builder = TemplatesTask.new

  # Blog articles
  print 'Blog articles ... '
  builder.build_articles 'articles'
  puts 'done.'

  # Site pages
  print 'Site pages ... '
  builder.build_pages 'pages'
  puts 'done.'
  puts
end

task :js do
  puts 'Compiling JS:'

  # Check webpack is installed
  print 'Checking for webpack ... '
  check_npm_command 'webpack', 'webpack'
  puts 'exists.'

  print 'Running webpack ... '

  compile_js

  puts 'done.'
  puts
end

task :css do
  puts 'Compiling CSS:'

  # Check lessc is installed
  print 'Checking for lessc ... '
  check_npm_command 'lessc', 'less'
  puts 'exists.'

  print 'Copying original files ... '
  FileUtils.mkdir_p 'build/assets/styles'
  FileUtils.copy_entry 'assets/styles', 'build/assets/styles'
  puts 'done.'

  print 'Running lessc ... '
  compile_css
  puts 'done.'

  puts
end

task :assets do
  print 'Copying assets ... '
  FileUtils.copy_entry 'assets/public', 'build'
  puts 'done.'
end

task :watch do
  puts 'Watching files for changes.'

  listener = Listen.to 'site' do |modified, added, removed|
    modified += added
    page_regex = /\bpages\/([^\/]+\.html)/
    asset_regex = /\bassets\/public\/(.+)/
    modified.each do |e|
      if e =~ page_regex
        print "Recompiling page #{$1} ... "
        compile_page 'site', $1
        puts 'done.'
      elsif e =~ asset_regex
        print "Coping asset #{$1} ... "
        FileUtils.copy e, e.sub(/.+\/assets\//, 'build/assets/')
        puts 'done.'
      end
    end

    modified += removed
    if modified.index { |e| e.end_with? '.js' }
      print 'Recompiling JS ... '
      compile_js
      puts 'done.'
    end
    if modified.index { |e| e.end_with? '.less' }
      print 'Recompiling CSS ... '
      compile_css
      puts 'done.'
    end
  end
  listener.start

  listener = Listen.to 'blog' do |modified, added, removed|
    modified += added
    article_regex = /articles\/([^\/]+\.md)/
    modified.each do |e|
      if e =~ article_regex
        print "Recompiling article #{$1} ... "
        compile_article 'blog', $1
        puts 'done.'
      end
    end
  end
  listener.start

  puts

  Rake::Task['webrick'].invoke
end

task :webrick do
  puts 'Starting server on port 8000.'
  WEBrick::HTTPServer.new(Port: 8000, DocumentRoot: File.join(Dir.pwd, BUILD_DIR)).start
end
