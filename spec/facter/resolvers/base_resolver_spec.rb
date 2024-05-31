# frozen_string_literal: true

describe Facter::Resolvers::BaseResolver do
  let(:fact) { 'fact' }
  let(:resolver) do
    Class.new(Facter::Resolvers::BaseResolver) do
      init_resolver

      def self.post_resolve(fact_name, _options)
        @fact_list[fact_name] = 'value'
        @fact_list
      end
    end
  end

  describe '#log' do
    it 'returns the log' do
      expect(resolver.log).to be_an_instance_of(Facter::Log)
    end

    it 'returns the same log instance each time' do
      expect(resolver.log).to be_equal(resolver.log)
    end
  end

  describe '#invalidate_cache' do
    it 'clears the facts_list' do
      resolver.resolve(fact)

      resolver.invalidate_cache

      expect(resolver.resolve('fact2')).to eq('value')
    end
  end

  describe '#subscribe_to_manager' do
    before do
      allow(Facter::SessionCache).to receive(:subscribe).with(resolver)
    end

    it 'calls the CacheManager subscribe method' do
      resolver.subscribe_to_manager

      expect(Facter::SessionCache).to have_received(:subscribe).with(resolver)
    end
  end

  describe '#resolve' do
    context 'when fact is resolved successfully' do
      before do
        allow(resolver).to receive(:post_resolve)
        allow(Facter::SessionCache).to receive(:subscribe).with(resolver)
      end

      it 'calls the CacheManager subscribe method' do
        resolver.resolve(fact)

        expect(Facter::SessionCache).to have_received(:subscribe).with(resolver)
      end

      it 'calls the post_resolve method' do
        resolver.resolve(fact)

        expect(resolver).to have_received(:post_resolve).with(fact, {})
      end
    end

    context 'when Load Error is raised' do
      before do
        allow(resolver).to receive(:post_resolve).and_raise(LoadError)
      end

      it 'logs the Load Error exception at the error level' do
        expect(resolver.log).to receive(:error).with(/Resolving fact #{fact}, but got LoadError/)

        resolver.resolve(fact)
      end

      it 'sets the fact to nil' do
        expect(resolver.resolve(fact)).to eq(nil)
      end
    end
  end

  describe '#validate_resolution' do
    before do
      allow(resolver).to receive(:cache_nil_for_unresolved_facts)
    end

    it 'sets the fact to nil if undefined' do
      resolver.cache_nil_for_unresolved_facts('unresolved_fact')
      expect(resolver.resolve('unresolved_fact')).to be_nil
    end

    it 'does not overwrite values' do
      resolver.resolve('my_fact')
      resolver.cache_nil_for_unresolved_facts('my_fact')

      expect(resolver.post_resolve('my_fact', {})).to eq({ 'my_fact' => 'value' })
    end
  end

  describe '#post_resolve' do
    let(:resolver) { Class.new(Facter::Resolvers::BaseResolver) }

    it 'raises NotImplementedError error' do
      expect { resolver.post_resolve(fact, {}) }.to \
        raise_error(NotImplementedError,
                    'You must implement post_resolve(fact_name, options) method in ')
    end
  end
end
