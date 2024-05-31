# frozen_string_literal: true

describe Facter::Resolvers::Lspci do
  subject(:lspci_resolver) { Facter::Resolvers::Lspci }

  before do
    allow(Facter::Core::Execution).to receive(:execute)
      .with('lspci', logger: an_instance_of(Facter::Log)).and_return(output)
  end

  after do
    lspci_resolver.invalidate_cache
  end

  context 'when lspci fails' do
    let(:output) { '' }

    it 'returns nil' do
      expect(lspci_resolver.resolve(:vm)).to be_nil
    end
  end

  context 'when lspci detects vmware' do
    let(:output) { load_fixture('lspci_vmware').read }

    it 'returns hypervisor name' do
      expect(lspci_resolver.resolve(:vm)).to eq('vmware')
    end
  end

  context 'when lspci detects xen' do
    let(:output) { load_fixture('lspci_aws').read }

    it 'returns hypervisor name' do
      expect(lspci_resolver.resolve(:vm)).to eq('xenhvm')
    end
  end

  context 'when lspci does not detect any hypervisor' do
    let(:output) { 'lspci output with no hypervisor' }

    it 'returns nil' do
      expect(lspci_resolver.resolve(:vm)).to be_nil
    end
  end
end
