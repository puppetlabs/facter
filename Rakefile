# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)
Dir.glob(File.join('tasks/**/*.rake')).each { |file| load file }

task default: :spec

desc 'verify that commit messages match CONTRIBUTING.md requirements'
task(:commits) do
  # This rake task looks at the summary from every commit from this branch not
  # in the branch targeted for a PR. This is accomplished by using the
  # TRAVIS_COMMIT_RANGE environment variable, which is present in travis CI and
  # populated with the range of commits the PR contains. If not available, this
  # falls back to `master..HEAD` as a next best bet as `master` is unlikely to
  # ever be absent.
  commit_range = ENV['TRAVIS_COMMIT_RANGE'].nil? ? 'master..HEAD' : ENV['TRAVIS_COMMIT_RANGE'].sub(/\.\.\./, '..')
  puts "Checking commits #{commit_range}"
  `git log --no-merges --pretty=%s #{commit_range}`.each_line do |commit_summary|
    # This regex tests for the currently supported commit summary tokens: maint, doc, gem, or fact-<number>.
    # The exception tries to explain it in more full.
    if /^\((maint|doc|docs|gem|fact-\d+)\)|revert/i.match(commit_summary).nil?
      raise "\n\n\n\tThis commit summary didn't match CONTRIBUTING.md guidelines:\n" \
        "\n\t\t#{commit_summary}\n" \
        "\tThe commit summary (i.e. the first line of the commit message) should start with one of:\n"  \
        "\t\t(FACT-<digits>) # this is most common and should be a ticket at tickets.puppet.com\n" \
        "\t\t(docs)\n" \
        "\t\t(docs)(DOCUMENT-<digits>)\n" \
        "\t\t(maint)\n" \
        "\t\t(gem)\n" \
        "\n\tThis test for the commit summary is case-insensitive.\n\n\n"
    else
      puts commit_summary.to_s
    end
    puts '...passed'
  end
end

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
