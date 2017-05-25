test_name 'C100202: Facter identity facts resolve on all platforms' do
  tag 'risk:high'

  require 'json'

  agents.each do |agent|
    step 'Ensure the identity fact resolves as expected' do
      if agent['platform'] =~ /windows/
        # Regular expression to validate the username from facter in the form of '<domain>\<username>'
        # Reference - https://msdn.microsoft.com/en-us/library/bb726984.aspx
        # - The domain name can be any character or empty
        # - Must contain a backslash between the domain and username
        # - Username must be at least one character and not contain the following charaters; " / \ [ ] : ; | = , + * ? < >
        expected_identity = {
            'user'       => /.*\\[^\\\/\"\[\]:|<>+=;,?*@]+$/,
            'privileged' => 'true'
        }
      elsif agent['platform'] =~ /aix-/
        expected_identity = {
            'gid'        => '0',
            'group'      => 'system',
            'uid'        => '0',
            'user'       => 'root',
            'privileged' => 'true'
        }
      elsif agent['platform'] =~ /osx-/
        expected_identity = {
            'gid'        => '0',
            'group'      => 'wheel',
            'uid'        => '0',
            'user'       => 'root',
            'privileged' => 'true'
        }
      else
        expected_identity = {
            'gid'        => '0',
            'group'      => 'root',
            'uid'        => '0',
            'user'       => 'root',
            'privileged' => 'true'
        }
      end

      on(agent, facter('--json')) do |facter_result|
        results = JSON.parse(facter_result.stdout)
        expected_identity.each do |fact, value|
          assert_match(value, results['identity'][fact].to_s, "Incorrect fact value for identity.#{fact}")
        end
      end
    end
  end
end
