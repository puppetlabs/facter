# We need access to the Puppet.version method
$LOAD_PATH.unshift(File.expand_path("lib"))
require 'facter/version'

RAKE_ROOT = File.expand_path(File.dirname(__FILE__))

$LOAD_PATH << File.join(RAKE_ROOT, 'tasks')

require 'rake'
Dir['tasks/**/*.rake'].each { |t| load t }

['rubygems', 'rspec', 'rspec/core/rake_task','rcov', 'packaging'].each do |lib|
  begin
    require lib
  rescue LoadError
  end
end

#load packaging tasks
Pkg::Util::RakeUtils.load_packaging_tasks if defined?(Pkg)

namespace :package do
  task :bootstrap do
    puts 'Bootstrap is no longer needed, using packaging-as-a-gem'
  end
  task :implode do
    puts 'Implode is no longer needed, using packaging-as-a-gem'
  end
end

if defined?(RSpec::Core::RakeTask)
  desc "Run all specs"
  RSpec::Core::RakeTask.new do |t|
    t.pattern ='spec/{unit,integration}/**/*_spec.rb'
    t.fail_on_error = true
  end

  RSpec::Core::RakeTask.new('spec:rcov') do |t|
    t.pattern ='spec/{unit,integration}/**/*_spec.rb'
    t.fail_on_error = true
    if defined?(Rcov)
      t.rcov = true
      t.rcov_opts = ['--exclude', 'spec/*,test/*,results/*,/usr/lib/*,/usr/local/lib/*,gems/*']
    end
  end
end
