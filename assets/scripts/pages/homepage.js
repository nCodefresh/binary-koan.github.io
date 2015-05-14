function Homepage() {
  this.path = '';
}

Homepage.prototype.setup = function() {
  console.log('setting up homepage');
}

module.exports = new Homepage();
