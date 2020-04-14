# frozen_string_literal: true

describe Facter::BlockList do
  subject(:block_list) { Facter::BlockList }

  let(:config_reader) { double(Facter::ConfigReader) }

  before do
    allow(Facter::ConfigReader).to receive(:init).and_return(config_reader)
    allow(config_reader).to receive(:block_list).and_return([])
  end

  describe '#initialize' do
    it 'sets @block_groups_file_path to parameter value' do
      blk_list = block_list.new('path/to/block/groups')

      expect(blk_list.instance_variable_get(:@block_groups_file_path)).to eq('path/to/block/groups')
    end

    it 'sets @block_groups_file_path to default path' do
      blk_list = block_list.new

      expect(blk_list.instance_variable_get(:@block_groups_file_path)).to eq(File.join(ROOT_DIR, 'block_groups.conf'))
    end
  end

  describe '#blocked_facts' do
    context 'with block_list' do
      before do
        allow(File).to receive(:readable?).and_return(true)
        allow(Hocon).to receive(:load)
          .with(File.join(ROOT_DIR, 'block_groups.conf'))
          .and_return('blocked_group' => %w[fact1 fact2])
        allow(config_reader).to receive(:block_list).and_return(%w[blocked_group blocked_fact])
      end

      it 'returns a list of blocked facts' do
        blk_list = block_list.new

        expect(blk_list.blocked_facts).to eq(%w[fact1 fact2 blocked_fact])
      end
    end

    context 'without block_list' do
      before do
        allow(File).to receive(:readable?).and_return(false)
        allow(config_reader).to receive(:block_list).and_return([])
      end

      it 'finds no block group file' do
        allow(File).to receive(:readable?).and_return(false)

        config_reader = double(Facter::ConfigReader)
        allow(Facter::ConfigReader).to receive(:new).and_return(config_reader)
        allow(config_reader).to receive(:block_list).and_return(nil)

        blk_list = block_list.new

        expect(blk_list.blocked_facts).to eq([])
      end
    end
  end
end
