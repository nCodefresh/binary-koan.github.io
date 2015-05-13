module.exports = function() {
  var pages = {};
  for(var i = 0; i < arguments.length; ++i) {
    var currentPage = require(arguments[i]);
    pages[currentPage.path] = currentPage;
  }
  return pages;
}
