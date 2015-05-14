class AssetsTask
  def compile_styles
    check_npm_command 'lessc', 'less'
    extra_args = '--source-map' if $config[:env] == 'debug'

    $config[:styles].each do |source_file, build_file|
      compile_stylesheet source_file, "#{$config[:build_path]}/#{build_file}", extra_args
    end

    if $config[:env] == 'debug'
      puts '    Copying original files ...'
      FileUtils.mkdir_p 'build/assets/styles'
      FileUtils.copy_entry 'assets/styles', 'build/assets/styles'
    end
  end

  def compile_scripts
    check_npm_command 'webpack', 'webpack'
    extra_args = '-d' if $config[:env] == 'debug'

    $config[:scripts].each do |source_file, build_file|
      compile_script source_file, "#{$config[:build_path]}/#{build_file}", extra_args
    end
  end

  def copy_public
    FileUtils.copy_entry $config[:public_path], $config[:build_path]
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

  def compile_stylesheet(source_file, build_file, extra_args)
    output = `lessc #{source_file} #{build_file} #{extra_args}`
    unless $? == 0
      puts 'ERROR (lessc):'
      puts output
    end
  end

  def compile_script(source_file, build_file, extra_args)
    sources = Dir.glob("#{File.dirname(source_file)}/*.js").join(' ') + ' ' + source_file
    output = `webpack #{sources} #{build_file} #{extra_args}`
    unless $? == 0
      puts 'ERROR (webpack):'
      puts output
    end
  end
end
