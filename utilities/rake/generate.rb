class GeneratorTask
  def article(title, date)
    date = Date.parse(date) unless date.is_a? Date
    id = date.strftime('%Y_%m_%d_') + title.downcase.sub(/\s+/, '-').sub(/[^a-zA-Z0-9_-]+/, '')
    Dir.mkdir 'articles/' + id
    File.write 'articles/' + id + '.md', <<-EOF
---
title: #{title}
subtitle:
category:
cover: cover.jpeg
---

EOF
  end
end
