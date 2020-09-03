# frozen_string_literal: true

describe Facter::Resolvers::BaseResolver do
  let(:fact) { 'fact' }
  let(:resolver) do
    Class.new(Facter::Resolvers::BaseResolver) do
      @fact_list = {}
      @semaphore = Mutex.new
      def self.post_resolve(fact_name)
        @fact_list[fact_name] = 'value'
        @fact_list
      end
    end
  end

  describe '#log' do
    before do
      allow(Facter::Log).to receive(:new).with(resolver).and_return('logger')
    end

    it 'initializes the log' do
      resolver.log

      expect(Facter::Log).to have_received(:new).with(resolver)
    end

    it 'initializes the log only once' do
      resolver.log
      resolver.log

      expect(Facter::Log).to have_received(:new).with(resolver).once
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

        expect(resolver).to have_received(:post_resolve).with(fact)
      end
    end

    context 'when Load Error is raised' do
      before do
        allow(resolver).to receive(:post_resolve).and_raise(LoadError)
        allow(Facter::Log).to receive(:new).with(resolver).and_return(instance_double(Facter::Log, debug: nil))
      end

      it 'logs the Load Error exception' do
        resolver.resolve(fact)

        expect(resolver.log).to have_received(:debug).with("resolving fact #{fact}, but LoadError")
      end

      it 'sets the fact to nil' do
        expect(resolver.resolve(fact)).to eq(nil)
      end
    end
  end

  describe '#validate_resolution' do
    before do
      allow(resolver).to receive(:validate_resolution)
    end

    it 'sets the fact to nil if undefined' do
      resolver.validate_resolution('unresolved_fact')
      expect(resolver.resolve('unresolved_fact')).to be_nil
    end

    it 'does not overwrite values' do
      resolver.resolve('my_fact')
      resolver.validate_resolution('my_fact')

      expect(resolver.post_resolve('my_fact')).to eq({ 'my_fact' => 'value' })
    end
  end

  describe '#post_resolve' do
    let(:resolver) { Class.new(Facter::Resolvers::BaseResolver) }

    it 'raises NotImplementedError error' do
      expect { resolver.post_resolve(fact) }.to \
        raise_error(NotImplementedError,
                    'You must implement post_resolve(fact_name) method in ')
    end
  end
end
