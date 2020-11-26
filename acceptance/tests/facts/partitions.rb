test_name "C96148: verify partitions facts" do
  tag 'risk:high'

  confine :except, :platform => 'osx' # no partitions on osx
  confine :except, :platform => 'windows' # no partitions on windows
  confine :except, :platform => 'solaris' # no partitions on solaris

  require 'json'

  possible_facts = [
      ['backing_file', /^\/.*/],
      ['filesystem', /\w/],
      ['uuid', /^[-a-zA-Z0-9]+$/],
      ['partuuid', /^[-a-f0-9]+$/],
      ['mount', /^\/.*/],
      ['label', /.*/],
      ['partlabel', /\w+/],
  ]

  agents.each do |agent|
    step("verify that partitions contain facts") do
      on(agent, facter("--json partitions #{@options[:trace]}")) do |facter_output|
        facter_results = JSON.parse(facter_output.stdout)
        facter_results['partitions'].each_key do |partition_name|
          partition_facts = facter_results['partitions'][partition_name]
          assert_match(/\d+\.\d+ [TGMK]iB/, partition_facts['size'], "Expected partition '#{partition_name}' fact 'size' to match expression")
          assert(partition_facts['size_bytes'] >= 0, "Expected partition '#{partition_name}' fact 'size_bytes' to be positive")
          possible_facts.each do |fact, expression|
            unless partition_facts[fact].nil?
              assert_match(expression, partition_facts[fact], "Expected partition '#{partition_name}' fact '#{fact}' to match expression")
            end
          end
        end
      end
    end
  end
end
