# frozen_string_literal: true

describe Facter::Resolvers::OpenVz do
  subject(:openvz_resolver) { Facter::Resolvers::OpenVz }

  let(:vz_dir) { true }
  let(:list_executable) { true }

  after do
    openvz_resolver.invalidate_cache
  end

  before do
    allow(Dir).to receive(:exist?).with('/proc/vz').and_return(vz_dir)
    allow(File).to receive(:executable?).with('/proc/lve/list').and_return(list_executable)
    allow(Dir).to receive(:entries).with('/proc/vz').and_return(vz_dir_entries)
  end

  context 'when /proc/vz dir is empty' do
    let(:vz_dir_entries) { ['.', '..'] }

    it 'returns nil' do
      expect(openvz_resolver.resolve(:vm)).to be_nil
    end
  end

  context 'when /proc/vz dir is not empty' do
    let(:vz_dir_entries) { ['.', '..', 'some_file.txt'] }

    before do
      allow(Facter::Util::FileHelper).to receive(:safe_readlines).with('/proc/self/status', nil).and_return(status_file)
    end

    context 'when /proc/self/status is nil' do
      let(:status_file) { nil }

      it 'returns nil' do
        expect(openvz_resolver.resolve(:vm)).to be_nil
      end
    end

    context 'when /proc/self/status is readable' do
      let(:status_file) { load_fixture('proc_self_status').readlines }

      it 'returns openvzhn' do
        expect(openvz_resolver.resolve(:vm)).to eql('openvzhn')
      end
    end
  end
end
