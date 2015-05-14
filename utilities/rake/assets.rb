class AssetsTask
  def compile_styles(source_file, build_file)
    check_npm_command 'lessc', 'less'

    extra_args = '--source-map' if BUILD_ENV == 'debug'

    output = `lessc #{source_file} #{build_file} #{extra_args}`
    unless $? == 0
      puts 'ERROR (lessc):'
      puts output
      return
    end

    puts '    Copying original files ...'
    FileUtils.mkdir_p 'build/assets/styles'
    FileUtils.copy_entry 'assets/styles', 'build/assets/styles'
  end

  def compile_scripts(source_file, build_file)
    check_npm_command 'webpack', 'webpack'

    extra_args = '-d' if BUILD_ENV == 'debug'
    source_files = Dir.glob("#{File.dirname(source_file)}/*.js").join(' ') + ' ' + source_file

    output = `webpack #{source_files} #{build_file} #{extra_args}`
    unless $? == 0
      puts 'ERROR (webpack):'
      puts output
    end
  end

  def copy_assets(source_dir, build_dir)
    FileUtils.copy_entry source_dir, build_dir
  end

  private

  def check_npm_command(command, package_name)
    puts "    Checking for #{command} ..."
    `#{command} --help 2>&1`
  rescue Errno::ENOENT
    output = `npm install -g #{package_name}`
    unless $? == 0
      puts
      puts output
      raise '#{package_name} not found; tried to install but it failed.'
    end
  end
end
