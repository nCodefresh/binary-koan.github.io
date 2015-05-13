require 'fileutils'
require 'open-uri'
require 'nokogiri'

MEDIUM_DIR = 'C:/Users/reaso_000/Downloads/medium-export'
STATIC_DIR = 'blog'

$image_count = 0
$output_filename = ''

def format(text)
  text.strip.gsub /\s+/, ' '
end

def format_lines(text, subsequent_indent = '')
  words = text.strip.split /\s+/
  result = ''
  line = ''
  words.each do |word|
    if line.length + word.length > 100
      result += line[0..-2] + "\n"
      line = subsequent_indent
    end
    line += word + ' '
  end
  result + line
end

def download_image(filename, output_filename)
  puts "downloading image"
  File.open output_filename, 'wb' do |image|
    image.write open(filename, ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE).read
  end
end

def add_node(file, node)
  case node.name
    when 'p'
      file.write "\n#{format_lines(node.text)}\n"
    when 'figure'
      $image_count += 1
      old_src = node.css('img')[0]['src']
      download_image old_src, "#{STATIC_DIR}/#{$output_filename}/#{$image_count}.jpeg"
      caption = node.css 'figcaption'
      alt = caption.length > 0 ? format(caption[0].text) : ""
      file.write "\n![#{alt}](#{$image_count}.jpeg)\n"
    when 'ul'
      file.write "\n"
      node.css('li').each do |li|
        file.write "- #{format_lines(li.text, '  ')}\n"
      end
    when 'h1'
      return if node['id'] == 'title'
      file.write "\n# #{format(node.text)}\n"
    when 'h2'
      file.write "\n## #{format(node.text)}\n"
    when 'h3'
      file.write "\n### #{format(node.text)}\n"
  end
end

Dir.entries(MEDIUM_DIR).each do |filename|
  next if File.directory?("#{MEDIUM_DIR}/#{filename}")

  placeholder_date = Date.today - 100
  File.open "#{MEDIUM_DIR}/#{filename}" do |f|
    $image_count = 0
    html = Nokogiri::HTML f
    title = format html.css('header > h1')[0].text

    placeholder_date += 1
    $output_filename = output_filename = placeholder_date.strftime('%Y_%m_%d_' + title.gsub(/[^a-zA-Z0-9_-]+/, '-'))
    markdown_file = File.open "#{STATIC_DIR}/#{output_filename}.md", 'w'

    subtitle = format html.css('section[data-field="subtitle"]')[0].text
    category = 'travel'
    cover = 'cover.jpeg'

    # Cover image
    Dir.mkdir "#{STATIC_DIR}/#{output_filename}"
    cover_image = html.css('section.section--first .section-backgroundImage')
    if cover_image.length > 0 && cover_image[0]['style'] =~ /background-image: url\((.+)\)/
      download_image $1, "#{STATIC_DIR}/#{output_filename}/cover.jpeg"
    end

    # YAML prefix
    markdown_file.write "---\ntitle: #{title}\nsubtitle: #{subtitle}\ncategory: #{category}\ncover: #{cover}\n---\n"

    # Content
    html.css('.section-inner').each do |section|
      section.css('p, figure, ul, h1, h2, h3').each do |node|
        puts "adding #{node.name}"
        add_node markdown_file, node
      end
    end

    markdown_file.close
  end
end

