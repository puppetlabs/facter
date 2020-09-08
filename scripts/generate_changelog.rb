#!/usr/bin/env ruby
# frozen_string_literal: true

require 'octokit'

class ChangelogGenerator
  attr_reader :version, :entries, :unlabeled_prs

  def initialize(version)
    unless version
      warn 'Usage: generate_changelog.rb VERSION'
      exit 1
    end

    @version = version
    @entries = {
      'feature' => { name: 'Added', entries: {} },
      'bugfix' => { name: 'Fixed', entries: {} },
      'backwards-incompatible' => { name: 'Changed', entries: {} }
    }

    @unlabeled_prs = []

    # Setting the changelog path early lets us check that it exists
    # before we spend time making API calls
    changelog
  end

  def labels
    @entries.keys
  end

  def client
    unless @client
      unless ENV['GITHUB_TOKEN']
        warn 'Missing GitHub personal access token. Set $GITHUB_TOKEN with a '\
             'personal access token to use this script.'
        exit 1
      end

      Octokit.configure do |c|
        c.auto_paginate = true
      end

      @client = Octokit::Client.new(access_token: ENV['GITHUB_TOKEN'])
    end

    @client
  end

  def latest
    @latest ||= client.latest_release('puppetlabs/facter').tag_name
  end

  def commits
    @commits ||= client.compare('puppetlabs/facter', latest, 'main').commits
  end

  def changelog
    unless @changelog
      @changelog = File.expand_path('CHANGELOG.md', Dir.pwd)

      unless File.file?(@changelog)
        warn "Unable to find changelog at #{@changelog}"
        exit 1
      end
    end

    @changelog
  end

  # Parses individual commits by scanning the commit message for valid release notes
  # and adding them to the list of entries. Entries include extra information about
  # the author and whether it was an internal or external contribution so we can give
  # kudos.
  def parse_commit(commit)
    prs = client.commit_pulls('puppetlabs/facter', commit.sha, { accept: 'application/vnd.github.groot-preview+json' })

    prs.each do |pr|
      next if pr[:state] != 'closed' && pr[:merged_at].nil?

      if pr[:labels].nil? || pr[:labels].empty?
        unlabeled_prs << pr[:html_url] unless unlabeled_prs.include?(pr[:html_url])
      end

      pr[:labels].each do |label|
        next unless entries.key?(label[:name])

        entries[label[:name]][:entries][pr[:html_url]] = {
          title: pr[:title],
          number: pr[:number],
          url: pr[:html_url],
          author: pr[:user][:login],
          profile: pr[:user][:html_url]
        }
      end
    end
  end

  def update_changelog
    old_lines = File.read(changelog).split("\n")

    new_lines = [
      "## [#{version}](https://github.com/puppetlabs/facter/tree/#{version}) (#{Time.now.strftime '%Y-%m-%d'})\n",
      "[Full Changelog](https://github.com/puppetlabs/facter/compare/#{latest}...#{version})"
    ]

    entries.each_value do |type|
      next unless type[:entries].any?

      new_lines << "\n### #{type[:name]}\n"

      type[:entries].each do |_, entry|
        new_lines << "- #{entry[:title].strip} [\##{entry[:number]}](#{entry[:url]})" \
                     " ([#{entry[:author]}](#{entry[:profile]}))"
      end
    end

    new_lines = check_unlabeled_prs(new_lines)

    content = (new_lines + ["\n"] + old_lines).join("\n")

    if File.write(changelog, content)
      puts "Successfully wrote entries to #{changelog}"
    else
      warn "Unable to write entries to #{changelog}"
      exit 1
    end
  end

  def check_unlabeled_prs(content)
    return content unless unlabeled_prs.any?

    content << "\n### Unlabeled PRs:\n"
    unlabeled_prs.each do |pr|
      content << "- #{pr}"
    end

    content
  end

  def generate
    puts "Loading and parsing commits for #{latest}..main"

    commits.each do |commit|
      parse_commit(commit)
    end

    if entries.each_value.all? { |type| type[:entries].empty? }
      warn "No release notes for #{latest}..main"
      exit 0
    end

    update_changelog
  end
end

ChangelogGenerator.new(ARGV.first).generate if $PROGRAM_NAME == __FILE__
