# frozen_string_literal: true

describe 'Windows WinOsDescription' do
  before do
    win = double('Win32Ole')

    allow(Win32Ole).to receive(:new).and_return(win)
    allow(win).to receive(:return_first).with('SELECT ProductType,OtherTypeDescription FROM Win32_OperatingSystem')
                                        .and_return(comp)
  end
  after do
    Facter::Resolvers::WinOsDescription.invalidate_cache
  end

  context '#resolve when query fails' do
    let(:comp) { nil }

    it 'logs debug message and facts are nil' do
      allow_any_instance_of(Facter::Log).to receive(:debug)
        .with('WMI query returned no results for Win32_OperatingSystem'\
                   'with values ProductType and OtherTypeDescription.')

      expect(Facter::Resolvers::WinOsDescription.resolve(:full)).to eql(nil)
    end
  end

  context '#resolve' do
    let(:comp) { double('Win32Ole', ProductType: prod, OtherTypeDescription: type) }
    let(:prod) { 1 }
    let(:type) {}

    it 'returns consumerrel true' do
      expect(Facter::Resolvers::WinOsDescription.resolve(:consumerrel)).to eql(true)
    end

    it 'returns description as nil' do
      expect(Facter::Resolvers::WinOsDescription.resolve(:description)).to eql(nil)
    end
  end

  context '#resolve when product type is nil' do
    let(:comp) { double('Win32Ole', ProductType: prod, OtherTypeDescription: type) }
    let(:prod) { nil }
    let(:type) { 'description' }

    it 'returns consumerrel false' do
      expect(Facter::Resolvers::WinOsDescription.resolve(:consumerrel)).to eql(false)
    end

    it 'returns description' do
      expect(Facter::Resolvers::WinOsDescription.resolve(:description)).to eql('description')
    end
  end
end
