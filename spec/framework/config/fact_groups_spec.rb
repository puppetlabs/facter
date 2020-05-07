# frozen_string_literal: true

describe Facter::FactGroups do
  subject(:fact_groups) { Facter::FactGroups }

  let(:fg) { fact_groups.new }
  let(:config_reader) { class_spy(Facter::ConfigReader) }

  before do
    allow(Facter::ConfigReader).to receive(:init).and_return(config_reader)
    allow(config_reader).to receive(:block_list).and_return([])
    allow(config_reader).to receive(:ttls).and_return([])
    allow(config_reader).to receive(:fact_groups).and_return({})
  end

  describe '#initialize' do
    it 'sets @groups_file_path to parameter value' do
      blk_list = fact_groups.new('path/to/block/groups')

      expect(blk_list.instance_variable_get(:@groups_file_path)).to eq('path/to/block/groups')
    end

    it 'sets @groups_file_path to default path' do
      blk_list = fact_groups.new

      expect(blk_list.instance_variable_get(:@groups_file_path)).to eq(File.join(ROOT_DIR, 'fact_groups.conf'))
    end

    it 'merges groups from facter.conf' do
      allow(config_reader).to receive(:fact_groups).and_return('foo' => 'bar')
      fct_grp = fact_groups.new

      expect(fct_grp.instance_variable_get(:@groups)).to include('foo' => 'bar')
    end

    it 'merges groups from facter.conf with default group override' do
      allow(Hocon).to receive(:load).with(File.join(ROOT_DIR, 'fact_groups.conf'))
                                    .and_return('kernel' => %w[kernel kernelversion])
      allow(config_reader).to receive(:fact_groups).and_return('kernel' => 'foo')
      fct_grp = fact_groups.new

      expect(fct_grp.instance_variable_get(:@groups)).to eq('kernel' => 'foo')
    end
  end

  describe '#blocked_facts' do
    context 'with block_list' do
      before do
        allow(File).to receive(:readable?).and_return(true)
        allow(Hocon).to receive(:load)
          .with(File.join(ROOT_DIR, 'fact_groups.conf'))
          .and_return('blocked_group' => %w[fact1 fact2])
        allow(config_reader).to receive(:block_list).and_return(%w[blocked_group blocked_fact])
      end

      it 'returns a list of blocked facts' do
        blk_list = fact_groups.new

        expect(blk_list.blocked_facts).to eq(%w[fact1 fact2 blocked_fact])
      end
    end

    context 'without block_list' do
      before do
        allow(File).to receive(:readable?).and_return(false)
        allow(config_reader).to receive(:block_list).and_return([])
        allow(Facter::ConfigReader).to receive(:new).and_return(config_reader)
        allow(config_reader).to receive(:block_list).and_return(nil)
      end

      it 'finds no block group file' do
        blk_list = fact_groups.new

        expect(blk_list.blocked_facts).to eq([])
      end
    end
  end

  describe '#get_fact_group' do
    context 'when it finds group file' do
      before do
        allow(File).to receive(:readable?).and_return(true)
        allow(Hocon).to receive(:load)
          .with(File.join(ROOT_DIR, 'fact_groups.conf'))
          .and_return('operating system' => %w[os os.name])

        allow(config_reader).to receive(:ttls).and_return(['operating system' => '30 minutes'])
      end

      it 'returns group' do
        expect(fg.get_fact_group('os')).to eq('operating system')
      end

      it 'returns nil' do
        expect(fg.get_fact_group('memory')).to be_nil
      end
    end

    context 'when it does not find group file' do
      before do
        allow(File).to receive(:readable?).and_return(false)
        allow(config_reader).to receive(:ttls).and_return(nil)
      end

      it 'returns nil' do
        expect(fg.get_fact_group('os')).to be_nil
      end
    end
  end

  describe '#get_group_ttls' do
    context 'when it finds group file' do
      before do
        allow(File).to receive(:readable?).and_return(true)
        allow(Hocon).to receive(:load)
          .with(File.join(ROOT_DIR, 'fact_groups.conf'))
          .and_return('operating system' => %w[os os.name])

        allow(config_reader).to receive(:ttls).and_return(['operating system' => '30 minutes'])
      end

      it 'returns group' do
        expect(fg.get_group_ttls('operating system')).to eq(1800)
      end

      it 'returns nil' do
        expect(fg.get_group_ttls('memory')).to be_nil
      end
    end

    context 'when it does not find group file' do
      before do
        allow(File).to receive(:readable?).and_return(false)
        allow(config_reader).to receive(:ttls).and_return(nil)
      end

      it 'returns nil' do
        expect(fg.get_group_ttls('os')).to be_nil
      end
    end
  end
end
