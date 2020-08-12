# frozen_string_literal: true

describe Facter::Resolvers::Solaris::Dmi do
  describe '#resolve' do
    subject(:resolver) { Facter::Resolvers::Solaris::Dmi }

    let(:log_spy) { instance_spy(Facter::Log) }

    before do
      resolver.instance_variable_set(:@log, log_spy)
      allow(File).to receive(:executable?).with('/usr/sbin/smbios').and_return(true)
      allow(Facter::Core::Execution).to receive(:execute)
        .with('/usr/sbin/smbios -t SMB_TYPE_BIOS', logger: log_spy)
        .and_return(load_fixture('smbios_bios').read)
      allow(Facter::Core::Execution).to receive(:execute)
        .with('/usr/sbin/smbios -t SMB_TYPE_SYSTEM', logger: log_spy)
        .and_return(load_fixture('smbios_system').read)
      allow(Facter::Core::Execution).to receive(:execute)
        .with('/usr/sbin/smbios -t SMB_TYPE_CHASSIS', logger: log_spy)
        .and_return(load_fixture('smbios_chassis').read)
    end

    after do
      Facter::Resolvers::Solaris::Dmi.invalidate_cache
    end

    it 'returns bios_release_date' do
      expect(resolver.resolve(:bios_release_date)).to eq('12/12/2018')
    end

    it 'returns bios_vendor' do
      expect(resolver.resolve(:bios_vendor)).to eq('Phoenix Technologies LTD')
    end

    it 'returns bios_version' do
      expect(resolver.resolve(:bios_version)).to eq('6.00')
    end

    it 'returns chassis_asset_tag' do
      expect(resolver.resolve(:chassis_asset_tag)).to eq('No Asset Tag')
    end

    it 'returns chassis_type' do
      expect(resolver.resolve(:chassis_type)).to eq('0x1 (other)')
    end

    it 'returns manufacturer' do
      expect(resolver.resolve(:manufacturer)).to eq('VMware, Inc.')
    end

    it 'returns product_name' do
      expect(resolver.resolve(:product_name)).to eq('VMware Virtual Platform')
    end

    it 'returns serial_number' do
      expect(resolver.resolve(:serial_number)).to eq('VMware-42 1a 46 19 2d fc 12 90-73 48 ea 8f 1a 37 cb 95')
    end

    it 'returns product_uuid' do
      expect(resolver.resolve(:product_uuid)).to eq('421a4619-2dfc-1290-7348-ea8f1a37cb95')
    end
  end
end
