# frozen_string_literal: true

describe Facter::Resolvers::ReleaseFromFirstLine do
  subject(:release_from_first_line_resolver) { Facter::Resolvers::ReleaseFromFirstLine }

  after do
    release_from_first_line_resolver.invalidate_cache
  end

  context 'when release file name is not given' do
    it 'returns nil' do
      result = release_from_first_line_resolver.resolve(:release, release_folder: 'folder')

      expect(result).to be_nil
    end
  end

  context 'when release file is present' do
    before do
      allow(Facter::Util::FileHelper).to receive(:safe_read).with(file_name, nil).and_return(result)
    end

    context 'when release file can not be read' do
      let(:file_name) { '/etc/ovs-release' }
      let(:result) { nil }

      it 'returns nil' do
        result = release_from_first_line_resolver.resolve(:release, release_file: file_name)

        expect(result).to be_nil
      end
    end

    context 'when release file is readable' do
      let(:file_name) { '/etc/oracle-release' }
      let(:result) { 'Oracle Linux release 10.5 (something)' }

      it 'returns release value' do
        result = release_from_first_line_resolver.resolve(:release, release_file: file_name)

        expect(result).to eq('10.5')
      end
    end

    context 'when os-release file contains Rawhide' do
      let(:file_name) { '/etc/os-release' }
      let(:result) { 'a bunch of data and there is Rawhide' }

      it 'returns nil' do
        result = release_from_first_line_resolver.resolve(:release, release_file: file_name)

        expect(result).to eq('Rawhide')
      end
    end

    context 'when os-release file contains Amazon Linux' do
      let(:file_name) { '/etc/os-release' }
      let(:result) { 'some other data and Amazon Linux 15 and that\'s it' }

      it 'returns nil' do
        result = release_from_first_line_resolver.resolve(:release, release_file: file_name)

        expect(result).to eq('15')
      end
    end

    context 'when requesting invalid data' do
      let(:file_name) { '/etc/oracle-release' }
      let(:result) { nil }

      it 'returns nil' do
        result = release_from_first_line_resolver.resolve(:something, release_file: file_name)

        expect(result).to be_nil
      end
    end
  end
end
