test_name 'Facter should appropriately resolve a custom fact when it conflicts with a builtin fact' do
  tag 'risk:high'

  def create_custom_fact_on(host, custom_fact_dir, fact_file_name, fact)
    fact_file_contents = <<-CUSTOM_FACT
Facter.add(:#{fact[:name]}) do
  has_weight #{fact[:weight]}
  setcode do
    #{fact[:value]}
  end
end
CUSTOM_FACT

    fact_file_path = File.join(custom_fact_dir, fact_file_name)
    create_remote_file(host, fact_file_path, fact_file_contents)
  end

  def clear_custom_facts_on(host, custom_fact_dir)
    step "Clean-up the previous test's custom facts" do
      host.rm_rf("#{custom_fact_dir}/*")
    end
  end

  agents.each do |agent|
    custom_fact_dir = agent.tmpdir('facter')
    teardown do
      agent.rm_rf(custom_fact_dir)
    end

    fact_name = 'timezone'
    builtin_value = on(agent, facter("timezone #{@options[:trace]}")).stdout.chomp

    step "Verify that Facter uses the custom fact's value when its weight is > 0" do
      custom_fact_value = "custom_timezone"
      create_custom_fact_on(
        agent,
        custom_fact_dir,
        'custom_timezone.rb',
        name: fact_name,
        weight: 10,
        value: "'#{custom_fact_value}'"
      )

      on(agent, facter("--custom-dir \"#{custom_fact_dir}\" timezone #{@options[:trace]}")) do |result|
        assert_match(/#{custom_fact_value}/, result.stdout.chomp, "Facter does not use the custom fact's value when its weight is > 0")
      end
    end

    clear_custom_facts_on(agent, custom_fact_dir)

    step "Verify that Facter uses the builtin fact's value when all conflicting custom facts fail to resolve" do
      [ 'timezone_one.rb', 'timezone_two.rb'].each do |fact_file|
        create_custom_fact_on(
          agent,
          custom_fact_dir,
          fact_file,
          { name: fact_name, weight: 10, value: nil }
        )
      end

      on(agent, facter("--custom-dir \"#{custom_fact_dir}\" timezone #{@options[:trace]}")) do |result|
        assert_match(/#{builtin_value}/, result.stdout.chomp, "Facter does not use the builtin fact's value when all conflicting custom facts fail to resolve")
      end
    end

    step "Verify that Facter gives precedence to the builtin fact over zero weight custom facts" do
      step "when all custom facts have zero weight" do
        {
          'timezone_one.rb' => "'timezone_one'",
          'timezone_two.rb' => "'timezone_two'"
        }.each do |fact_file, fact_value|
          create_custom_fact_on(
            agent,
            custom_fact_dir,
            fact_file,
            { name: fact_name, weight: 0, value: fact_value }
          )
        end

        on(agent, facter("--custom-dir \"#{custom_fact_dir}\" timezone #{@options[:trace]}")) do |result|
          assert_match(/#{builtin_value}/, result.stdout.chomp, "Facter does not give precedence to the builtin fact when all custom facts have zero weight")
        end
      end

      clear_custom_facts_on(agent, custom_fact_dir)

      step "when some custom facts have zero weight" do
        {
          'timezone_one.rb' => { weight: 10, value: nil },
          'timezone_two.rb' => { weight: 0, value: "'timezone_two'" }
        }.each do |fact_file, fact|
          create_custom_fact_on(
            agent,
            custom_fact_dir,
            fact_file,
            fact.merge(name: fact_name)
          )
        end

        on(agent, facter("--custom-dir \"#{custom_fact_dir}\" timezone #{@options[:trace]}")) do |result|
          assert_match(/#{builtin_value}/, result.stdout.chomp, "Facter does not give precedence to the builtin fact when only some custom facts have zero weight")
        end
      end
    end
  end
end
