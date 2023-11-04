# frozen_string_literal: true

describe Facter::Resolvers::Openbsd::Virtual do
  subject(:resolver) { Facter::Resolvers::Openbsd::Virtual }

  let(:vm) { 'VMM' }

  after do
    resolver.invalidate_cache
  end

  before do
    allow(Facter::Bsd::FfiHelper)
      .to receive(:sysctl)
      .with(:string, [6, 15])
      .and_return(vm)
  end

  context 'when running on bare metal' do
    let(:vm) { nil }

    it 'returns nil' do
      expect(resolver.resolve(:vm)).to be_nil
    end
  end

  context 'when running in a vm' do
    it 'returns VMM' do
      expect(resolver.resolve(:vm)).to eq('vmm')
    end
  end
end
