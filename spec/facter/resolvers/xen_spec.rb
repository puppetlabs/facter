# frozen_string_literal: true

describe Facter::Resolvers::Xen do
  subject(:xen_resolver) { Facter::Resolvers::Xen }

  let(:proc_xen_file) { false }
  let(:xvda1_file) { false }
  let(:log_spy) { instance_spy(Facter::Log) }
  let(:domains) { '' }

  before do
    xen_resolver.instance_variable_set(:@log, log_spy)
    allow(File).to receive(:exist?).with('/dev/xen/evtchn').and_return(evtchn_file)
    allow(File).to receive(:exist?).with('/proc/xen').and_return(proc_xen_file)
    allow(File).to receive(:exist?).with('/dev/xvda1').and_return(xvda1_file)
    allow(File).to receive(:exist?).with('/usr/lib/xen-common/bin/xen-toolstack').and_return(false)
    allow(File).to receive(:exist?).with('/usr/sbin/xl').and_return(false)
    allow(File).to receive(:exist?).with('/usr/sbin/xm').and_return(true)
    allow(Facter::Core::Execution).to receive(:execute).with('/usr/sbin/xm list', logger: log_spy).and_return(domains)

    xen_resolver.invalidate_cache
  end

  after do
    xen_resolver.invalidate_cache
  end

  context 'when xen is privileged' do
    context 'when /dev/xen/evtchn exists' do
      let(:domains) { load_fixture('xen_domains').read }
      let(:evtchn_file) { true }

      it 'returns xen0' do
        expect(xen_resolver.resolve(:vm)).to eq('xen0')
      end

      it 'detects xen as privileged' do
        expect(xen_resolver.resolve(:privileged)).to be_truthy
      end

      it 'does not check other files' do
        expect(File).not_to have_received(:exist?).with('/proc/xen')
      end

      it 'returns domains' do
        expect(xen_resolver.resolve(:domains)).to eq(%w[win linux])
      end
    end

    context 'when /dev/xen/evtchn does not exist' do
      let(:evtchn_file) { false }

      before do
        allow(Facter::Util::FileHelper)
          .to receive(:safe_read)
          .with('/proc/xen/capabilities', nil)
          .and_return('control_d')
      end

      it 'detects xen as privileged' do
        expect(xen_resolver.resolve(:privileged)).to be_truthy
      end
    end
  end

  context 'when xen is unprivileged' do
    let(:evtchn_file) { false }
    let(:xvda1_file) { true }

    before do
      allow(Facter::Util::FileHelper)
        .to receive(:safe_read)
        .with('/proc/xen/capabilities', nil)
        .and_return(nil)
    end

    it 'returns xenu' do
      expect(xen_resolver.resolve(:vm)).to eq('xenu')
    end

    it 'detects xen as unprivileged' do
      expect(xen_resolver.resolve(:privileged)).to be_falsey
    end

    it 'does not detect domains' do
      expect(xen_resolver.resolve(:domains)).to be_nil
    end
  end
end
