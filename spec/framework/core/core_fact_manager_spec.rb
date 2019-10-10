# frozen_string_literal: true

describe 'CoreFactManager' do
  describe '#resolve_facts' do
    it 'resolved one core fact' do
      ubuntu_os_name = double(Facter::Ubuntu::OsName)

      resolved_fact = mock_resolved_fact('os', 'Ubuntu', '', [])

      allow(ubuntu_os_name).to receive(:new).and_return(ubuntu_os_name)
      allow(ubuntu_os_name).to receive(:call_the_resolver).and_return(resolved_fact)

      searched_fact =
        double(Facter::SearchedFact, name: 'os', fact_class: ubuntu_os_name, filter_tokens: [], user_query: '')

      core_fact_manager = Facter::CoreFactManager.new
      resolved_facts = core_fact_manager.resolve_facts([searched_fact])

      expect(resolved_facts).to eq([resolved_fact])
    end

    it 'resolved one legacy fact' do
      ubuntu_networking_interface = double(Facter::Ubuntu::NetworkInterface)
      resolved_fact = mock_resolved_fact('ipaddress_ens160', '192.168.5.121', '', [])

      allow(ubuntu_networking_interface).to receive(:new).and_return(ubuntu_networking_interface)
      allow(ubuntu_networking_interface).to receive(:call_the_resolver).and_return(resolved_fact)

      searched_fact = double(Facter::SearchedFact, name: 'ipaddress_.*', fact_class: ubuntu_networking_interface,
                                                   filter_tokens: [], user_query: '')

      core_fact_manager = Facter::CoreFactManager.new
      resolved_facts = core_fact_manager.resolve_facts([searched_fact])

      expect(resolved_facts).to eq([resolved_fact])
    end
  end
end
