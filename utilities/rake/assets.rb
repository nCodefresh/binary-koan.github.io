class AssetsTask
  def compile_styles
    if $config[:env] == 'debug'
      extra_args = '--source-map'
    else
      extra_args = '--clean-css'
    end

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
    if $config[:env] == 'debug'
      extra_args = '-d'
    else
      extra_args = '--optimize-minimize'
    end

    $config[:scripts].each do |source_file, build_file|
      compile_script source_file, "#{$config[:build_path]}/#{build_file}", extra_args
    end
  end

  def copy_public
    FileUtils.copy_entry $config[:public_path], $config[:build_path]
  end

  private

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
