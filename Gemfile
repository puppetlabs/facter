source :rubygems

gemspec

group(:development, :test) do
  gem "rspec", "~> 2.10.0", :require => false
  gem "mocha", "~> 0.10.5", :require => false
end

if File.exists? "#{__FILE__}.local"
  eval(File.read("#{__FILE__}.local"), binding)
end

# vim:filetype=ruby
