# frozen_string_literal: true

source ENV['GEM_SOURCE'] || 'https://rubygems.org'

gemspec name: 'facter'

group(:release, optional: true) do
  gem 'octokit', '~> 4.18.0'
end

gem 'packaging', require: false

local_gemfile = File.expand_path('Gemfile.local', __dir__)
eval_gemfile(local_gemfile) if File.exist?(local_gemfile)

group(:documentation) do
  gem 'ronn', '~> 0.7.3', require: false, platforms: [:ruby]
end
