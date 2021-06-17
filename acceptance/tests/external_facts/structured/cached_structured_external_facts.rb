# frozen_string_literal: true

test_name 'strucutured external facts can be cached' do
  tag 'risk:high'

  require 'facter/acceptance/user_fact_utils'
  extend Facter::Acceptance::UserFactUtils

  fact_1_name = 'key1.key2'
  fact_2_name = 'key1.key3'
  fact_1_value = 'test1'
  fact_2_value = 'test2'
  fact_1_content = "#{fact_1_name}=#{fact_1_value}"
  fact_2_content = "#{fact_2_name}=#{fact_2_value}"

  cached_file_1_content = <<~RUBY
    {
      "#{fact_1_name}": "#{fact_1_value}",
      "cache_format_version": 1
    }
  RUBY

  cached_file_2_content = <<~RUBY
    {
      "#{fact_2_name}": "#{fact_2_value}",
      "cache_format_version": 1
    }
  RUBY

  config_data = <<~HOCON
    facts : {
      ttls : [
          { "fact_1.txt" : 3 days },
          { "fact_2.txt" : 3 days }
      ]
    }
    global : {
      force-dot-resolution : true
    }
  HOCON

  agents.each do |agent|
    cache_folder = get_cached_facts_dir(agent['platform'], on(agent, facter('kernelmajversion')).stdout.chomp.to_f)

    config_dir = get_default_fact_dir(agent['platform'], on(agent, facter('kernelmajversion')).stdout.chomp.to_f)
    config_file = File.join(config_dir, 'facter.conf')
    agent.mkdir_p(config_dir)
    create_remote_file(agent, config_file, config_data)

    external_dir = agent.tmpdir('facts.d')
    agent.mkdir_p(external_dir)
    create_remote_file(agent, File.join(external_dir, 'fact_1.txt'), fact_1_content)
    create_remote_file(agent, File.join(external_dir, 'fact_2.txt'), fact_2_content)

    teardown do
      agent.rm_rf(external_dir)
      agent.rm_rf(config_dir)
      agent.rm_rf(cache_folder)
    end

    step 'creates a fact_1.txt and fact_2.txt cache file that contains fact information' do
      on(agent, facter("--external-dir \"#{external_dir}\" key1 --json")) do |facter_output|
        assert_equal(
          {
            'key1' => {
              'key2' => fact_1_value,
              'key3' => fact_2_value
            }
          },
          JSON.parse(facter_output.stdout.chomp)
        )
      end

      assert_equal(true, agent.file_exist?("#{cache_folder}/fact_1.txt"))
      assert_equal(true, agent.file_exist?("#{cache_folder}/fact_2.txt"))

      assert_match(
        cached_file_1_content.chomp,
        agent.cat("#{cache_folder}/fact_1.txt").strip,
        'Expected cached external fact file to contain fact information for fact_1'
      )

      assert_match(
        cached_file_2_content.chomp,
        agent.cat("#{cache_folder}/fact_2.txt").strip,
        'Expected cached external fact file to contain fact information for fact_2'
      )
    end
  end
end
