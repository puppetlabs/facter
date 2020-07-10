# frozen_string_literal: true

describe Facter::Resolvers::VirtWhat do
  subject(:virt_what_resolver) { Facter::Resolvers::VirtWhat }

  let(:log_spy) { instance_spy(Facter::Log) }

  after do
    virt_what_resolver.invalidate_cache
  end

  before do
    virt_what_resolver.instance_variable_set(:@log, log_spy)
    allow(Facter::Core::Execution).to receive(:execute).with('virt-what', logger: log_spy).and_return(content)
  end

  context 'when virt-what fails' do
    let(:content) { '' }

    it 'returns nil' do
      expect(virt_what_resolver.resolve(:vm)).to be_nil
    end
  end

  context 'when virt-what detects xen hypervisor' do
    let(:content) { load_fixture('virt-what-content').read }
    let(:result) { 'xenhvm' }

    it 'returns virtual fact' do
      expect(virt_what_resolver.resolve(:vm)).to eq(result)
    end
  end

  context 'when virt-what detects vserver' do
    let(:content) { 'linux_vserver' }
    let(:result) { 'vserver_host' }
    let(:proc_status_content) { load_fixture('proc_self_status').readlines }

    before do
      allow(Facter::Util::FileHelper).to receive(:safe_readlines).with('/proc/self/status', nil)
                                                                 .and_return(proc_status_content)
    end

    it 'returns virtual fact' do
      expect(virt_what_resolver.resolve(:vm)).to eq(result)
    end
  end

  context 'when virt-what detects kvm' do
    let(:content) { 'kvm' }
    let(:result) { 'kvm' }

    it 'returns virtual fact' do
      expect(virt_what_resolver.resolve(:vm)).to eq(result)
    end
  end
end
