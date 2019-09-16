# frozen_string_literal: true

describe 'Windows UptimeResolver' do
  before do
    win = double('Win32Ole')

    allow(Win32Ole).to receive(:new).and_return(win)
    allow(win).to receive(:return_first).with('SELECT LocalDateTime,LastBootUpTime FROM Win32_OperatingSystem')
                                        .and_return(comp)
  end
  after do
    Facter::Resolvers::UptimeResolver.invalidate_cache
  end

  context '#resolve system_uptime when system is up for 1 hour' do
    let(:comp) { double('WIN32OLE', LocalDateTime: local_time, LastBootUpTime: last_bootup_time) }
    let(:local_time) { '20010203040506+0700' }
    let(:last_bootup_time) { '20010203030506+0700' }

    it 'resolves uptime' do
      expect(Facter::Resolvers::UptimeResolver.resolve(:uptime)).to eql('1:0 hours')
    end
    it 'resolves seconds' do
      expect(Facter::Resolvers::UptimeResolver.resolve(:seconds)).to eql(3600)
    end
    it 'resolves hours' do
      expect(Facter::Resolvers::UptimeResolver.resolve(:hours)).to eql(1)
    end
    it 'resolves days' do
      expect(Facter::Resolvers::UptimeResolver.resolve(:days)).to eql(0)
    end
  end

  context '#resolve system_uptime when system is up for 1 hour and 45 minutes' do
    let(:comp) { double('WIN32OLE', LocalDateTime: local_time, LastBootUpTime: last_bootup_time) }
    let(:local_time) { '20010203045006+0700' }
    let(:last_bootup_time) { '20010203030506+0700' }

    it 'resolves uptime' do
      expect(Facter::Resolvers::UptimeResolver.resolve(:uptime)).to eql('1:45 hours')
    end
    it 'resolves seconds' do
      expect(Facter::Resolvers::UptimeResolver.resolve(:seconds)).to eql(6300)
    end
    it 'resolves hours' do
      expect(Facter::Resolvers::UptimeResolver.resolve(:hours)).to eql(1)
    end
    it 'resolves days' do
      expect(Facter::Resolvers::UptimeResolver.resolve(:days)).to eql(0)
    end
  end

  context '#resolve system_uptime when system is up for 1 hour and 45 minutes and 20 sec' do
    let(:comp) { double('WIN32OLE', LocalDateTime: local_time, LastBootUpTime: last_bootup_time) }
    let(:local_time) { '20010203045026+0700' }
    let(:last_bootup_time) { '20010203030506+0700' }

    it 'resolves uptime' do
      expect(Facter::Resolvers::UptimeResolver.resolve(:uptime)).to eql('1:45 hours')
    end
    it 'resolves seconds' do
      expect(Facter::Resolvers::UptimeResolver.resolve(:seconds)).to eql(6320)
    end
    it 'resolves hours' do
      expect(Facter::Resolvers::UptimeResolver.resolve(:hours)).to eql(1)
    end
    it 'resolves days' do
      expect(Facter::Resolvers::UptimeResolver.resolve(:days)).to eql(0)
    end
  end

  context '#resolve system_uptime when system is up for 1 day' do
    let(:comp) { double('WIN32OLE', LocalDateTime: local_time, LastBootUpTime: last_bootup_time) }
    let(:local_time) { '20010204040506+0700' }
    let(:last_bootup_time) { '20010203040506+0700' }

    it 'resolves uptime' do
      expect(Facter::Resolvers::UptimeResolver.resolve(:days)).to eql(1)
    end
    it 'resolves seconds' do
      expect(Facter::Resolvers::UptimeResolver.resolve(:seconds)).to eql(86_400)
    end
    it 'resolves hours' do
      expect(Facter::Resolvers::UptimeResolver.resolve(:hours)).to eql(24)
    end
    it 'resolvese uptime' do
      expect(Facter::Resolvers::UptimeResolver.resolve(:uptime)).to eql('1 day')
    end
  end

  context '#resolve system_uptime when system is up for more than 1 day' do
    let(:comp) { double('WIN32OLE', LocalDateTime: local_time, LastBootUpTime: last_bootup_time) }
    let(:local_time) { '20010204040506+0700' }
    let(:last_bootup_time) { '20010201120506+0700' }

    it 'resolves uptime' do
      expect(Facter::Resolvers::UptimeResolver.resolve(:days)).to eql(2)
    end
    it 'resolves seconds' do
      expect(Facter::Resolvers::UptimeResolver.resolve(:seconds)).to eql(230_400)
    end
    it 'resolves hours' do
      expect(Facter::Resolvers::UptimeResolver.resolve(:hours)).to eql(64)
    end
    it 'resolves uptime' do
      expect(Facter::Resolvers::UptimeResolver.resolve(:uptime)).to eql('2 days')
    end
  end

  context '#resolve system_uptime when local time is behind last bootup time' do
    let(:comp) { double('WIN32OLE', LocalDateTime: local_time, LastBootUpTime: last_bootup_time) }
    let(:local_time) { '20010201110506+0700' }
    let(:last_bootup_time) { '20010201120506+0700' }

    it 'logs that is unable to determine system uptime and all facts are nil' do
      allow_any_instance_of(Facter::Log).to receive(:debug)
        .with('Unable to determine system uptime!')
      expect(Facter::Resolvers::UptimeResolver.resolve(:days)).to eql(nil)
      expect(Facter::Resolvers::UptimeResolver.resolve(:uptime)).to eql(nil)
      expect(Facter::Resolvers::UptimeResolver.resolve(:seconds)).to eql(nil)
      expect(Facter::Resolvers::UptimeResolver.resolve(:hours)).to eql(nil)
    end
  end

  context '#resolve  when WMI query returns nil' do
    let(:comp) { nil }

    it 'logs that query failed and days nil' do
      allow_any_instance_of(Facter::Log).to receive(:debug)
        .with('WMI query returned no results'\
        'for Win32_OperatingSystem with values LocalDateTime and LastBootUpTime.')
      allow_any_instance_of(Facter::Log).to receive(:debug)
        .with('Unable to determine system uptime!')
      expect(Facter::Resolvers::UptimeResolver.resolve(:days)).to eql(nil)
    end
    it 'detects that seconds, hours and uptime are nil' do
      expect(Facter::Resolvers::UptimeResolver.resolve(:uptime)).to eql(nil)
      expect(Facter::Resolvers::UptimeResolver.resolve(:seconds)).to eql(nil)
      expect(Facter::Resolvers::UptimeResolver.resolve(:hours)).to eql(nil)
    end
  end

  context '#resolve  when WMI query returns nil for LocalDateTime and LastBootUpTIme' do
    let(:comp) { double('WIN32OLE', LocalDateTime: nil, LastBootUpTime: nil) }

    it 'logs that is unable to determine system uptime and days fact is nil' do
      allow_any_instance_of(Facter::Log).to receive(:debug)
        .with('Unable to determine system uptime!')
      expect(Facter::Resolvers::UptimeResolver.resolve(:days)).to eql(nil)
    end
    it 'detects that seconds, hours and uptime are nil' do
      expect(Facter::Resolvers::UptimeResolver.resolve(:uptime)).to eql(nil)
      expect(Facter::Resolvers::UptimeResolver.resolve(:seconds)).to eql(nil)
      expect(Facter::Resolvers::UptimeResolver.resolve(:hours)).to eql(nil)
    end
  end
end
