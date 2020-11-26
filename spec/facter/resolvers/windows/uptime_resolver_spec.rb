# frozen_string_literal: true

describe Facter::Resolvers::Windows::Uptime do
  let(:logger) { instance_spy(Facter::Log) }

  before do
    win = double('Facter::Util::Windows::Win32Ole')

    allow(Facter::Util::Windows::Win32Ole).to receive(:new).and_return(win)
    allow(win).to receive(:return_first).with('SELECT LocalDateTime,LastBootUpTime FROM Win32_OperatingSystem')
                                        .and_return(comp)

    Facter::Resolvers::Windows::Uptime.instance_variable_set(:@log, logger)
  end

  after do
    Facter::Resolvers::Windows::Uptime.invalidate_cache
  end

  describe '#resolve system_uptime when system is up for 1 hour' do
    let(:comp) { double('WIN32OLE', LocalDateTime: local_time, LastBootUpTime: last_bootup_time) }
    let(:local_time) { '20010203040506+0700' }
    let(:last_bootup_time) { '20010203030506+0700' }

    it 'resolves uptime' do
      expect(Facter::Resolvers::Windows::Uptime.resolve(:uptime)).to eql('1:0 hours')
    end

    it 'resolves seconds' do
      expect(Facter::Resolvers::Windows::Uptime.resolve(:seconds)).to be(3600)
    end

    it 'resolves hours' do
      expect(Facter::Resolvers::Windows::Uptime.resolve(:hours)).to be(1)
    end

    it 'resolves days' do
      expect(Facter::Resolvers::Windows::Uptime.resolve(:days)).to be(0)
    end
  end

  describe '#resolve system_uptime when system is up for 1 hour and 45 minutes' do
    let(:comp) { double('WIN32OLE', LocalDateTime: local_time, LastBootUpTime: last_bootup_time) }
    let(:local_time) { '20010203045006+0700' }
    let(:last_bootup_time) { '20010203030506+0700' }

    it 'resolves uptime' do
      expect(Facter::Resolvers::Windows::Uptime.resolve(:uptime)).to eql('1:45 hours')
    end

    it 'resolves seconds' do
      expect(Facter::Resolvers::Windows::Uptime.resolve(:seconds)).to be(6300)
    end

    it 'resolves hours' do
      expect(Facter::Resolvers::Windows::Uptime.resolve(:hours)).to be(1)
    end

    it 'resolves days' do
      expect(Facter::Resolvers::Windows::Uptime.resolve(:days)).to be(0)
    end
  end

  describe '#resolve system_uptime when system is up for 1 hour and 45 minutes and 20 sec' do
    let(:comp) { double('WIN32OLE', LocalDateTime: local_time, LastBootUpTime: last_bootup_time) }
    let(:local_time) { '20010203045026+0700' }
    let(:last_bootup_time) { '20010203030506+0700' }

    it 'resolves uptime' do
      expect(Facter::Resolvers::Windows::Uptime.resolve(:uptime)).to eql('1:45 hours')
    end

    it 'resolves seconds' do
      expect(Facter::Resolvers::Windows::Uptime.resolve(:seconds)).to be(6320)
    end

    it 'resolves hours' do
      expect(Facter::Resolvers::Windows::Uptime.resolve(:hours)).to be(1)
    end

    it 'resolves days' do
      expect(Facter::Resolvers::Windows::Uptime.resolve(:days)).to be(0)
    end
  end

  describe '#resolve system_uptime when system is up for 1 day' do
    let(:comp) { double('WIN32OLE', LocalDateTime: local_time, LastBootUpTime: last_bootup_time) }
    let(:local_time) { '20010204040506+0700' }
    let(:last_bootup_time) { '20010203040506+0700' }

    it 'resolves uptime' do
      expect(Facter::Resolvers::Windows::Uptime.resolve(:days)).to be(1)
    end

    it 'resolves seconds' do
      expect(Facter::Resolvers::Windows::Uptime.resolve(:seconds)).to be(86_400)
    end

    it 'resolves hours' do
      expect(Facter::Resolvers::Windows::Uptime.resolve(:hours)).to be(24)
    end

    it 'resolvese uptime' do
      expect(Facter::Resolvers::Windows::Uptime.resolve(:uptime)).to eql('1 day')
    end
  end

  describe '#resolve system_uptime when system is up for more than 1 day' do
    let(:comp) { double('WIN32OLE', LocalDateTime: local_time, LastBootUpTime: last_bootup_time) }
    let(:local_time) { '20010204040506+0700' }
    let(:last_bootup_time) { '20010201120506+0700' }

    it 'resolves uptime days' do
      expect(Facter::Resolvers::Windows::Uptime.resolve(:days)).to be(2)
    end

    it 'resolves seconds' do
      expect(Facter::Resolvers::Windows::Uptime.resolve(:seconds)).to be(230_400)
    end

    it 'resolves hours' do
      expect(Facter::Resolvers::Windows::Uptime.resolve(:hours)).to be(64)
    end

    it 'resolves total uptime' do
      expect(Facter::Resolvers::Windows::Uptime.resolve(:uptime)).to eql('2 days')
    end
  end

  describe '#resolve system_uptime when local time is behind last bootup time' do
    let(:comp) { double('WIN32OLE', LocalDateTime: local_time, LastBootUpTime: last_bootup_time) }
    let(:local_time) { '20010201110506+0700' }
    let(:last_bootup_time) { '20010201120506+0700' }

    before do
      allow(logger).to receive(:debug).with('Unable to determine system uptime!')
    end

    it 'logs that is unable to determine system uptime and all facts are nil' do
      Facter::Resolvers::Windows::Uptime.resolve(:days)

      expect(logger).to have_received(:debug).with('Unable to determine system uptime!')
    end

    it 'uptime fact is nil' do
      expect(Facter::Resolvers::Windows::Uptime.resolve(:uptime)).to be(nil)
    end
  end

  describe '#resolve  when WMI query returns nil' do
    let(:comp) { nil }

    it 'logs that query failed and days nil' do
      allow(logger).to receive(:debug)
        .with('WMI query returned no results'\
        'for Win32_OperatingSystem with values LocalDateTime and LastBootUpTime.')
      allow(logger).to receive(:debug)
        .with('Unable to determine system uptime!')
      expect(Facter::Resolvers::Windows::Uptime.resolve(:days)).to be(nil)
    end

    it 'detects uptime fact is nil' do
      expect(Facter::Resolvers::Windows::Uptime.resolve(:uptime)).to be(nil)
    end

    it 'detects uptime.seconds fact is nil' do
      expect(Facter::Resolvers::Windows::Uptime.resolve(:seconds)).to be(nil)
    end

    it 'detects uptime.hours fact is nil' do
      expect(Facter::Resolvers::Windows::Uptime.resolve(:hours)).to be(nil)
    end
  end

  describe '#resolve  when WMI query returns nil for LocalDateTime and LastBootUpTIme' do
    let(:comp) { double('WIN32OLE', LocalDateTime: nil, LastBootUpTime: nil) }

    it 'logs that is unable to determine system uptime and days fact is nil' do
      allow(logger).to receive(:debug)
        .with('Unable to determine system uptime!')
      expect(Facter::Resolvers::Windows::Uptime.resolve(:days)).to be(nil)
    end

    it 'detects uptime fact is nil' do
      expect(Facter::Resolvers::Windows::Uptime.resolve(:uptime)).to be(nil)
    end

    it 'detects uptime.seconds fact is nil' do
      expect(Facter::Resolvers::Windows::Uptime.resolve(:seconds)).to be(nil)
    end

    it 'detects uptime.hours fact is nil' do
      expect(Facter::Resolvers::Windows::Uptime.resolve(:hours)).to be(nil)
    end
  end
end
