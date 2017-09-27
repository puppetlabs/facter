test_name 'C14514: Running facter should not output anything to stderr' do
  tag 'risk:high'

  require 'facter/acceptance/user_fact_utils'
  extend Facter::Acceptance::UserFactUtils

  agents.each do |agent|
    on(agent, facter) do |facter_output|
      assert_match(/hostname\s*=>\s*\S*/, facter_output.stdout, 'Hostname fact is missing')
      # NOTE: stderr should be empty here. The other case for power linux machines is
      # necessary until FACT-1765 is resolved.
      if power_linux?(agent)
        assert_match(/dmidecode not found at configured location/, facter_output.stderr, 'Facter should have written a warning regarding a missing dmidecode component')
      else
        assert_empty(facter_output.stderr, 'Facter should not have written to stderr')
      end
    end
  end
end
