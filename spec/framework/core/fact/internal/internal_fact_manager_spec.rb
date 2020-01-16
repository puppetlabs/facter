# frozen_string_literal: true

describe 'InternalFactManager' do
  describe '#resolve_facts' do
    it 'resolved one core fact' do
      ubuntu_os_name = double(Facter::Debian::OsName)

      resolved_fact = mock_resolved_fact('os', 'Ubuntu', nil, [])

      allow(ubuntu_os_name).to receive(:new).and_return(ubuntu_os_name)
      allow(ubuntu_os_name).to receive(:call_the_resolver).and_return(resolved_fact)

      searched_fact = double(Facter::SearchedFact, name: 'os', fact_class: ubuntu_os_name, filter_tokens: [],
                                                   user_query: '', type: :core)

      core_fact_manager = Facter::InternalFactManager.new
      resolved_facts = core_fact_manager.resolve_facts([searched_fact])

      expect(resolved_facts).to eq([resolved_fact])
    end

    it 'resolved one legacy fact' do
      windows_networking_interface = double(Facter::Windows::NetworkInterfaces)

      resolved_fact = mock_resolved_fact('network_Ethernet0', '192.168.5.121', nil, [], :legacy)

      allow(windows_networking_interface).to receive(:new).and_return(windows_networking_interface)
      allow(windows_networking_interface).to receive(:call_the_resolver).and_return(resolved_fact)

      searched_fact = double(Facter::SearchedFact, name: 'network_.*', fact_class: windows_networking_interface,
                                                   filter_tokens: [], user_query: '', type: :core)

      core_fact_manager = Facter::InternalFactManager.new
      resolved_facts = core_fact_manager.resolve_facts([searched_fact])

      expect(resolved_facts).to eq([resolved_fact])
    end
  end
end
