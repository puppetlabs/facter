# frozen_string_literal: true

describe Facter::Resolvers::Linux::Disks do
  describe '#resolve' do
    subject(:resolver) { Facter::Resolvers::Linux::Disks }

    let(:disk_files) { %w[sr0/device sr0/size sda/device sda/size] }

    let(:paths) do
      {
        model: '/device/model',
        size: '/size',
        vendor: '/device/vendor',
        type: '/queue/rotational',
        serial: 'false',
        wwn: 'false'
      }
    end

    let(:disks) do
      {
        sr0: {
          size: '12',
          rotational: '0',
          model: 'model1',
          vendor: 'vendor1',
          serial: 'AJDI2491AK',
          wwn: '239090190.0'
        },
        sda: {
          size: '231',
          rotational: '1',
          model: 'model2',
          vendor: 'vendor2',
          serial: 'B2EI34F1AL',
          wwn: '29429191.0'
        }
      }
    end

    before do
      allow(Facter::Util::FileHelper).to receive(:dir_children).with('/sys/block').and_return(%w[sda sr0])
    end

    after do
      Facter::Resolvers::Linux::Disks.invalidate_cache
    end

    context 'when device dir for blocks exists' do
      let(:expected_output) do
        { 'sr0' => { model: 'model1', serial: 'AJDI2491AK', wwn: '239090190.0',
                     size: '6.00 KiB', size_bytes: 6144, vendor: 'vendor1', type: 'ssd' },
          'sda' => { model: 'model2', serial: 'B2EI34F1AL', wwn: '29429191.0',
                     size: '115.50 KiB', size_bytes: 118_272, vendor: 'vendor2', type: 'hdd' } }
      end

      before do
        disk_files.each do |disk_file|
          allow(File).to receive(:readable?).with("/sys/block/#{disk_file}").and_return(true)
        end

        paths.each do |fact, value|
          disks.each do |disk, values|
            case value
            when '/size'
              allow(Facter::Util::FileHelper).to receive(:safe_read)
                .with("/sys/block/#{disk}#{value}", nil).and_return(values[:size])
            when '/queue/rotational'
              allow(Facter::Util::FileHelper).to receive(:safe_read)
                .with("/sys/block/#{disk}#{value}", nil).and_return(values[:rotational])
            when '/device/model'
              allow(Facter::Util::FileHelper).to receive(:safe_read)
                .with("/sys/block/#{disk}#{value}", nil).and_return(values[:model])
            when '/device/vendor'
              allow(Facter::Util::FileHelper).to receive(:safe_read)
                .with("/sys/block/#{disk}#{value}", nil).and_return(values[:vendor])
            when 'false'
              allow(Facter::Core::Execution).to receive(:execute)
                .with("lsblk -dn -o #{fact} /dev/#{disk}", on_fail: '', timeout: 1)
                .and_return(values[fact])
            end
          end
        end
      end

      context 'when all files are readable' do
        it 'returns disks fact' do
          expect(resolver.resolve(:disks)).to eql(expected_output)
        end
      end

      context 'when size files are not readable' do
        let(:expected_output) do
          { 'sr0' => { model: 'model1', vendor: 'vendor1', type: 'ssd', serial: 'AJDI2491AK', wwn: '239090190.0' },
            'sda' => { model: 'model2', vendor: 'vendor2', type: 'hdd', serial: 'B2EI34F1AL', wwn: '29429191.0' } }
        end

        before do
          paths.each do |_key, value|
            disks.each do |disk, _values|
              if value == '/size'
                allow(Facter::Util::FileHelper).to receive(:safe_read)
                  .with("/sys/block/#{disk}#{value}", nil).and_return(nil)
              end
            end
          end
        end

        it 'returns disks fact' do
          expect(resolver.resolve(:disks)).to eql(expected_output)
        end
      end

      context 'when device vendor and model files are not readable' do
        let(:expected_output) do
          { 'sr0' => { size: '6.00 KiB', size_bytes: 6144, serial: 'AJDI2491AK', wwn: '239090190.0' },
            'sda' => { size: '115.50 KiB', size_bytes: 118_272, serial: 'B2EI34F1AL', wwn: '29429191.0' } }
        end

        before do
          paths.each do |_key, value|
            disks.each do |disk, _values|
              if value != '/size'
                allow(Facter::Util::FileHelper).to receive(:safe_read)
                  .with("/sys/block/#{disk}#{value}", nil).and_return(nil)
              end
            end
          end
        end

        it 'returns disks fact' do
          expect(resolver.resolve(:disks)).to eql(expected_output)
        end
      end

      context 'when serial and wwn are not returned by lsblk' do
        let(:expected_output) do
          { 'sr0' => { size: '6.00 KiB', size_bytes: 6144, model: 'model1', vendor: 'vendor1', type: 'ssd' },
            'sda' => { size: '115.50 KiB', size_bytes: 118_272, model: 'model2', vendor: 'vendor2', type: 'hdd' } }
        end

        before do
          paths.each do |fact, value|
            disks.each do |disk, _values|
              next unless value == 'false'

              allow(Facter::Core::Execution).to receive(:execute)
                .with("lsblk -dn -o #{fact} /dev/#{disk}", on_fail: '', timeout: 1)
                .and_return('')
            end
          end
        end

        it 'returns disks fact' do
          expect(resolver.resolve(:disks)).to eql(expected_output)
        end
      end
    end

    context 'when all files inside device dir for blocks are missing' do
      before do
        disk_files.each do |disk_file|
          allow(File).to receive(:readable?).with("/sys/block/#{disk_file}").and_return(false)
        end
      end

      it 'returns disks fact as nil' do
        expect(resolver.resolve(:disks)).to be(nil)
      end
    end
  end
end
