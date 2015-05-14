require_relative 'templates/renderer'

class TemplatesTask < TemplateRenderer
  def initialize
    super
  end

  def build_articles(base_dir)
    Dir.entries(base_dir).each do |filename|
      if File.directory?(File.join(base_dir, filename)) and not filename =~ /\.\.?/
        copy_article_assets base_dir, filename
      elsif filename.end_with?('.md')
        compile_article base_dir, filename
      end
    end
  end

  def build_pages(base_dir)
    Dir.entries(base_dir).each do |filename|
      if filename.end_with?('.html') and not File.directory?(File.join(base_dir, filename))
        compile_page base_dir, filename
      end
    end
  end

  private

  def article_build_dir(base_dir, filename)
    base_path = filename.split('_') # Remove '.md' and split into desired subdirs
    build_dir = File.join BUILD_DIR, 'blog', *base_path
    FileUtils.mkdir_p build_dir
    build_dir
  end

  def compile_page(base_dir, filename)
    static_html, fragment_html = render_page base_dir, filename

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

  def compile_article(base_dir, filename)
    static_html, fragment_html = render_article base_dir, filename

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
end
