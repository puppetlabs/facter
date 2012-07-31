VERSION_FILE = 'lib/facter.rb'

def get_current_version
  File.open( VERSION_FILE ) {|io| io.grep(/VERSION = /)}[0].split()[-1]
end

def described_version
  # This ugly bit removes the gSHA1 portion of the describe as that causes failing tests
  %x{git describe}.gsub('-', '.').split('.')[0..3].join('.').to_s.gsub('v', '')
end

namespace :package do

  desc "Bump version prior to release (internal task)"
  task :versionbump  do
    old_version =  get_current_version
    contents = IO.read(VERSION_FILE)
    new_version = '"' + described_version.to_s.strip + '"'
    contents.gsub!("VERSION = #{old_version}", "VERSION = #{new_version}")
    file = File.open(VERSION_FILE, 'w')
    file.write contents
    file.close
  end

  desc "Bump version file and build tarball"
  task :release => [ :versionbump, :default ] do
    Rake::Task[:package].invoke
  end

end # namespace

task :clean => [ :clobber_package ] do
end
