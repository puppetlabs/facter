# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)
Dir.glob(File.join('tasks/**/*.rake')).each { |file| load file }

task default: :spec

def retrieve_from_keyboard
  return unless ARGV =~ /changelog/

  puts "Please provide the next release tag:\n"
  next_version = $stdin.gets.chomp
  raise(ArgumentError, ' The string that you entered is invalid!') unless /[0-9]+\.[0-9]+\.[0-9]+/.match?(next_version)

  next_version
end

if Bundler.rubygems.find_name('github_changelog_generator').any?
  require 'github_changelog_generator/task'

  GitHubChangelogGenerator::RakeTask.new :changelog do |config|
    if Rake.application.top_level_tasks.include?('changelog') &&
       ENV['CHANGELOG_GITHUB_TOKEN'].nil?
      raise 'Set CHANGELOG_GITHUB_TOKEN environment variable' /
            " eg 'export CHANGELOG_GITHUB_TOKEN=valid_token_here'"
    end

    config.user = 'puppetlabs'
    config.project = 'facter-ng'
    config.since_tag = File.read('VERSION').strip
    config.future_release = retrieve_from_keyboard
    config.exclude_labels = ['maintenance']
    config.add_pr_wo_labels = true
    config.issues = false
    config.max_issues = 100
    config.header = ''
    config.base = 'CHANGELOG.md'
    config.merge_prefix = '### UNCATEGORIZED PRS; GO LABEL THEM'
    config.configure_sections = {
      "Changed": {
        "prefix": '### Changed',
        "labels": ['backwards-incompatible']
      },
      "Added": {
        "prefix": '### Added',
        "labels": ['feature']
      },
      "Fixed": {
        "prefix": '### Fixed',
        "labels": ['bugfix']
      }
    }
  end
else
  desc 'Generate a Changelog from GitHub'
  task :changelog do
    raise <<~ERRORMESSAGE
      The changelog tasks depends on github_changelog_generator gem.
      Please install github_changelog_generator:
      ---
      Gemfile:
        optional:
          ':release':
            - gem: 'github_changelog_generator'
              condition: "Gem::Version.new(RUBY_VERSION.dup) >= Gem::Version.new('2.2.2')"
    ERRORMESSAGE
  end
end
