#! /usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper_legacy'

describe LegacyFacter::Util::Collection do
  let(:external_loader) { LegacyFacter::Util::NothingLoader.new }
  let(:internal_loader) do
    load = LegacyFacter::Util::Loader.new
    allow(load).to receive(:load).and_return nil
    allow(load).to receive(:load_all).and_return nil
    load
  end
  let(:collection) { LegacyFacter::Util::Collection.new(internal_loader, external_loader) }

  it 'delegates its load_all method to its loader' do
    expect(internal_loader).to receive(:load_all)

    collection.load_all
  end

  describe 'when adding facts' do
    it 'creates a new fact if no fact with the same name already exists' do
      collection.add(:myname)
      expect(collection.fact(:myname).name).to eq :myname
    end

    it 'accepts options' do
      collection.add(:myname, timeout: 1) {}
    end

    it 'passes resolution specific options to the fact' do
      fact = Facter::Util::Fact.new(:myname)
      expect(Facter::Util::Fact).to receive(:new).with(:myname, timeout: 'myval').and_return(fact)

      expect(fact).to receive(:add).with(timeout: 'myval')

      collection.add(:myname, timeout: 'myval') {}
    end

    describe 'and a block is provided' do
      it 'uses the block to add a resolution to the fact' do
        fact = double 'fact'
        # allow(fact).to receive(:extract_ldapname_option!)
        expect(Facter::Util::Fact).to receive(:new).and_return(fact)

        expect(fact).to receive(:add)

        collection.add(:myname) {}
      end

      it 'discards resolutions that throw an exception when added' do
        expect(LegacyFacter).to receive(:warn).with(/Unable to add resolve .* kaboom!/)
        expect do
          collection.add('yay') do
            raise 'kaboom!'
          end
        end.not_to raise_error
        expect(collection.value('yay')).to be_nil
      end
    end
  end

  describe 'when only defining facts' do
    it 'creates a new fact if no such fact exists' do
      fact = Facter::Util::Fact.new(:newfact)
      expect(Facter::Util::Fact).to receive(:new).with(:newfact, {}).and_return fact
      expect(collection.define_fact(:newfact)).to equal fact
    end

    it 'returns an existing fact if the fact has already been defined' do
      fact = collection.define_fact(:newfact)
      expect(collection.define_fact(:newfact)).to equal fact
    end

    it 'passes options to newly generated facts' do
      allow(LegacyFacter).to receive(:warnonce)
      fact = collection.define_fact(:newfact, ldapname: 'NewFact')
      expect(fact.ldapname).to eq 'NewFact'
    end

    it 'logs an error if the fact could not be defined' do
      expect(Facter).to receive(:log_exception).with(StandardError, 'Unable to add fact newfact: kaboom!')

      collection.define_fact(:newfact) do
        raise 'kaboom!'
      end
    end
  end

  describe 'when retrieving facts' do
    before do
      @fact = collection.add('YayNess')
    end

    it 'returns the fact instance specified by the name' do
      expect(collection.fact('YayNess')).to equal(@fact)
    end

    it 'is case-insensitive' do
      expect(collection.fact('yayness')).to equal(@fact)
    end

    it 'treats strings and symbols equivalently' do
      expect(collection.fact(:yayness)).to equal(@fact)
    end

    it 'uses its loader to try to load the fact if no fact can be found' do
      expect(collection.internal_loader).to receive(:load).with(:testing)
      collection.fact('testing')
    end

    it 'returns nil if it cannot find or load the fact' do
      expect(collection.internal_loader).to receive(:load).with(:testing)
      expect(collection.fact('testing')).to be nil
    end
  end

  describe "when returning a fact's value" do
    before do
      collection.add('YayNess', value: 'result', weight: 0)
      collection.add('my_fact', value: 'my_fact_value', weight: 0)
      collection.add('nil_core_value_custom', value: 'custom_fact_value', weight: 0)
    end

    it 'returns the result of calling :value on the fact' do
      expect(collection.value('YayNess')).to eq 'result'
    end

    it 'is case-insensitive' do
      expect(collection.value('yayness')).to eq 'result'
    end

    it 'treats strings and symbols equivalently' do
      expect(collection.value(:yayness)).to eq 'result'
    end

    describe 'when the weight of the resolution is 0' do
      before do
        allow(Facter).to receive(:core_value).with('yayness').and_return('core_result')
        allow(Facter).to receive(:core_value).with('my_fact').and_return(nil)
        allow(Facter).to receive(:core_value).with('non_existing_fact')
        allow(Facter).to receive(:core_value).with('nil_core_value_custom').and_return(nil)
      end

      context 'when there is a custom fact with the name in collection' do
        it 'calls Facter.core_value' do
          collection.value('yayness')

          expect(Facter).to have_received(:core_value).with('yayness')
        end

        it 'returns core facts value' do
          expect(collection.value('yayness')).to eq('core_result')
        end
      end

      context 'when there is no custom fact with the name in collection' do
        it 'calls Facter.core_value' do
          collection.value('non_existing_fact')

          expect(Facter).to have_received(:core_value).with('non_existing_fact')
        end

        it 'returns custom facts value' do
          expect(collection.value('my_fact')).to eq('my_fact_value')
        end
      end

      context 'when core fact is nil and custom fact has value' do
        it 'returns custom fact' do
          expect(collection.value('nil_core_value_custom')).to eq('custom_fact_value')
        end
      end
    end

    describe 'when the weight of the resolution is greater than 0' do
      before do
        collection.add('100_weight_fact', value: 'my_weight_fact_value', weight: 100)
        collection.add('100_weight_nil_fact', value: nil, weight: 100)

        allow(Facter).to receive(:core_value).with('100_weight_fact').and_return('core_result')
        allow(Facter).to receive(:core_value).with('100_weight_nil_fact').and_return('core_100_weight_nil_fact_value')
        allow(Facter).to receive(:core_value).with('core_fact_only').and_return('core_fact_only_value')
        allow(Facter).to receive(:core_value).with('no_fact').and_return(nil)
      end

      context 'when there is a custom fact with the name in collection' do
        it 'returns the custom fact value' do
          expect(collection.value('100_weight_fact')).to eq('my_weight_fact_value')
        end
      end

      context 'when the custom fact returns nil' do
        it 'returns core fact value' do
          expect(collection.value('100_weight_nil_fact')).to eq('core_100_weight_nil_fact_value')
        end
      end

      context 'when no custom fact and one core fact with the name' do
        it 'returns the core fact value' do
          expect(collection.value('core_fact_only')).to eq('core_fact_only_value')
        end
      end

      context 'when no custom fact and no core fact with the name' do
        it 'returns nil' do
          expect(collection.value('no_fact')).to be_nil
        end
      end
    end
  end

  # describe 'when retriving a core fact' do
  #   before do
  #     # @fact = collection.add('YayNess', value: 'result')
  #   end
  # end

  it "returns the fact's value when the array index method is used" do
    collection.add('myfact', value: 'foo')

    expect(collection['myfact']).to eq 'foo'
  end

  it 'has a method for flushing all facts' do
    fact = collection.add('YayNess')

    expect(fact).to receive(:flush)

    collection.flush
  end

  it 'has a method that returns all fact names' do
    collection.add(:one)
    collection.add(:two)

    expect(collection.list.sort_by(&:to_s)).to eq %i[one two]
  end

  describe 'when returning a hash of values' do
    it 'returns a hash of fact names and values with the fact names as strings' do
      collection.add(:one, value: 'me')

      expect(collection.to_hash).to eq 'one' => 'me'
    end

    it 'does not include facts that did not return a value' do
      collection.add(:two, value: nil)

      expect(collection.to_hash).not_to be_include(:two)
    end
  end

  describe 'when iterating over facts' do
    before do
      collection.add(:one, value: 'ONE')
      collection.add(:two, value: 'TWO')
    end

    it 'yields each fact name and the fact value' do
      facts = {}
      collection.each do |fact, value|
        facts[fact] = value
      end
      expect(facts).to eq 'one' => 'ONE', 'two' => 'TWO'
    end

    it 'converts the fact name to a string' do
      collection.each do |fact, _value|
        expect(fact).to be_instance_of(String)
      end
    end

    it 'onlies yield facts that have values' do
      collection.add(:nil_fact, value: nil)
      facts = {}
      collection.each do |fact, value|
        facts[fact] = value
      end

      expect(facts).not_to be_include('nil_fact')
    end
  end

  describe 'when no facts are loaded' do
    it 'warns when no facts were loaded' do
      expect(LegacyFacter)
        .to receive(:warnonce)
        .with("No facts loaded from #{internal_loader.search_path.join(File::PATH_SEPARATOR)}").once

      collection.fact('one')
    end
  end

  describe 'external facts' do
    let(:external_loader) { SingleFactLoader.new(:test_fact, 'fact value') }
    let(:collection) { LegacyFacter::Util::Collection.new(internal_loader, external_loader) }

    it 'loads when a specific fact is requested' do
      expect(collection.fact(:test_fact).value).to eq 'fact value'
    end

    it 'loads when facts are listed' do
      expect(collection.list).to eq [:test_fact]
    end

    it 'loads when all facts are iterated over' do
      facts = []
      collection.each { |fact_name, fact_value| facts << [fact_name, fact_value] }

      expect(facts).to eq [['test_fact', 'fact value']]
    end

    it 'are loaded only once' do
      expect(external_loader).to receive(:load).with(collection)

      collection.load_all
      collection.load_all
    end

    it 'are reloaded after flushing' do
      expect(external_loader).to receive(:load).with(collection).twice

      collection.load_all
      collection.flush
      collection.load_all
    end
  end

  describe '#custom_facts' do
    it 'loads no facts' do
      expect(collection.custom_facts).to be_empty
    end

    context 'when custom facts are valid' do
      before do
        collection.instance_variable_set(:@custom_facts, ['my_custom_fact'])
        collection.instance_variable_set(:@valid_custom_facts, true)
      end

      it 'return one custom fact' do
        expect(collection.custom_facts.size).to eq(1)
      end

      it 'returns already loaded custom facts' do
        expect(collection.custom_facts.first).to eq('my_custom_fact')
      end
    end

    context 'when custom fact are invalid' do
      before do
        collection.add('my_fact', fact_type: :custom) {}
      end

      it 'returns one fact' do
        expect(collection.custom_facts.size).to eq(1)
      end

      it 'returns my_fact custom fact' do
        expect(collection.custom_facts.first).to eq(:my_fact)
      end
    end

    context 'when reload custom facts' do
      before do
        collection.instance_variable_set(:@custom_facts, ['old_fact'])
        collection.instance_variable_set(:@valid_custom_facts, false)
        collection.instance_variable_set(:@loaded, false)
        collection.add('new_fact', fact_type: :custom) {}
      end

      it 'loads all internal facts' do
        collection.custom_facts

        expect(internal_loader).to have_received(:load_all)
      end

      it 'loads one fact' do
        expect(collection.custom_facts.size). to eq(1)
      end

      it 'loads the new fact' do
        expect(collection.custom_facts.first). to eq(:new_fact)
      end
    end

    context "when don't reload custom facts" do
      before do
        collection.instance_variable_set(:@custom_facts, ['old_fact'])
        collection.instance_variable_set(:@valid_custom_facts, false)
        collection.instance_variable_set(:@loaded, true)
        collection.add('new_fact', fact_type: :custom) {}
      end

      it 'loads no internal facts' do
        collection.custom_facts

        expect(internal_loader).not_to have_received(:load_all)
      end

      it 'loads one fact' do
        expect(collection.custom_facts.size). to eq(1)
      end

      it 'loads the new fact' do
        expect(collection.custom_facts.first). to eq(:new_fact)
      end
    end
  end

  class SingleFactLoader
    def initialize(name, value)
      @name = name
      @value = value
    end

    def load(collection)
      collection.add(@name, value: @value)
    end
  end
end
