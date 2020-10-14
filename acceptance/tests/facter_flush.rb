test_name 'facter should flush fact values' do
  tag 'risk:high'

  fact_content1 = <<-EOM
    require 'facter'

    Facter.add(:fact1) do
      'this should be flushed'
    end

    Facter.flush

    puts "Fact1: \#\{Facter.value(:fact1)\}"
  EOM

  fact_content2 = <<-EOM
    require 'facter'

    Facter.add(:fact2) do
      on_flush do
        puts 'before flush'
      end
    end

    Facter.flush
  EOM

  agents.each do |agent|
    fact_dir = agent.tmpdir('test_scripts')
    script_path1 = File.join(fact_dir, 'flush_test1.rb')
    script_path2 = File.join(fact_dir, 'flush_test2.rb')
    create_remote_file(agent, script_path1, fact_content1)
    create_remote_file(agent, script_path2, fact_content2)

    teardown do
      agent.rm_rf(script_path1)
      agent.rm_rf(script_path2)
    end

    step 'fact value has been flushed' do
      on(agent, "#{ruby_command(agent)} #{script_path1}") do |ruby_result|
        assert_equal('Fact1: ', ruby_result.stdout.chomp)
      end
    end

    step 'prints on_flush block gets called' do
      on(agent, "#{ruby_command(agent)} #{script_path2}") do |ruby_result|
        assert_equal('before flush', ruby_result.stdout.chomp)
      end
    end
  end
end
