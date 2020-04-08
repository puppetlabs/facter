# frozen_string_literal: true

source ENV['GEM_SOURCE'] || 'https://rubygems.org'

gemspec name: 'facter'

group(:release, optional: true) do
  gem 'github_changelog_generator' if Gem::Version.new(RUBY_VERSION.dup) >= Gem::Version.new('2.3.0')
end

local_gemfile = File.expand_path('Gemfile.local', __dir__)
eval_gemfile(local_gemfile) if File.exist?(local_gemfile)
