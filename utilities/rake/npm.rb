class NpmTask
  def check_for_npm
    `npm --version`
  rescue Errno::ENOENT
    raise 'npm not found'
  end

  def check_installed(*packages)
    packages.each do |package|
      puts "  Checking for #{package} ..."
      output = `npm ls #{package} -g`

      try_install package if output.include? '(empty)'
    end
  end

  private

  def try_install(package)
    puts '  Not found, trying to install.'
    output = `npm install -g #{package}`
    unless $? == 0
      puts
      puts output
      raise "#{package} not found; tried to install but it failed."
    end
  end
end
