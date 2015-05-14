# Should be kept in sync with common.js

module Common
  SITE_TITLE = 'Jono Mingard'

  def self.pageid_for(path)
    id = path.sub(/\.[a-z]+$/i, '').gsub(/[^a-zA-Z0-9]/, '-')
    id = 'index' if id.length == 0
    return id
  end
end
