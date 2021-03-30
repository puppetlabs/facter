# frozen_string_literal: true

test_name 'to_hash handles custom and external structured facts' do
  tag 'risk:high'

  require 'facter/acceptance/user_fact_utils'
  require 'facter/acceptance/api_utils'
  extend Facter::Acceptance::UserFactUtils
  extend Facter::Acceptance::ApiUtils

  fact_file = 'custom_fact.rb'
  fact_1_name = 'custom1.key2'
  fact_2_name = 'custom1.key3'
  fact_1_value = 'custom1'
  fact_2_value = 'custom2'

  custom_fact_content = <<-RUBY
  Facter.add('#{fact_1_name}', type: :structured) do
    setcode do
      "#{fact_1_value}"
    end
  end

  Facter.add('#{fact_2_name}', type: :structured) do
    setcode do
      "#{fact_2_value}"
    end
  end
  RUBY

  fact_1_name = 'external1.key2'
  fact_2_name = 'external1.key3'
  fact_1_value = 'external1'
  fact_2_value = 'external2'
  ext_fact_1_content = "#{fact_1_name}=#{fact_1_value}"
  ext_fact_2_content = "#{fact_2_name}=#{fact_2_value}"

  agents.each do |agent|
    # create custom facts
    custom_facts_dir = agent.tmpdir('custom_facts')
    fact_file = File.join(custom_facts_dir, fact_file)
    create_remote_file(agent, fact_file, custom_fact_content)

    # create external facts
    external_dir = agent.tmpdir('facts.d')
    facts_dir = File.join(external_dir, 'structured')
    agent.mkdir_p(facts_dir)
    create_remote_file(agent, File.join(facts_dir, 'fact_1.txt'), ext_fact_1_content)
    create_remote_file(agent, File.join(facts_dir, 'fact_2.txt'), ext_fact_2_content)

    teardown do
      agent.rm_rf(external_dir)
      agent.rm_rf(custom_facts_dir)
    end

    step 'returns custom and external structured facts' do
      facter_rb = facter_to_hash_rb(agent, custom_dir: custom_facts_dir, external_dir: external_dir)
      result = JSON.parse(
        on(agent, "#{ruby_command(agent)} #{facter_rb}").stdout&.strip
      )

      assert_equal(result['custom1'], { 'key2' => 'custom1', 'key3' => 'custom2' })
      assert_equal(result['external1'], { 'key2' => 'external1', 'key3' => 'external2' })
    end
  end
end
