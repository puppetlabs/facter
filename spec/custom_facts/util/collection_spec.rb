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

  it 'should delegate its load_all method to its loader' do
    expect(internal_loader).to receive(:load_all)

    collection.load_all
  end

  describe 'when adding facts' do
    it 'should create a new fact if no fact with the same name already exists' do
      collection.add(:myname)
      expect(collection.fact(:myname).name).to eq :myname
    end

    it 'should accept options' do
      collection.add(:myname, timeout: 1) {}
    end

    it 'passes resolution specific options to the fact' do
      fact = LegacyFacter::Util::Fact.new(:myname)
      expect(LegacyFacter::Util::Fact).to receive(:new).with(:myname, timeout: 'myval').and_return(fact)

      expect(fact).to receive(:add).with(timeout: 'myval')

      collection.add(:myname, timeout: 'myval') {}
    end

    describe 'and a block is provided' do
      it 'should use the block to add a resolution to the fact' do
        fact = double 'fact'
        # allow(fact).to receive(:extract_ldapname_option!)
        expect(LegacyFacter::Util::Fact).to receive(:new).and_return(fact)

        expect(fact).to receive(:add)

        collection.add(:myname) {}
      end

      it 'should discard resolutions that throw an exception when added' do
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
      fact = LegacyFacter::Util::Fact.new(:newfact)
      expect(LegacyFacter::Util::Fact).to receive(:new).with(:newfact, {}).and_return fact
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

    it 'logs a warning if the fact could not be defined' do
      expect(LegacyFacter).to receive(:warn).with('Unable to add fact newfact: kaboom!')

      collection.define_fact(:newfact) do
        raise 'kaboom!'
      end
    end
  end

  describe 'when retrieving facts' do
    before do
      @fact = collection.add('YayNess')
    end

    it 'should return the fact instance specified by the name' do
      expect(collection.fact('YayNess')).to equal(@fact)
    end

    it 'should be case-insensitive' do
      expect(collection.fact('yayness')).to equal(@fact)
    end

    it 'should treat strings and symbols equivalently' do
      expect(collection.fact(:yayness)).to equal(@fact)
    end

    it 'should use its loader to try to load the fact if no fact can be found' do
      expect(collection.internal_loader).to receive(:load).with(:testing)
      collection.fact('testing')
    end

    it 'should return nil if it cannot find or load the fact' do
      expect(collection.internal_loader).to receive(:load).with(:testing)
      expect(collection.fact('testing')).to be nil
    end
  end

  describe "when returning a fact's value" do
    before do
      @fact = collection.add('YayNess', value: 'result')
    end

    it 'should return the result of calling :value on the fact' do
      expect(collection.value('YayNess')).to eq 'result'
    end

    it 'should be case-insensitive' do
      expect(collection.value('yayness')).to eq 'result'
    end

    it 'should treat strings and symbols equivalently' do
      expect(collection.value(:yayness)).to eq 'result'
    end

    describe 'when the fact is a core fact' do
      it 'should call the core_value method' do
        expect(Facter).to receive(:core_value).with('core_fact')
        collection.value('core_fact')
      end
    end

    describe 'when the weight of the resolution is 0' do
      it 'should return core facts value is it exists' do
        expect(Facter).to receive(:core_value).with('yayness').and_return('core_result')
        expect(collection.value('yayness')).to eq('core_result')
      end
    end

    describe 'when the weight of the resolution is greater than 0' do
      it 'shoudl return the custom fact value' do
        expect(collection.value('yayness')).to eq('result')
      end
    end
  end

  # describe 'when retriving a core fact' do
  #   before do
  #     # @fact = collection.add('YayNess', value: 'result')
  #   end
  # end

  it "should return the fact's value when the array index method is used" do
    collection.add('myfact', value: 'foo')

    expect(collection['myfact']).to eq 'foo'
  end

  it 'should have a method for flushing all facts' do
    fact = collection.add('YayNess')

    expect(fact).to receive(:flush)

    collection.flush
  end

  it 'should have a method that returns all fact names' do
    collection.add(:one)
    collection.add(:two)

    expect(collection.list.sort { |a, b| a.to_s <=> b.to_s }).to eq %i[one two]
  end

  describe 'when returning a hash of values' do
    it 'should return a hash of fact names and values with the fact names as strings' do
      collection.add(:one, value: 'me')

      expect(collection.to_hash).to eq 'one' => 'me'
    end

    it 'should not include facts that did not return a value' do
      collection.add(:two, value: nil)

      expect(collection.to_hash).not_to be_include(:two)
    end
  end

  describe 'when iterating over facts' do
    before do
      collection.add(:one, value: 'ONE')
      collection.add(:two, value: 'TWO')
    end

    it 'should yield each fact name and the fact value' do
      facts = {}
      collection.each do |fact, value|
        facts[fact] = value
      end
      expect(facts).to eq 'one' => 'ONE', 'two' => 'TWO'
    end

    it 'should convert the fact name to a string' do
      collection.each do |fact, _value|
        expect(fact).to be_instance_of(String)
      end
    end

    it 'should only yield facts that have values' do
      collection.add(:nil_fact, value: nil)
      facts = {}
      collection.each do |fact, value|
        facts[fact] = value
      end

      expect(facts).not_to be_include('nil_fact')
    end
  end

  describe 'when no facts are loaded' do
    it 'should warn when no facts were loaded' do
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
