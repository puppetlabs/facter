# This test verifies that the numbers for file systems sizes are positive from "facter" and "puppet facts"
# This is a regression test for FACT-1578
test_name "C100110: verify that file system sizes are positive" do
  tag 'risk:high'

  confine :except, :platform => 'windows' # Windows does not list mount points as facts like Unix
  confine :to, :platform => /skip/

  require 'json'

  agents.each do |agent|
    step("verify that facter returns positive numbers for the mount points byte fields") do

      on(agent, facter("--json")) do |facter_output|
        facter_results = JSON.parse(facter_output.stdout)
        facter_results['mountpoints'].each_key do |mount_key|
          ['available_bytes', 'size_bytes', 'used_bytes'].each do |sub_key|
            assert_operator(facter_results['mountpoints'][mount_key][sub_key], :>=, 0,
                            "Expected the #{sub_key} from facter to be positive for #{mount_key}")
          end
        end
      end
    end

    step("verify that puppet facts returns positive numbers for the mount points byte fields") do

      on(agent, puppet("facts --render-as json")) do |puppet_facts|
        puppet_results = JSON.parse(puppet_facts.stdout)
        puppet_results['mountpoints'].each_key do |mount_key|
          ['available_bytes', 'size_bytes', 'used_bytes'].each do |sub_key|
            assert_operator(puppet_results['mountpoints'][mount_key][sub_key], :>=, 0,
                            "Expected the #{sub_key} from puppet facts to be positive for #{mount_key}")
          end
        end
      end
    end
  end
end
