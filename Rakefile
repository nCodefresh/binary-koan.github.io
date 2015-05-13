require 'rubygems'
require 'bundler/setup'

require 'fileutils'
require 'webrick'
require 'listen'

require './templates/templates'

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

def compile_page(base_dir, filename)
  static_html, fragment_html = Templates.render_page base_dir, filename

  # Special case for homepage
  if filename == 'index.html'
    static_filename = BUILD_DIR + '/index.html'
    fragment_filename = BUILD_DIR + '/index.fragment.html'
  else
    base_filename = filename[0..-6] # Remove '.html'
    FileUtils.mkdir_p BUILD_DIR + '/' + base_filename
    static_filename = BUILD_DIR + '/' + base_filename + '/index.html'
    fragment_filename = BUILD_DIR + '/' + base_filename + '.fragment.html'
  end

  File.write static_filename, static_html
  File.write fragment_filename, fragment_html
end

def article_build_dir(base_dir, filename)
  base_path = filename.split('_') # Remove '.md' and split into desired subdirs
  build_dir = File.join BUILD_DIR, 'blog', *base_path
  FileUtils.mkdir_p build_dir
  build_dir
end

def compile_article(base_dir, filename)
  static_html, fragment_html = Templates.render_article base_dir, filename

  build_dir = article_build_dir base_dir, filename[0..-4]

  File.write File.join(build_dir, 'index.html'), static_html
  build_dir << '.fragment.html'
  File.write build_dir, fragment_html
end

def copy_article_assets(base_dir, filename)
  build_dir = article_build_dir base_dir, filename

  Dir.entries(File.join(base_dir, filename)).each do |asset|
    next if File.directory? asset
    FileUtils.copy File.join(base_dir, filename, asset), File.join(build_dir, asset)
  end
end

def compile_css
  source_file = 'site/css/main.less'
  build_file = BUILD_DIR + '/css/main.css'
  extra_args = '--source-map' if BUILD_ENV == 'debug'

  output = `lessc #{source_file} #{build_file} #{extra_args}`
  unless $? == 0
    puts
    puts output
    raise 'Error while running lessc.'
  end
end

def compile_js(mode = nil)
  source_file = 'site/js/main.js'
  build_file = BUILD_DIR + '/js/main.js'
  extra_args = '-d' if BUILD_ENV == 'debug'

  source_files = Dir.glob('site/js/pages/*.js').join(' ') + ' ' + source_file

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

  # Blog articles
  print 'Blog articles ... '
  base_dir = 'blog'

  Dir.entries(base_dir).each do |filename|
    if File.directory?(File.join(base_dir, filename)) and not filename =~ /\.\.?/
      copy_article_assets base_dir, filename
    elsif filename.end_with?('.md')
      compile_article base_dir, filename
    end
  end

  puts 'done.'

  # Site pages
  print 'Site pages ... '
  base_dir = 'site'

  Dir.entries(base_dir).each do |filename|
    if filename.end_with?('.html') and not File.directory?(File.join(base_dir, filename))
      compile_page base_dir, filename
    end
  end

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
  FileUtils.mkdir_p 'build/site'
  FileUtils.copy_entry 'site/css', 'build/site/css'
  puts 'done.'

  print 'Running lessc ... '
  compile_css
  puts 'done.'

  puts
end

task :assets do
  print 'Copying assets ... '
  FileUtils.copy_entry 'site/assets', 'build/assets'
  puts 'done.'
end

task :watch do
  puts 'Watching files for changes.'

  listener = Listen.to 'site' do |modified, added, removed|
    modified += added
    page_regex = /\bsite\/([^\/]+\.html)/
    asset_regex = /\bsite\/assets\/(.+)/
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
    article_regex = /blog\/([^\/]+\.md)/
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
