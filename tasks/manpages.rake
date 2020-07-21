# frozen_string_literal: true

desc 'Build Facter manpages'
task :gen_manpages do
  require 'fileutils'

  ronn_args = '--manual="Facter manual" --organization="Puppet, Inc." --roff'

  # Locate ronn
  begin
    require 'ronn'
  rescue LoadError
    abort('Run `bundle install --with documentation` to install the `ronn` gem.')
  end

  ronn = `which ronn`.chomp

  abort('Ronn does not appear to be installed') unless File.executable?(ronn)

  FileUtils.mkdir_p('./man/man8')

  `RUBYLIB=./lib:$RUBYLIB bin/facter --man > ./man/man8/facter.8.ronn`
  `#{ronn} #{ronn_args} ./man/man8/facter.8.ronn`
  FileUtils.rm('./man/man8/facter.8.ronn')
end
