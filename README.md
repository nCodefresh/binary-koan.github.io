# mingard.io
My personal website. It's built using a super simple static site generator,
written in Ruby.

## Requirements
- Ruby 2.0+ and `bundler` gem
- `less`, `less-plugin-clean-css`, `less-plugin-autoprefix` and `webpack`
  installed using npm

## Tasks
- `rake default` builds the website
- `rake server` builds the website, starts a server on port 8000 (for
  debugging purposes) and watches files for changes, recompiling as
  necessary

## Options
Put these after the rake command (eg. `rake default env=production`)
- `env=debug|production` sets the build environment. `debug` is the
  default - it will create source maps and won't minify output.
  `production` won't create source maps and will minify everything
- `out=<directory>` sets the output directory (default './build')
