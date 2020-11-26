# frozen_string_literal: true

describe Facter::Resolvers::Freebsd::Virtual do
  subject(:jail_resolver) { Facter::Resolvers::Freebsd::Virtual }

  after do
    jail_resolver.invalidate_cache
  end

  before do
    allow(Facter::Freebsd::FfiHelper).to receive(:sysctl_by_name).with(:long, 'security.jail.jailed').and_return(jailed)
    allow(Facter::Freebsd::FfiHelper).to receive(:sysctl_by_name).with(:string, 'kern.vm_guest').and_return(vm)
  end

  let(:jailed) { 0 }
  let(:vm) { nil }

  context 'when not jailed' do
    context 'when running on bare metal' do
      it 'returns nil' do
        expect(jail_resolver.resolve(:vm)).to be_nil
      end
    end

    context 'when running in a vm' do
      let(:vm) { 'xen' }

      it 'returns xen' do
        expect(jail_resolver.resolve(:vm)).to eq('xenu')
      end
    end
  end

  context 'when jailed' do
    let(:jailed) { 1 }

    context 'when running on bare metal' do
      it 'returns jail' do
        expect(jail_resolver.resolve(:vm)).to eq('jail')
      end
    end

    context 'when running in a vm' do
      let(:vm) { 'xen' }

      it 'returns jail' do
        expect(jail_resolver.resolve(:vm)).to eq('jail')
      end
    end
  end
end
