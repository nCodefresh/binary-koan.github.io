require 'listen'

require_relative 'templates'
require_relative 'assets'

class WatcherTask
  def initialize
    @template_builder = TemplatesTask.new
    @asset_builder = AssetsTask.new
  end

  def watch_all
    template_watcher.start
    page_watcher.start
    article_watcher.start
    script_watcher.start
    style_watcher.start
    public_watcher.start
  end

  def template_watcher
    path = File.dirname(__FILE__) + '/templates'
    Listen.to path do |modified, added, removed|
      recompile_pages = false
      (modified + added + removed).each do |file|
        if file =~ /\/blogpost\.html$/
          puts 'Recompiling articles ...'
          @template_builder.build_articles
        else
          recompile_pages = true
        end
      end
      if recompile_pages
        puts 'Recompiling pages ...'
        @template_builder.build_pages
      end
    end
  end

  def article_watcher
    path = $config[:articles_path]
    abs_path = File.absolute_path path
    Listen.to path do |modified, added, removed|
      p modified
      (added + modified).each do |file|
        puts "Compiling article #{file} ..."
        @template_builder.build_article file.sub(abs_path + '/', '')
      end
      if (added + modified + removed).length > 0
        puts 'Recompiling pages ...'
        @template_builder.build_pages
      end
    end
  end

  def page_watcher
    path = $config[:pages_path]
    abs_path = File.absolute_path path
    Listen.to path do |modified, added, removed|
      if (added + removed).length > 0
        puts 'Added or removed a page, recompiling all'
        @template_builder.build_pages
      else
        modified.each do |file|
          puts "Compiling page #{file} ..."
          @template_builder.build_page file.sub(abs_path + '/', '')
        end
      end
    end
  end

  def script_watcher
    paths = Set.new
    $config[:scripts].each { |script, _| paths.add(File.dirname(script)) }

    Listen.to *paths.to_a do |modified, added, removed|
      puts 'Recompiling scripts ...'
      @asset_builder.compile_scripts
    end
  end

  def style_watcher
    paths = Set.new
    $config[:styles].each { |stylesheet, _| paths.add(File.dirname(stylesheet)) }

    Listen.to *paths.to_a do |modified, added, removed|
      puts 'Recompiling stylesheets ...'
      @asset_builder.compile_styles
    end
  end

  def public_watcher
    Listen.to $config[:public_path] do |modified, added, removed|
      @asset_builder.copy_public
    end
  end
end
