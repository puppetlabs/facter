# frozen_string_literal: true

describe Facter::CacheManager do
  subject(:cache_manager) { Facter::CacheManager.new }

  let(:cache_dir) { '/etc/facter/cache' }
  let(:searched_core_fact) do
    instance_spy(Facter::SearchedFact, name: 'os', fact_class: instance_spy(Facts::Linux::Os::Name),
                                       filter_tokens: [], user_query: '', type: :core, file: nil)
  end
  let(:searched_custom_fact) do
    instance_spy(Facter::SearchedFact, name: 'my_custom_fact', fact_class: nil, filter_tokens: [],
                                       user_query: '', type: :custom, file: nil)
  end
  let(:searched_external_fact) do
    instance_spy(Facter::SearchedFact, name: 'my_external_fact', fact_class: nil, filter_tokens: [],
                                       user_query: '', type: :file, file: '/tmp/ext_file.txt')
  end
  let(:searched_facts) { [searched_core_fact, searched_custom_fact, searched_external_fact] }
  let(:cached_core_fact) { "{\n  \"os\": \"Ubuntu\"\n}" }
  let(:cached_external_fact) { "{\n  \"my_external_fact\": \"ext_fact\"\n}" }

  let(:resolved_core_fact) { mock_resolved_fact('os', 'Ubuntu', '', []) }
  let(:resolved_facts) { [resolved_core_fact] }
  let(:group_name) { 'operating system' }
  let(:cache_file_name) { File.join(cache_dir, group_name) }
  let(:fact_groups) { instance_spy(Facter::FactGroups) }
  let(:os_fact) { { ttls: 60, group: 'operating system' } }
  let(:external_fact) { { ttls: 60, group: 'ext_file.txt' } }

  before do
    allow(LegacyFacter::Util::Config).to receive(:facts_cache_dir).and_return(cache_dir)
    allow(Facter::FactGroups).to receive(:new).and_return(fact_groups)
    allow(Facter::Options).to receive(:[]).with(:debug).and_return(false)
    allow(Facter::Options).to receive(:[])
    allow(Facter::Options).to receive(:[]).with(:ttls).and_return([])
  end

  describe '#resolve_facts' do
    context 'with no cache dir' do
      before do
        allow(File).to receive(:directory?).with(cache_dir).and_return(false)
        allow(Facter::Options).to receive(:[]).with(:cache).and_return(true)
        allow(Facter::Options).to receive(:[]).with(:ttls).and_return(['fact'])
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
        allow(Facter::Options).to receive(:[]).with(:ttls).and_return(['fact'])
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
        allow(fact_groups).to receive(:get_fact_group).with('ext_file.txt').and_return(nil)
        allow(fact_groups).to receive(:get_group_ttls).with('ext_file.txt').and_return(nil)
        allow(fact_groups).to receive(:get_fact).with('ext_file.txt').and_return(nil)
        allow(fact_groups).to receive(:get_fact).with('my_custom_fact').and_return(nil)
        allow(File).to receive(:readable?).with(cache_file_name).and_return(true)
        allow(File).to receive(:mtime).with(cache_file_name).and_return(Time.now)
        allow(Facter::Util::FileHelper).to receive(:safe_read).with(cache_file_name).and_return(cached_core_fact)
        allow(Facter::Options).to receive(:[]).with(:cache).and_return(true)
      end

      it 'returns cached fact' do
        allow(fact_groups).to receive(:get_fact).with('os').and_return(os_fact)
        allow(File).to receive(:readable?).with(cache_file_name).and_return(true)
        allow(File).to receive(:readable?).with(File.join(cache_dir, 'ext_file.txt')).and_return(false)

        _, cached_facts = cache_manager.resolve_facts(searched_facts)
        expect(cached_facts).to be_an_instance_of(Array).and contain_exactly(
          an_instance_of(Facter::ResolvedFact).and(having_attributes(name: 'os', value: 'Ubuntu', type: :core))
        )
      end

      it 'returns searched fact' do
        allow(fact_groups).to receive(:get_fact).with('os').and_return(os_fact)
        allow(File).to receive(:readable?).with(cache_file_name).and_return(true)
        allow(File).to receive(:readable?).with(File.join(cache_dir, 'ext_file.txt')).and_return(false)

        sf, _cf = cache_manager.resolve_facts(searched_facts)
        expect(sf).to be_an_instance_of(Array).and contain_exactly(
          an_object_having_attributes(name: 'my_custom_fact', type: :custom),
          an_object_having_attributes(name: 'my_external_fact', type: :file)
        )
      end

      it 'deletes cache file' do
        allow(fact_groups).to receive(:get_fact).with('os').and_return(nil)
        allow(File).to receive(:readable?).with(cache_file_name).and_return(true)
        allow(File).to receive(:delete).with(cache_file_name)
        allow(fact_groups).to receive(:get_fact_group).with('os').and_return(group_name)
        allow(File).to receive(:readable?).with(File.join(cache_dir, 'ext_file.txt')).and_return(false)

        cache_manager.resolve_facts(searched_facts)
        expect(File).to have_received(:delete).with(cache_file_name)
      end

      it 'returns cached external facts' do
        allow(fact_groups).to receive(:get_fact).with('os').and_return(nil)
        allow(fact_groups).to receive(:get_fact).with('my_custom_fact').and_return(nil)
        allow(fact_groups).to receive(:get_fact).with('ext_file.txt').and_return(external_fact)
        allow(File).to receive(:readable?).with(cache_file_name).and_return(false)
        allow(Facter::Util::FileHelper).to receive(:safe_read).with(File.join(cache_dir, 'ext_file.txt'))
                                                              .and_return(cached_external_fact)
        allow(File).to receive(:readable?).with(File.join(cache_dir, 'ext_file.txt')).and_return(true)
        allow(File).to receive(:mtime).with(File.join(cache_dir, 'ext_file.txt')).and_return(Time.now)

        _, cached_facts = cache_manager.resolve_facts(searched_facts)
        expect(cached_facts).to be_an_instance_of(Array).and contain_exactly(
          an_instance_of(Facter::ResolvedFact).and(having_attributes(name: 'my_external_fact', value: 'ext_fact',
                                                                     type: :file))
        )
      end
    end

    context 'with timer' do
      before do
        allow(File).to receive(:directory?).and_return(true)
        allow(fact_groups).to receive(:get_fact_group).and_return(group_name)
        allow(fact_groups).to receive(:get_group_ttls).and_return(nil)
        allow(fact_groups).to receive(:get_fact).and_return(nil)
        allow(File).to receive(:readable?)
        allow(File).to receive(:mtime).with(cache_file_name).and_return(Time.now)
        allow(Facter::Util::FileHelper).to receive(:safe_read).with(cache_file_name).and_return(cached_core_fact)
        allow(Facter::Options).to receive(:[]).with(:cache).and_return(true)
        allow(Facter::Framework::Benchmarking::Timer).to receive(:measure)
      end

      it 'returns cached external facts' do
        allow(fact_groups).to receive(:get_fact).with('os').and_return(nil)
        allow(fact_groups).to receive(:get_fact).with('my_custom_fact').and_return(nil)
        allow(fact_groups).to receive(:get_fact).with('ext_file.txt').and_return(external_fact)
        allow(Facter::Util::FileHelper).to receive(:safe_read).with(File.join(cache_dir, 'ext_file.txt'))
                                                              .and_return(cached_external_fact)
        allow(File).to receive(:mtime).with(File.join(cache_dir, 'ext_file.txt')).and_return(Time.now)

        cache_manager.resolve_facts(searched_facts)

        expect(Facter::Framework::Benchmarking::Timer).to have_received(:measure)
      end
    end
  end

  describe '#cache_facts' do
    context 'with group not cached' do
      before do
        allow(File).to receive(:directory?).with(cache_dir).and_return(true)
        allow(File).to receive(:readable?).with(cache_file_name).and_return(false)
        allow(fact_groups).to receive(:get_fact).with('os').and_return(nil)
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
        allow(fact_groups).to receive(:get_fact).with('os').and_return(os_fact)
        allow(fact_groups).to receive(:get_fact_group).with('os').and_return(group_name)
        allow(fact_groups).to receive(:get_fact_group).with('my_custom_fact').and_return(nil)
        allow(fact_groups).to receive(:get_fact_group).with('my_external_fact').and_return(nil)
        allow(File).to receive(:readable?).with(cache_file_name).and_return(false)
        allow(File).to receive(:write).with(cache_file_name, cached_core_fact)
        allow(Facter::Options).to receive(:[]).with(:cache).and_return(true)
        allow(Facter::Options).to receive(:[]).with(:ttls).and_return(['fact'])
      end

      it 'caches fact' do
        cache_manager.cache_facts(resolved_facts)
        expect(File).to have_received(:write).with(cache_file_name, cached_core_fact)
      end
    end
  end

  describe '#fact_cache_enabled?' do
    context 'with ttls' do
      before do
        allow(fact_groups).to receive(:get_fact).with('os').and_return(os_fact)
        allow(File).to receive(:readable?).with(cache_file_name).and_return(false)
      end

      it 'returns true' do
        result = cache_manager.fact_cache_enabled?('os')
        expect(result).to be true
      end
    end

    context 'without ttls' do
      before do
        allow(fact_groups).to receive(:get_fact).with('os').and_return(nil)
        allow(fact_groups).to receive(:get_fact_group).with('os').and_return(group_name)
        allow(Facter::Options).to receive(:[]).with(:cache).and_return(true)
        allow(File).to receive(:delete).with(cache_file_name)
      end

      it 'returns false' do
        allow(File).to receive(:readable?).with(cache_file_name).and_return(false)
        result = cache_manager.fact_cache_enabled?('os')
        expect(result).to be false
      end

      it 'deletes invalid cache file' do
        allow(File).to receive(:readable?).with(cache_file_name).and_return(true)
        cache_manager.fact_cache_enabled?('os')
        expect(File).to have_received(:delete).with(cache_file_name)
      end
    end
  end
end
