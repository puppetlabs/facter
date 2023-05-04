# frozen_string_literal: true

describe Facter::Resolvers::SwVers do
  subject(:sw_vers) { Facter::Resolvers::SwVers }

  let(:log_spy) { instance_spy(Facter::Log) }

  context 'with ProductVersionExtra' do
    before do
      Facter::Resolvers::SwVers.invalidate_cache
      sw_vers.instance_variable_set(:@log, log_spy)
      allow(Facter::Core::Execution).to receive(:execute)
        .with('sw_vers', { logger: log_spy })
        .and_return("ProductName:\tmacOS\nProductVersion:\t13.3.1\n"\
          "ProductVersionExtra:\t(a)\nBuildVersion:\t22E772610a\n")
    end

    it 'returns os ProductName' do
      expect(sw_vers.resolve(:productname)).to eq('macOS')
    end

    it 'returns os ProductVersion' do
      expect(sw_vers.resolve(:productversion)).to eq('13.3.1')
    end

    it 'returns os ProductVersionExtra' do
      expect(sw_vers.resolve(:productversionextra)).to eq('(a)')
    end

    it 'returns os BuildVersion' do
      expect(sw_vers.resolve(:buildversion)).to eq('22E772610a')
    end
  end

  context 'without ProductVersionExtra' do
    before do
      Facter::Resolvers::SwVers.invalidate_cache
      sw_vers.instance_variable_set(:@log, log_spy)
      allow(Facter::Core::Execution).to receive(:execute)
        .with('sw_vers', { logger: log_spy })
        .and_return("ProductName:\tMac OS X\nProductVersion:\t10.14.1\n"\
          "BuildVersion:\t18B75\n")
    end

    it 'returns os ProductName' do
      expect(sw_vers.resolve(:productname)).to eq('Mac OS X')
    end

    it 'returns os ProductVersion' do
      expect(sw_vers.resolve(:productversion)).to eq('10.14.1')
    end

    it 'returns os BuildVersion' do
      expect(sw_vers.resolve(:buildversion)).to eq('18B75')
    end

    it 'does not return os ProductVersionExtra' do
      expect(sw_vers.resolve(:productversionextra)).to eq(nil)
    end
  end
end
