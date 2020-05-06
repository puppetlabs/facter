# frozen_string_literal: true

describe Facter::Resolvers::SolarisRelease do
  subject(:solaris_release) { Facter::Resolvers::SolarisRelease }

  before do
    allow(Facter::Util::FileHelper).to receive(:safe_read)
      .with('/etc/release', nil)
      .and_return(output)
  end

  after do
    solaris_release.invalidate_cache
  end

  context 'when can resolve os release facts' do
    let(:output) { load_fixture('os_release_solaris').read }

    it 'returns os FULL' do
      expect(solaris_release.resolve(:full)).to eq('10_u11')
    end

    it 'returns os MINOR' do
      expect(solaris_release.resolve(:minor)).to eq('11')
    end

    it 'returns os MAJOR' do
      expect(solaris_release.resolve(:major)).to eq('10')
    end
  end

  context 'when os release ends with no minor version' do
    let(:output) { 'Oracle Solaris 11 X86' }

    it 'returns append 0 to minor version if no minor version is in file but regex pattern matches' do
      expect(solaris_release.resolve(:full)).to eq('11.0')
    end
  end

  context 'when trying to read os release file has exit status == 0 but file is empty' do
    let(:output) { '' }

    it 'returns result nil if file is empty' do
      expect(solaris_release.resolve(:full)).to eq(nil)
    end
  end

  context 'when the result from the os file release has no valid data' do
    let(:output) { 'test test' }

    it 'returns nil in case the file returns invalid data' do
      expect(solaris_release.resolve(:full)).to eq(nil)
    end
  end
end
