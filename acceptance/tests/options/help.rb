# This test is intended to ensure that the --help command-line option works
# properly. This option prints usage information and available command-line
# options.
test_name 'C99984: --help command-line option prints usage information to stdout' do

  agents.each do |agent|
    step "Agent #{agent}: retrieve usage info from stdout using --help option" do
      on(agent, facter("--help #{@options[:trace]}")) do
        assert_match(/(facter|facter-ng) \[options\] \[query\] \[query\] \[...\]/, stdout, 'Expected stdout to contain usage information')
      end
    end

    step 'Facter help should list options with minus sign' do
      options = %w[
        --no-color
        --custom-dir
        --external-dir
        --log-level
        --no-block
        --no-cache
        --no-custom-facts
        --no-external-facts
        --no-ruby
        --show-legacy
        --list-block-groups
        --list-cache-groups
      ]
      on(agent, facter("--help #{@options[:trace]}")) do
        options.each do |option|
          assert_match(/#{option}/, stdout, "Key: #{option} not found in help description")
        end
      end
    end
  end
end
