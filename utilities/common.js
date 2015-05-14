// Should be kept in sync with common.rb

var Common = {
  SITE_TITLE: 'Jono Mingard',

  pageidFor: function(path) {
    var id = path.replace(/\.[a-z]+$/i, '').replace(/[^a-zA-Z0-9]/g, '-');
    if (id.length === 0) id = 'index';
    return id;
  }
};

module.exports = Common;
