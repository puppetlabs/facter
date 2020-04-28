# frozen_string_literal: true

describe Facter::FilesystemHelper do
  describe '.compute_capacity' do
    it 'returns an integer if full' do
      capacity = Facter::FilesystemHelper.send(:compute_capacity, 100, 100)
      expect(capacity).to eq('100%')
    end

    it 'returns an integer if empty' do
      capacity = Facter::FilesystemHelper.send(:compute_capacity, 0, 100)
      expect(capacity).to eq('0%')
    end

    it 'returns a ratio with 2 decimals otherwise' do
      capacity = Facter::FilesystemHelper.send(:compute_capacity, 421, 10_000)
      expect(capacity).to eq('4.21%')
    end
  end

  describe '#read_mountpoints' do
    before do
      mount = OpenStruct.new
      mount.name = +'test_name'.encode('ASCII-8BIT')
      mount.mount_type = +'test_type'.encode('ASCII-8BIT')
      mount.mount_point = +'test_mount_point'.encode('ASCII-8BIT')
      mount.options = +'test_options'.encode('ASCII-8BIT')

      mounts = [mount]
      allow(Sys::Filesystem).to receive(:mounts).and_return(mounts)
    end

    let(:mount_points) { Facter::FilesystemHelper.read_mountpoints }

    it 'converts name from ASCII-8BIT to UTF-8' do
      expect(mount_points.first.name.encoding.name). to eq('UTF-8')
    end

    it 'converts mount_type from ASCII-8BIT to UTF-8' do
      expect(mount_points.first.mount_type.encoding.name). to eq('UTF-8')
    end

    it 'converts mount_point from ASCII-8BIT to UTF-8' do
      expect(mount_points.first.mount_point.encoding.name). to eq('UTF-8')
    end

    it 'converts options from ASCII-8BIT to UTF-8' do
      expect(mount_points.first.options.encoding.name). to eq('UTF-8')
    end
  end
end
