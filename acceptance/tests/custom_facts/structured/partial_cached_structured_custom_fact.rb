# frozen_string_literal: true

test_name 'structured custom facts can be granually cached' do
  tag 'risk:high'

  require 'facter/acceptance/user_fact_utils'
  extend Facter::Acceptance::UserFactUtils

  fact_file = 'custom_fact.rb'
  fact_1_name = 'key1.key2'
  fact_2_name = 'key1.key3'
  fact_1_value = 'test1'
  fact_2_value = 'test2'

  fact_content = <<-RUBY
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

  cached_file_content = <<~RUBY
    {
      "#{fact_1_name}": "#{fact_1_value}",
      "cache_format_version": 1
    }
  RUBY

  config_data = <<~HOCON
    facts : {
      ttls : [
          { "cached-custom-facts" : 3 days }
      ]
    }
    fact-groups : {
      cached-custom-facts : ["#{fact_1_name}"],
    }
  HOCON

  agents.each do |agent|
    cache_folder = get_cached_facts_dir(agent['platform'], on(agent, facter('kernelmajversion')).stdout.chomp.to_f)

    config_dir = get_default_fact_dir(agent['platform'], on(agent, facter('kernelmajversion')).stdout.chomp.to_f)
    config_file = File.join(config_dir, 'facter.conf')
    agent.mkdir_p(config_dir)
    create_remote_file(agent, config_file, config_data)

    fact_dir = agent.tmpdir('custom_facts')
    fact_file = File.join(fact_dir, fact_file)
    create_remote_file(agent, fact_file, fact_content)


    teardown do
      agent.rm_rf(fact_dir)
      agent.rm_rf(config_dir)
      agent.rm_rf(cache_folder)
    end

    step 'does not create cache of part of the fact that is not in ttls' do
      on(agent, facter("--custom-dir=#{fact_dir} key1.key3"))

      result = agent.file_exist?("#{cache_folder}/cached-custom-facts")
      assert_equal(false, result)
    end

    step 'creates a cached-custom-facts cache file that contains fact information' do
      on(agent, facter("--custom-dir=#{fact_dir} key1.key2"))

      result = agent.file_exist?("#{cache_folder}/cached-custom-facts")
      assert_equal(true, result)

      cat_output = agent.cat("#{cache_folder}/cached-custom-facts")
      assert_match(
        cached_file_content.chomp,
        cat_output.strip,
        'Expected cached custom fact file to contain fact information'
      )
    end

    step 'resolves the fact' do
      on(agent, facter("--custom-dir=#{fact_dir} key1 --json")) do |facter_output|
        assert_equal(
          {
            'key1' => {
              'key2' => fact_1_value ,
              'key3' => fact_2_value
            },
          },
          JSON.parse(facter_output.stdout.chomp)
        )
      end
    end
  end
end
