test_name 'Facter should load facts that are placed in facter directory from all load path locations ' do
  tag 'risk:high'

  content = <<-EOM
Facter.add(:my_custom_fact) do
  setcode do
    'before_update'
  end
end
  EOM

  script_content = <<-EOM
#!/usr/bin/env ruby

require 'facter'

file_name = 'custom_fact.rb'

path = ARGV[0]
$LOAD_PATH.unshift(path)

puts Facter.value('my_custom_fact')

# change custom fact value
text = File.read(path + '/facter/' + file_name)
new_contents = text.gsub(/before_update/, "after_update")

# Write changes to the file
File.open(path + '/facter/' + file_name, "w") {|file| file.puts new_contents }

# if we don't reset, the fact is cached and the old value is displayed
Facter.reset

puts Facter.value('my_custom_fact')
  EOM


  agents.each do |agent|
    fact_temp_dir = agent.tmpdir('custom_facts')
    test_script_dir = agent.tmpdir('test_script')
    fact_dir = Pathname.new("#{fact_temp_dir}/lib/facter")

    agent.mkdir_p(fact_dir.to_s)

    fact_file = File.join(fact_dir, 'custom_fact.rb')
    test_script_file = File.join(test_script_dir, 'test_script.rb')

    create_remote_file(agent, fact_file, content)
    create_remote_file(agent, test_script_file, script_content)

    teardown do
      agent.rm_rf(fact_temp_dir)
      agent.rm_rf(test_script_dir)
    end

    step "Facter: Verify that custom fact updates it's value after updating the fact and reseting facter" do
      # use ruby provided by puppet
      on(agent, "#{ruby_command(agent)} #{test_script_file} #{fact_temp_dir}/lib") do |script_output|
        assert_match(/before_update\nafter_update/, script_output.stdout, 'Expected custom facts value before and after fact value update')
      end
    end
  end
end
