require 'liquid'
require 'kramdown'
require 'htmlbeautifier'

require './util/common'

module Templates
  #
  # Global variables available to templates - blog helpers and so forth
  #

  @globals = { 'blog_articles' => [] }

  #
  # Basic templates
  #

  PAGE_FRAGMENT = <<-END
    <article id="{{ pageid }}" class="current" data-title="{{ attrs.page_title }}">
      {== content ==}
    </article>
  END

  PAGE_STATIC = <<-END
    <!DOCTYPE html>
    <html lang="en">
      <head>
        <title>{{ attrs.page_title }}</title>
        <link rel='stylesheet' type='text/css' href='/css/main.css' />
        <script type='text/javascript' src='/js/main.js'></script>
      </head>
      <body>
        #{PAGE_FRAGMENT}
      </body>
    </html>
  END

  #
  # Rendering
  #

  def self.render_page(base_path, page_path)
    pageid = Common.pageid_for page_path
    path = File.join base_path, page_path

    content, attrs = read_file path
    attrs['pageid'] = pageid
    if attrs['template']
      File.open 'templates/' + attrs['template'] + '.html', 'r' do |f|
        content = f.read.sub /\{==\s*content\s*==\}/, content
      end
    end

    static = render pageid, content, attrs, PAGE_STATIC
    fragment = render pageid, content, attrs, PAGE_FRAGMENT

    return static, fragment
  end

  def self.render_article(base_path, article_path)
    pageid = Common.pageid_for article_path
    path = File.join base_path, article_path

    md, attrs = read_file path
    attrs['date'] = article_date article_path
    attrs['pageid'] = pageid
    content = Kramdown::Document.new(md).to_html
    add_image_captions! content
    File.open 'templates/blogpost.html', 'r' do |f|
        content = f.read.sub /\{==\s*content\s*==\}/, content
    end

    static = render pageid, content, attrs, PAGE_STATIC
    fragment = render pageid, content, attrs, PAGE_FRAGMENT

    url = article_path[0..-4].split('_')
    attrs['url'] = '/blog/' + url.join('/')
    attrs['content'] = content
    @globals['blog_articles'].unshift attrs

    return static, fragment
  end

  private

  def self.read_file(path)
    preface = ''
    content = ''

    File.open path, 'r' do |f|
      preface = f.readline
      raise 'Files must begin with a YAML object preface' unless preface == "---\n"

      preface += f.readline until preface.end_with? "\n---\n"
      content = f.read
    end

    attrs = YAML.load(preface[0..-5]) || {}

    if attrs['title']
      attrs['page_title'] = attrs['title'] + ' - ' + Common::SITE_TITLE
    else
      attrs['page_title'] = Common::SITE_TITLE
    end

    return content, attrs
  end

  def self.render(pageid, content, attrs, template)
    template = Liquid::Template.parse template.sub('{== content ==}', content)
    return HtmlBeautifier.beautify template.render(
      'pageid' => pageid, 'attrs' => attrs, 'global' => @globals
    )
  end

  def self.article_date(path)
    parts = path.split '_'
    return Date.new parts[0].to_i, parts[1].to_i, parts[2].to_i
  end

  def self.add_image_captions!(html)
    html.gsub! /(<img src=".+" alt="(.+)" \/>)/, '\1<span class="caption">\2</span>'
  end
end
