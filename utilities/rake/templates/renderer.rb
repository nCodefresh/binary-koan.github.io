require 'liquid'
require 'kramdown'
require 'htmlbeautifier'

require_relative '../../common'

module TemplateRenderer
  @template_globals = { 'blog_articles' => [] }

  #
  # Basic templates
  #

  TEMPLATES_DIR = File.dirname(__FILE__)

  PAGE_FRAGMENT = <<-END
    <article id="{{ pageid }}" class="current" data-title="{{ attrs.page_title }}">
      {{ content }}
    </article>
  END

  PAGE_STATIC = <<-END
    <!DOCTYPE html>
    <html lang="en">
      <head>
        <title>{{ attrs.page_title }}</title>
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <link href='http://fonts.googleapis.com/css?family=Lato:400,700,400italic' rel='stylesheet' type='text/css'>
        <link rel='stylesheet' type='text/css' href='/fonts/blackjack.css' />
        <link rel='stylesheet' type='text/css' href='/styles/main.css' />
        <script type='text/javascript' src='/scripts/main.js'></script>
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
      File.open "#{TEMPLATES_DIR}/#{attrs['template']}.html", 'r' do |f|
        content = f.read.sub /\{\{\s*content\s*\}\}/, content
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
    File.open "#{TEMPLATES_DIR}/blogpost.html", 'r' do |f|
        content = f.read.split(/\{\{\s*content\s*\}\}/).join content
    end

    static = render pageid, content, attrs, PAGE_STATIC
    fragment = render pageid, content, attrs, PAGE_FRAGMENT

    url = article_path[0..-4].split('_')
    attrs['url'] = '/blog/' + url.join('/')
    attrs['content'] = content
    @template_globals['blog_articles'].unshift attrs

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
    template = Liquid::Template.parse template.sub('{{ content }}', content)
    HtmlBeautifier.beautify template.render(
      'pageid' => pageid, 'attrs' => attrs, 'global' => @template_globals
    )
  end

  def self.article_date(path)
    parts = path.split '_'
    Date.new parts[0].to_i, parts[1].to_i, parts[2].to_i
  end

  def self.add_image_captions!(html)
    html.gsub! /(<img src=".+" alt="(.+)" \/>)/, '\1<span class="caption">\2</span>'
  end
end
