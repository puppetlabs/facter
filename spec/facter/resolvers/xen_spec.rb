# frozen_string_literal: true

describe Facter::Resolvers::Xen do
  subject(:xen_resolver) { Facter::Resolvers::Xen }

  let(:proc_xen_file) { false }
  let(:xvda1_file) { false }

  before do
    allow(File).to receive(:exist?).with('/dev/xen/evtchn').and_return(evtchn_file)
    allow(File).to receive(:exist?).with('/proc/xen').and_return(proc_xen_file)
    allow(File).to receive(:exist?).with('/dev/xvda1').and_return(xvda1_file)
    xen_resolver.invalidate_cache
  end

  context 'when is priviledged xen' do
    let(:evtchn_file) { true }

    it 'returns xen0' do
      expect(xen_resolver.resolve(:vm)).to eq('xen0')
    end

    it 'does not check other files' do
      expect(File).not_to have_received(:exist?).with('/proc/xen')
    end
  end

  context 'when is unpriviledged xen' do
    let(:evtchn_file) { false }
    let(:xvda1_file) { true }

    it 'returns xenu' do
      expect(xen_resolver.resolve(:vm)).to eq('xenu')
    end
  end
end
