# frozen_string_literal: true

describe Facter::Resolvers::Solaris::Ldom do
  subject(:resolver) { Facter::Resolvers::Solaris::Ldom }

  let(:log_spy) { instance_spy(Facter::Log) }

  before do
    resolver.instance_variable_set(:@log, log_spy)
    allow(Facter::Core::Execution)
      .to receive(:execute)
      .with('/usr/sbin/virtinfo  -a  -p', logger: log_spy)
      .and_return(output)
  end

  after do
    resolver.invalidate_cache
  end

  context 'when syscall returns valid output' do
    let(:output) { load_fixture('virtinfo').read }

    it 'parses chassis_serial' do
      expect(resolver.resolve(:chassis_serial)).to eq('AK00358110')
    end

    it 'parses control_domain' do
      expect(resolver.resolve(:control_domain)).to eq('opdx-a0-sun2')
    end

    it 'parses domain_name' do
      expect(resolver.resolve(:domain_name)).to eq('sol11-11')
    end

    it 'parses domain_uuid' do
      expect(resolver.resolve(:domain_uuid)).to eq('415dfab4-c373-4ac0-9414-8bf00801fb72')
    end

    it 'parses role_control' do
      expect(resolver.resolve(:role_control)).to eq('false')
    end

    it 'parses role_io' do
      expect(resolver.resolve(:role_io)).to eq('false')
    end

    it 'parses role_root' do
      expect(resolver.resolve(:role_root)).to eq('false')
    end

    it 'parses role_service' do
      expect(resolver.resolve(:role_service)).to eq('false')
    end
  end

  context 'when syscall returns invalid output' do
    let(:output) { 'iNvAlId OuTpUt' }

    it 'parses chassis_serial to nil' do
      expect(resolver.resolve(:chassis_serial)).to be_nil
    end

    it 'parses control_domain to nil' do
      expect(resolver.resolve(:control_domain)).to be_nil
    end

    it 'parses domain_name to nil' do
      expect(resolver.resolve(:domain_name)).to be_nil
    end

    it 'parses domain_uuid to nil' do
      expect(resolver.resolve(:domain_uuid)).to be_nil
    end

    it 'parses role_control to nil' do
      expect(resolver.resolve(:role_control)).to be_nil
    end

    it 'parses role_io to nil' do
      expect(resolver.resolve(:role_io)).to be_nil
    end

    it 'parses role_root to nil' do
      expect(resolver.resolve(:role_root)).to be_nil
    end

    it 'parses role_service to nil' do
      expect(resolver.resolve(:role_service)).to be_nil
    end
  end

  context 'when syscall has no output' do
    let(:output) { '' }

    it 'parses chassis_serial to nil' do
      expect(resolver.resolve(:chassis_serial)).to be_nil
    end

    it 'parses control_domain to nil' do
      expect(resolver.resolve(:control_domain)).to be_nil
    end

    it 'parses domain_name to nil' do
      expect(resolver.resolve(:domain_name)).to be_nil
    end

    it 'parses domain_uuid to nil' do
      expect(resolver.resolve(:domain_uuid)).to be_nil
    end

    it 'parses role_control to nil' do
      expect(resolver.resolve(:role_control)).to be_nil
    end

    it 'parses role_io to nil' do
      expect(resolver.resolve(:role_io)).to be_nil
    end

    it 'parses role_root to nil' do
      expect(resolver.resolve(:role_root)).to be_nil
    end

    it 'parses role_service to nil' do
      expect(resolver.resolve(:role_service)).to be_nil
    end
  end
end
