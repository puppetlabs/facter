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
    it 'merges groups from facter.conf' do
      allow(config_reader).to receive(:fact_groups).and_return('foo' => 'bar')
      fct_grp = fact_groups.new

      expect(fct_grp.groups).to include('foo' => 'bar')
    end

    it 'merges external facts' do
      external_path = '/path/to/external'
      allow(Facter::Options).to receive(:external_dir).and_return([external_path])
      allow(Dir).to receive(:exist?).with(external_path).and_return true
      allow(Dir).to receive(:entries).with(external_path).and_return(['.', '..', 'external.sh'])
      fct_grp = fact_groups.new

      expect(fct_grp.instance_variable_get(:@groups)).to include('external.sh' => nil)
    end

    it 'merges groups from facter.conf with default group override' do
      stub_const('Facter::Config::FACT_GROUPS', { 'kernel' => %w[kernel kernelversion] })
      allow(config_reader).to receive(:fact_groups).and_return('kernel' => 'foo')
      fct_grp = fact_groups.new

      expect(fct_grp.groups).to eq('kernel' => 'foo')
    end
  end

  describe '#blocked_facts' do
    context 'with block_list' do
      before do
        stub_const('Facter::Config::FACT_GROUPS', 'blocked_group' => %w[fact1 fact2])
        allow(config_reader).to receive(:block_list).and_return(%w[blocked_group blocked_fact])
      end

      it 'returns a list of blocked facts' do
        blk_list = fact_groups.new

        expect(blk_list.blocked_facts).to eq(%w[fact1 fact2 blocked_fact])
      end
    end

    context 'with blocked `legacy` group' do
      before do
        stub_const('Facter::Config::FACT_GROUPS', 'legacy' => %w[legacy_fact1 legacy_fact2])
        allow(config_reader).to receive(:block_list).and_return(%w[legacy])
      end

      # legacy facts are excluded because they are blocked by another mechanism that takes into account the fact's type
      it 'excludes legacy facts' do
        blk_list = fact_groups.new

        expect(blk_list.blocked_facts).to be_empty
      end
    end

    context 'without block_list' do
      before do
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
    before do
      stub_const('Facter::Config::FACT_GROUPS', 'operating system' => %w[os os.name])
      allow(config_reader).to receive(:ttls).and_return(['operating system' => '30 minutes'])
    end

    it 'returns group' do
      expect(fg.get_fact_group('os')).to eq('operating system')
    end

    it 'returns nil' do
      expect(fg.get_fact_group('memory')).to be_nil
    end
  end

  describe '#get_group_ttls' do
    let(:ttls) { ['operating system' => '30 minutes'] }

    before do
      stub_const('Facter::Config::FACT_GROUPS', 'operating system' => %w[os os.name])
      allow(config_reader).to receive(:ttls).and_return(ttls)
    end

    it 'returns group' do
      expect(fg.get_group_ttls('operating system')).to eq(1800)
    end

    it 'returns nil' do
      expect(fg.get_group_ttls('memory')).to be_nil
    end

    context 'when ttls has short names for units' do
      let(:ttls) { ['operating system' => '10000000000000 ns', 'memory' => '10000', 'hostname' => '30 h'] }

      it 'returns os ttl in seconds' do
        expect(fg.get_group_ttls('operating system')).to eq(10_000)
      end

      it 'returns memory ttl in seconds' do
        expect(fg.get_group_ttls('memory')).to eq(10)
      end

      it 'returns hostname ttl in seconds' do
        expect(fg.get_group_ttls('hostname')).to eq(108_000)
      end
    end

    context 'when ttls has hour instead of hour' do
      let(:ttls) { ['operating system' => '1 hour', 'memory' => '1 day', 'hostname' => '30 invalid_unit'] }
      let(:logger) { Facter::Log.class_variable_get(:@@logger) }

      before do
        allow(Facter::Log).to receive(:new).and_return(logger)
      end

      it 'logs an error message' do
        allow(logger).to receive(:error)
        expect(logger).to receive(:error).with('Could not parse time unit invalid_units '\
          "(try #{Facter::FactGroups::STRING_TO_SECONDS.keys.reject(&:empty?).join(', ')})").twice

        fg.get_group_ttls('hostname')
      end

      it 'returns os ttl in seconds' do
        expect(fg.get_group_ttls('operating system')).to eq(3600)
      end

      it 'returns memory ttl in seconds' do
        expect(fg.get_group_ttls('memory')).to eq(86_400)
      end
    end
  end
end
