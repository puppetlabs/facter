# frozen_string_literal: true

describe Facter::BlockList do
  before do
    Singleton.__init__(Facter::BlockList)
  end

  describe '#blocked_facts' do
    it 'converts block to facts' do
      expect(File).to receive(:readable?).and_return(true)
      expect(Hocon).to receive(:load)
        .with(File.join(ROOT_DIR, 'block_groups.conf'))
        .and_return('blocked_group' => %w[fact1 fact2])

      config_reader = double(Facter::ConfigReader)
      expect(Facter::ConfigReader).to receive(:new).and_return(config_reader)
      expect(config_reader).to receive(:block_list).and_return(%w[blocked_group blocked_fact])

      blocked_facts = Facter::BlockList.instance.blocked_facts

      expect(blocked_facts).to eq(%w[fact1 fact2 blocked_fact])
    end

    it 'finds no block group file' do
      expect(File).to receive(:readable?).and_return(false)

      config_reader = double(Facter::ConfigReader)
      expect(Facter::ConfigReader).to receive(:new).and_return(config_reader)
      expect(config_reader).to receive(:block_list).and_return(nil)

      blocked_facts = Facter::BlockList.instance.blocked_facts

      expect(blocked_facts).to eq([])
    end
  end
end
