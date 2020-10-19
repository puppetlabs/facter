test_name 'facter should not update it`s session cache in same session' do
  tag 'risk:high'

  fact_content = <<-EOM
    require 'facter'
    
    seconds_before = Facter.value('system_uptime.seconds')
    sleep(3)
    seconds_after = Facter.value('system_uptime.seconds')
    
    puts seconds_before == seconds_after
  EOM

  agents.each do |agent|
    fact_dir = agent.tmpdir('test_scripts')
    script_path = File.join(fact_dir, 'session_test.rb')
    create_remote_file(agent, script_path, fact_content)

    teardown do
      agent.rm_rf(script_path)
    end

    on(agent, "#{ruby_command(agent)} #{script_path}") do |ruby_result|
      assert_equal('true', ruby_result.stdout.chomp, 'Expect the session cache is not reset in same session')
    end
  end
end
