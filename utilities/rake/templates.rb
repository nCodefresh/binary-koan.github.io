require_relative 'templates/renderer'

class TemplatesTask
  def initialize
    super
  end

  def build_articles
    path = $config[:articles_path]
    Dir.entries(path).sort.each do |filename|
      if File.directory?(File.join(path, filename)) and not filename =~ /\.\.?/
        copy_article_assets path, filename
      elsif filename.end_with?('.md')
        compile_article path, filename
      end
    end
  end

  def build_article(filename)
    path = $config[:articles_path]
    compile_article path, filename
    assets_dir = "#{path}/#{filename}"[0..-4]
    if File.exists?(assets_dir) and File.directory?(assets_dir)
      copy_article_assets path, filename[0..-4]
    end
  end

  def build_pages
    path = $config[:pages_path]
    Dir.entries(path).each do |filename|
      if filename.end_with?('.html') and not File.directory?(File.join(path, filename))
        compile_page path, filename
      end
    end
  end

  def build_page filename
    compile_page $config[:pages_path], filename
  end

  private

  def article_build_dir(path, filename)
    subpath = filename.split('_') # Remove '.md' and split into desired subdirs
    build_path = File.join $config[:build_path], 'blog', *subpath
    FileUtils.mkdir_p build_path
    build_path
  end

  def compile_article(path, filename)
    static_html, fragment_html = TemplateRenderer.render_article path, filename

    build_dir = article_build_dir path, filename[0..-4]

    File.write File.join(build_dir, 'index.html'), static_html
    build_dir << '.fragment.html'
    File.write build_dir, fragment_html
  end

  def copy_article_assets(path, filename)
    build_dir = article_build_dir path, filename

    Dir.entries(File.join(path, filename)).each do |asset|
      next if File.directory? asset
      FileUtils.copy File.join(path, filename, asset), File.join(build_dir, asset)
    end
  end

  def compile_page(path, filename)
    static_html, fragment_html = TemplateRenderer.render_page path, filename

    # Special case for homepage
    if filename == 'index.html'
      static_filename = $config[:build_path] + '/index.html'
      fragment_filename = $config[:build_path] + '/index.fragment.html'
    else
      build_path = "#{$config[:build_path]}/#{filename[0..-6]}" # Remove '.html'
      FileUtils.mkdir_p build_path
      static_filename = "#{build_path}/index.html"
      fragment_filename = "#{build_path}.fragment.html"
    end

    File.write static_filename, static_html
    File.write fragment_filename, fragment_html
  end
end
