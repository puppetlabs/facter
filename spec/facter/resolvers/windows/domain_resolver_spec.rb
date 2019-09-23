# frozen_string_literal: true

describe 'Windows DomainResolver' do
  before do
    win = double('Win32Ole')

    allow(Win32Ole).to receive(:new).and_return(win)
    allow(win).to receive(:exec_query)
      .with('select DNSDomain from Win32_NetworkAdapterConfiguration where IPEnabled = True')
      .and_return(comp)
  end
  after do
    Facter::Resolvers::Domain.invalidate_cache
  end

  context '#resolve' do
    let(:comp) { [double('Win32Ole', DNSDomain: 'domain')] }

    it 'detects that domain is nil' do
      expect(Facter::Resolvers::Domain.resolve(:domain)).to eql('domain')
    end
  end

  context '#resolve when wmi query fails' do
    let(:comp) {}
    before do
      allow_any_instance_of(Facter::Log).to receive(:debug)
        .with('WMI query returned no results for '\
                                                'Win32_NetworkAdapterConfiguration with value DNSDomain.')
    end

    it 'detects that domain is nil' do
      expect(Facter::Resolvers::Domain.resolve(:domain)).to eql(nil)
    end
  end

  context '#resolve when domain is nil' do
    let(:comp) { [double('Win32Ole', DNSDomain: nil)] }

    it 'detects that domain is nil' do
      expect(Facter::Resolvers::Domain.resolve(:domain)).to eql(nil)
    end
  end

  context '#resolve when domain is empty' do
    let(:comp) { [double('Win32Ole', DNSDomain: '')] }

    it 'detects that domain is nil' do
      expect(Facter::Resolvers::Domain.resolve(:domain)).to eql(nil)
    end
  end
end
