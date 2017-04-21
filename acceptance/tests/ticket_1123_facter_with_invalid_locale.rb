test_name 'C89524: facter should not crash with invalid locale setting' do
  tag 'risk:high'

  confine :except, :platform => 'windows'
  confine :except, :platform => /^cisco_/ # See CISCO-43
  confine :except, :platform => /^huawei/ # See HUAWEI-24

  agents.each do |agent|
    step 'facter should run when started with an invalid locale' do
      on(agent, facter('facterversion'), :environment => {'LANG' => 'ABCD'}) do |facter_output|
        assert_match(/^\d+\.\d+\.\d+$/, facter_output.stdout, 'facter did not continue running')

        if agent['platform'] !~ /solaris|aix|cumulus|osx/
          step 'facter should return an error message when started with an invalid locale' do
            assert_match(/locale environment variables were bad; continuing with LANG=C LC_ALL=C/, facter_output.stderr,
                         'Expected facter to return a locale error message')
          end
        end
      end
    end
  end
end
