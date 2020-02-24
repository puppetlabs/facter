# frozen_string_literal: true

describe Facter::Resolvers::NetKVM do
  describe '#resolve' do
    before do
      allow(Win32::Registry::HKEY_LOCAL_MACHINE).to receive(:open)
        .with('SYSTEM\\CurrentControlSet\\Services')
        .and_return(reg)
      allow(reg).to receive(:keys?)
      allow(reg).to receive(:close)
    end

    after do
      Facter::Resolvers::NetKVM.invalidate_cache
    end

    context 'when is not kvm' do
      let(:reg) { { 'puppet' => 'labs' } }

      it 'returns false' do
        expect(Facter::Resolvers::NetKVM.resolve(:kvm)).to be(false)
      end
    end

    context 'when is kvm' do
      let(:reg) { { 'puppet' => 'labs', 'netkvm' => 'info' } }

      it 'returns true' do
        expect(Facter::Resolvers::NetKVM.resolve(:kvm)).to be(true)
      end
    end
  end
end
