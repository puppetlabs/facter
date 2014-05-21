require 'rubygems'
require 'rubygems/package_task'

spec = Gem::Specification.load(File.join(File.dirname(__FILE__), '../cfacter.gemspec'))

Gem::PackageTask.new(spec) do |pkg|
  pkg.need_tar = true
end

desc "Install the cfacter gem."
task :install => [:gem] do |t|
  file = "cfacter-#{spec.version}.gem"
  exec "gem install #{File.join(File.dirname(__FILE__), '../pkg', file)}"
end
