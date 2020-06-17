# frozen_string_literal: true

describe Facter::Resolvers::Freebsd::Geom do
  describe '#resolve' do
    subject(:resolver) { Facter::Resolvers::Freebsd::Geom }

    before do
      allow(Facter::Freebsd::FfiHelper).to receive(:sysctl_by_name)
        .with(:string, 'kern.geom.confxml')
        .and_return(load_fixture('kern.geom.confxml').read)
    end

    describe 'disks resolution' do
      let(:expected_output) do
        {
          'ada0' => {
            model: 'Samsung SSD 850 PRO 512GB',
            serial_number: 'S250NXAG959927J',
            size: '476.94 GiB',
            size_bytes: 512_110_190_592
          }
        }
      end

      it 'returns disks fact' do
        expect(resolver.resolve(:disks)).to eql(expected_output)
      end
    end

    describe 'partitions resolution' do
      let(:expected_output) do
        {
          'ada0p1' => {
            partlabel: 'gptboot0',
            partuuid: '503d3458-c135-11e8-bd11-7d7cd061b26f',
            size: '512.00 KiB',
            size_bytes: 524_288
          },
          'ada0p2' => {
            partlabel: 'swap0',
            partuuid: '5048d40d-c135-11e8-bd11-7d7cd061b26f',
            size: '2.00 GiB',
            size_bytes: 2_147_483_648
          },
          'ada0p3' => {
            partlabel: 'zfs0',
            partuuid: '504f1547-c135-11e8-bd11-7d7cd061b26f',
            size: '474.94 GiB',
            size_bytes: 509_961_306_112
          }
        }
      end

      it 'returns partitions fact' do
        expect(resolver.resolve(:partitions)).to eql(expected_output)
      end
    end
  end
end
