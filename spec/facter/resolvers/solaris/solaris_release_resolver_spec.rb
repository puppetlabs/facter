# frozen_string_literal: true

describe Facter::Resolvers::SolarisRelease do
  let(:logger) { instance_spy(Facter::Log) }

  before do
    status = double(Process::Status, to_s: st)
    allow(Open3).to receive(:capture2)
      .with('cat /etc/release')
      .and_return([output, status])
    Facter::Resolvers::SolarisRelease.instance_variable_set(:@log, logger)
  end

  after do
    Facter::Resolvers::SolarisRelease.invalidate_cache
  end

  context 'when can resolve os release facts' do
    let(:output) { load_fixture('os_release_solaris').read }
    let(:st) { 'exit 0' }

    it 'returns os FULL' do
      result = Facter::Resolvers::SolarisRelease.resolve(:full)

      expect(result).to eq('10_u11')
    end

    it 'returns os MINOR' do
      result = Facter::Resolvers::SolarisRelease.resolve(:minor)

      expect(result).to eq('11')
    end

    it 'returns os MAJOR' do
      result = Facter::Resolvers::SolarisRelease.resolve(:major)
      expect(result).to eq('10')
    end
  end

  context 'when os release ends with no minor version' do
    let(:output) { 'Oracle Solaris 11 X86' }
    let(:st) { 'exit 0' }

    it 'returns append 0 to minor version if no minor version is in file but regex pattern matches' do
      result = Facter::Resolvers::SolarisRelease.resolve(:full)
      expect(result).to eq('11.0')
    end
  end

  context 'when trying to read os release file has exit status == 0 but file is empty' do
    let(:output) { '' }
    let(:st) { 'exit 0' }

    it 'returns result nil if file is empty' do
      allow(logger).to receive(:error)
        .with('Could not build release fact because of missing or empty file /etc/release')
      result = Facter::Resolvers::SolarisRelease.resolve(:full)
      expect(result).to eq(nil)
    end
  end

  context 'when trying to read os release file has exit status != 0' do
    let(:output) { '' }
    let(:st) { 'exit 1' }

    it 'returns result nil if exit status != 0' do
      allow(logger).to receive(:error)
        .with('Could not build release fact because of missing or empty file /etc/release')
      result = Facter::Resolvers::SolarisRelease.resolve(:full)
      expect(result).to eq(nil)
    end
  end

  context 'when the result from the os file release has no valid data' do
    let(:output) { 'test test' }
    let(:st) { 'exit 0' }

    it 'returns nil in case the file returns invalid data' do
      result = Facter::Resolvers::SolarisRelease.resolve(:full)
      expect(result).to eq(nil)
    end
  end
end
