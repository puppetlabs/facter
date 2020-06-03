# frozen_string_literal: true

desc 'verify that commit messages match CONTRIBUTING.md requirements'
task(:commits) do
  # This rake task looks at the summary from every commit from this branch not
  # in the branch targeted for a PR. This is accomplished by using the
  # TRAVIS_COMMIT_RANGE environment variable, which is present in travis CI and
  # populated with the range of commits the PR contains. If not available, this
  # falls back to `master..HEAD` as a next best bet as `master` is unlikely to
  # ever be absent.
  commit_range = 'HEAD^..HEAD'
  puts "Checking commits #{commit_range}"
  `git log --no-merges --pretty=%s #{commit_range}`.each_line do |commit_summary|
    # This regex tests for the currently supported commit summary tokens: maint, doc, gem, or fact-<number>.
    # The exception tries to explain it in more full.
    if /^\((maint|doc|docs|gem|fact-\d+)\)|revert|merge/i.match(commit_summary).nil?
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
