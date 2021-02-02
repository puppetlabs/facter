# frozen_string_literal: true

describe Facter::Resolvers::SpecificReleaseFile do
  subject(:specific_release_file_resolver) { Facter::Resolvers::SpecificReleaseFile }

  after do
    specific_release_file_resolver.invalidate_cache
  end

  context 'when release file name is not given' do
    it 'returns nil' do
      expect(specific_release_file_resolver.resolve(:release, {})).to be_nil
    end
  end

  context 'when release file is present' do
    let(:result) { nil }

    before do
      allow(Facter::Util::FileHelper).to receive(:safe_read).with(options[:release_file], nil).and_return(result)
    end

    context 'when release file can not be read' do
      let(:options) { { release_file: '/etc/alpine-release' } }
      let(:result) { nil }

      it 'returns nil' do
        result = specific_release_file_resolver.resolve(:release, options)

        expect(result).to be_nil
      end
    end

    context 'when release file is readable' do
      let(:options) { { release_file: '/etc/devuan_version' } }
      let(:result) { load_fixture('os_release_devuan').read }

      it 'returns release value' do
        result = specific_release_file_resolver.resolve(:release, options)

        expect(result).to eq('beowulf')
      end
    end

    context 'when requesting invalid data' do
      let(:options) { { release_file: '/etc/alpine-release' } }
      let(:result) { nil }

      it 'returns nil' do
        result = specific_release_file_resolver.resolve(:something, options)

        expect(result).to be_nil
      end
    end

    context 'when release file name is not given' do
      let(:options) do
        {
          release_folder: 'folder',
          no_regex: /regex/
        }
      end

      it 'returns nil' do
        result = specific_release_file_resolver.resolve(:release, options)

        expect(result).to be_nil
      end
    end

    context 'when regex is not given' do
      let(:options) do
        {
          release_file: 'folder',
          no_regex: /regex/
        }
      end

      it 'returns nil' do
        result = specific_release_file_resolver.resolve(:release, options)

        expect(result).to be_nil
      end
    end

    context 'when release file and regex are present' do
      let(:options) do
        {
          release_file: '/etc/ovs-release',
          regex: /^RELEASE=(\d+)/
        }
      end

      before do
        allow(Facter::Util::FileHelper).to receive(:safe_read).with(options[:release_file], nil).and_return(result)
      end

      context 'when release file can not be read' do
        let(:result) { nil }

        it 'returns nil' do
          result = specific_release_file_resolver.resolve(:release, options)

          expect(result).to be_nil
        end
      end

      context 'when release file is readable' do
        let(:result) { load_fixture('os_release_mint').read }

        it 'returns release value' do
          result = specific_release_file_resolver.resolve(:release, options)[1]

          expect(result).to eq('19')
        end
      end

      context 'when requesting invalid data' do
        let(:result) { load_fixture('os_release_mint').read }

        it 'returns nil' do
          result = specific_release_file_resolver.resolve(:something, options)

          expect(result).to be_nil
        end
      end
    end
  end
end
