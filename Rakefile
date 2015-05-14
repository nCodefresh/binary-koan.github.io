require 'rubygems'
require 'bundler/setup'

require 'fileutils'
require 'webrick'
require 'listen'

require_relative 'utilities/rake/templates'
require_relative 'utilities/rake/assets'

template_builder = TemplatesTask.new
asset_builder = AssetsTask.new

#
# Environment
#

Dir.chdir File.dirname(__FILE__)

BUILD_ENV = ENV['env'] || 'debug'
BUILD_DIR = ENV['out'] || 'build'

#
# Utility functions
#

def compile_css
end

#
# Tasks
#

task :default => %w{ clean templates assets }
task :server => %w{ default watch }

task :clean do
  puts 'Cleaning build dir ...'
  FileUtils.rm_r(BUILD_DIR) if File.directory?(BUILD_DIR)
  puts 'done.'
  puts
end

task :templates do
  puts 'Compiling templates:'

  # Blog articles
  puts '  Blog articles ...'
  template_builder.build_articles 'articles'

  # Site pages
  puts '  Site pages ...'
  template_builder.build_pages 'pages'

  puts 'done.'
  puts
end

task :assets do
  puts 'Compiling assets:'

  puts '  Compiling scripts ...'
  asset_builder.compile_scripts 'assets/scripts/main.js', "#{BUILD_DIR}/scripts/main.js"
  puts '  Compiling stylesheets ...'
  asset_builder.compile_styles 'assets/styles/main.less', "#{BUILD_DIR}/styles/main.css"
  puts '  Copying assets ...'
  asset_builder.copy_assets 'assets/public', 'build'
  
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
