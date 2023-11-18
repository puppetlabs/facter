# frozen_string_literal: true

describe Facter::Resolvers::Openbsd::Virtual do
  subject(:resolver) { Facter::Resolvers::Openbsd::Virtual }

  after do
    resolver.invalidate_cache
  end

  before do
    allow(Facter::Bsd::FfiHelper)
      .to receive(:sysctl)
      .with(:string, [6, 15])
      .and_return(vm)
  end

  let(:vm) { nil }

  context 'when running on bare metal' do
    let(:vm) { 'physical' }

    it 'returns physical' do
      expect(resolver.resolve(:vm)).to eq('physical')
    end
  end

  context 'when running in a vm' do
    let(:vm) { 'VMM' }

    it 'returns VMM' do
      expect(resolver.resolve(:vm)).to eq('vmm')
    end
  end
end
