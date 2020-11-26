# frozen_string_literal: true

describe Facter::Resolvers::WinOsDescription do
  let(:logger) { instance_spy(Facter::Log) }

  before do
    win = double('Facter::Util::Windows::Win32Ole')

    allow(Facter::Util::Windows::Win32Ole).to receive(:new).and_return(win)
    allow(win).to receive(:return_first).with('SELECT ProductType,OtherTypeDescription FROM Win32_OperatingSystem')
                                        .and_return(comp)
    Facter::Resolvers::WinOsDescription.instance_variable_set(:@log, logger)
  end

  after do
    Facter::Resolvers::WinOsDescription.invalidate_cache
  end

  describe '#resolve when query fails' do
    let(:comp) { nil }

    it 'logs debug message and facts are nil' do
      allow(logger).to receive(:debug)
        .with('WMI query returned no results for Win32_OperatingSystem'\
                   'with values ProductType and OtherTypeDescription.')

      expect(Facter::Resolvers::WinOsDescription.resolve(:full)).to be(nil)
    end
  end

  describe '#resolve' do
    let(:comp) { double('Facter::Util::Windows::Win32Ole', ProductType: prod, OtherTypeDescription: type) }
    let(:prod) { 1 }
    let(:type) {}

    it 'returns consumerrel true' do
      expect(Facter::Resolvers::WinOsDescription.resolve(:consumerrel)).to be(true)
    end

    it 'returns description as nil' do
      expect(Facter::Resolvers::WinOsDescription.resolve(:description)).to be(nil)
    end
  end

  describe '#resolve when product type is nil' do
    let(:comp) { double('Facter::Util::Windows::Win32Ole', ProductType: prod, OtherTypeDescription: type) }
    let(:prod) { nil }
    let(:type) { 'description' }

    it 'returns consumerrel false' do
      expect(Facter::Resolvers::WinOsDescription.resolve(:consumerrel)).to be(false)
    end

    it 'returns description' do
      expect(Facter::Resolvers::WinOsDescription.resolve(:description)).to eql('description')
    end
  end
end
