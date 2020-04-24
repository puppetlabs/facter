# frozen_string_literal: true

describe Facter::CacheManager do
  subject(:cache_manager) { Facter::CacheManager.new }

  let(:cache_dir) { '/etc/facter/cache' }
  let(:searched_core_fact) do
    instance_spy(Facter::SearchedFact, name: 'os', fact_class: instance_spy(Facts::Debian::Os::Name),
                                       filter_tokens: [], user_query: '', type: :core)
  end
  let(:searched_custom_fact) do
    instance_spy(Facter::SearchedFact, name: 'my_custom_fact', fact_class: nil, filter_tokens: [],
                                       user_query: '', type: :custom)
  end
  let(:searched_facts) { [searched_core_fact, searched_custom_fact] }
  let(:cached_core_fact) { "{\n  \"os\": \"Ubuntu\"\n}" }

  let(:resolved_core_fact) { mock_resolved_fact('os', 'Ubuntu', '', []) }
  let(:resolved_facts) { [resolved_core_fact] }
  let(:group_name) { 'operating system' }
  let(:cache_file_name) { File.join(cache_dir, group_name) }
  let(:fact_groups) { instance_spy(Facter::FactGroups) }

  before do
    allow(LegacyFacter::Util::Config).to receive(:facts_cache_dir).and_return(cache_dir)
    allow(Facter::FactGroups).to receive(:new).and_return(fact_groups)
    allow(Facter::Options).to receive(:[]).with(:debug).and_return(false)
  end

  describe '#resolve_facts' do
    context 'with no cache dir' do
      before do
        allow(File).to receive(:directory?).with(cache_dir).and_return(false)
        allow(Facter::Options).to receive(:[]).with(:cache).and_return(true)
      end

      it 'returns searched facts' do
        sf, _cf = cache_manager.resolve_facts(searched_facts)
        expect(sf).to eq(searched_facts)
      end

      it 'returns no cached facts' do
        _, cf = cache_manager.resolve_facts(searched_facts)
        expect(cf).to be_empty
      end
    end

    context 'with no cache false' do
      before do
        allow(File).to receive(:directory?).with(cache_dir).and_return(true)
        allow(Facter::Options).to receive(:[]).with(:cache).and_return(false)
      end

      it 'returns searched facts' do
        sf, _cf = cache_manager.resolve_facts(searched_facts)
        expect(sf).to eq(searched_facts)
      end

      it 'returns no cached facts' do
        _, cf = cache_manager.resolve_facts(searched_facts)
        expect(cf).to be_empty
      end
    end

    context 'with cached facts' do
      before do
        allow(File).to receive(:directory?).with(cache_dir).and_return(true)
        allow(fact_groups).to receive(:get_fact_group).with('os').and_return(group_name)
        allow(fact_groups).to receive(:get_fact_group).with('my_custom_fact').and_return(nil)
        allow(File).to receive(:readable?).with(cache_file_name).and_return(true)
        allow(File).to receive(:mtime).with(cache_file_name).and_return(Time.now)
        allow(Facter::Util::FileHelper).to receive(:safe_read).with(cache_file_name).and_return(cached_core_fact)
        allow(Facter::Options).to receive(:[]).with(:cache).and_return(true)
      end

      it 'returns cached fact' do
        allow(fact_groups).to receive(:get_group_ttls).with(group_name).and_return(1000)

        _, cached_facts = cache_manager.resolve_facts(searched_facts)
        expect(cached_facts).to be_an_instance_of(Array).and contain_exactly(
          an_instance_of(Facter::ResolvedFact).and(having_attributes(name: 'os', value: 'Ubuntu', type: :core))
        )
      end

      it 'returns searched fact' do
        allow(fact_groups).to receive(:get_group_ttls).with(group_name).and_return(1000)

        sf, _cf = cache_manager.resolve_facts(searched_facts)
        expect(sf).to be_an_instance_of(Array).and contain_exactly(
          an_object_having_attributes(name: 'my_custom_fact', type: :custom)
        )
      end

      it 'deletes cache file' do
        allow(fact_groups).to receive(:get_group_ttls).with(group_name).and_return(nil)
        allow(File).to receive(:delete).with(cache_file_name)

        cache_manager.resolve_facts(searched_facts)
        expect(File).to have_received(:delete).with(cache_file_name)
      end
    end
  end

  describe '#cache_facts' do
    context 'with group not cached' do
      before do
        allow(File).to receive(:directory?).with(cache_dir).and_return(true)
        allow(File).to receive(:readable?).with(cache_file_name).and_return(false)
        allow(fact_groups).to receive(:get_group_ttls).with(group_name).and_return(nil)
        allow(fact_groups).to receive(:get_fact_group).with('os').and_return(group_name)
        allow(File).to receive(:write).with(cache_file_name, cached_core_fact)
        allow(Facter::Options).to receive(:[]).with(:cache).and_return(true)
      end

      it 'returns without caching' do
        cache_manager.cache_facts(resolved_facts)
        expect(File).not_to have_received(:write).with(cache_file_name, cached_core_fact)
      end
    end

    context 'with cache group' do
      before do
        allow(File).to receive(:directory?).with(cache_dir).and_return(true)
        allow(fact_groups).to receive(:get_fact_group).with('os').and_return(group_name)
        allow(fact_groups).to receive(:get_fact_group).with('my_custom_fact').and_return(nil)
        allow(fact_groups).to receive(:get_group_ttls).with(group_name).and_return(1000)
        allow(File).to receive(:readable?).with(cache_file_name).and_return(false)
        allow(File).to receive(:write).with(cache_file_name, cached_core_fact)
        allow(Facter::Options).to receive(:[]).with(:cache).and_return(true)
      end

      it 'caches fact' do
        cache_manager.cache_facts(resolved_facts)
        expect(File).to have_received(:write).with(cache_file_name, cached_core_fact)
      end
    end
  end
end
