# frozen_string_literal: true

require_relative '../../spec_helper_legacy'

describe LegacyFacter::Core::Aggregate do
  subject(:aggregate_res) { LegacyFacter::Core::Aggregate.new('aggregated', fact) }

  let(:fact) { double('stub_fact', name: 'stub_fact') }

  it 'can be resolved' do
    expect(aggregate_res).to be_a_kind_of LegacyFacter::Core::Resolvable
  end

  it 'can be confined and weighted' do
    expect(aggregate_res).to be_a_kind_of LegacyFacter::Core::Suitable
  end

  describe 'setting options' do
    it 'can set the timeout' do
      aggregate_res.options(timeout: 314)
      expect(aggregate_res.limit).to eq 314
    end

    it 'can set the weight' do
      aggregate_res.options(weight: 27)
      expect(aggregate_res.weight).to eq 27
    end

    it 'can set the name' do
      aggregate_res.options(name: 'something')
      expect(aggregate_res.name).to eq 'something'
    end

    it 'fails on unhandled options' do
      expect do
        aggregate_res.options(foo: 'bar')
      end.to raise_error(ArgumentError, /Invalid aggregate options .*foo/)
    end

    it 'fact_type does not raise error' do
      expect { aggregate_res.options(fact_type: 'custom') }.not_to raise_error(ArgumentError)
    end
  end

  describe 'declaring chunks' do
    it 'requires that an chunk is given a block' do
      expect { aggregate_res.chunk(:fail) }.to raise_error(ArgumentError, /requires a block/)
    end

    it 'allows an chunk to have a list of requirements' do
      aggregate_res.chunk(:data, require: [:other]) {}
      expect(aggregate_res.deps[:data]).to eq [:other]
    end

    it 'converts a single chunk requirement to an array' do
      aggregate_res.chunk(:data, require: :other) {}
      expect(aggregate_res.deps[:data]).to eq [:other]
    end

    it 'raises an error when an unhandled option is passed' do
      expect do
        aggregate_res.chunk(:data, before: [:other]) {}
      end.to raise_error(ArgumentError, /Unexpected options.*#chunk: .*before/)
    end
  end

  describe 'handling interactions between chunks' do
    it 'generates a warning when there is a dependency cycle in chunks' do
      aggregate_res.chunk(:first, require: [:second]) {}
      aggregate_res.chunk(:second, require: [:first]) {}

      expect(LegacyFacter).to receive(:warn).with(/dependency cycles: .*[:first, :second]/)

      expect { aggregate_res.value }.to raise_error(Facter::ResolveCustomFactError)
    end

    it 'passes all requested chunk results to the depending chunk' do
      aggregate_res.chunk(:first) { ['foo'] }
      aggregate_res.chunk(:second, require: [:first]) do |first|
        [first[0] + ' bar']
      end

      output = aggregate_res.value
      expect(output).to include 'foo'
      expect(output).to include 'foo bar'
    end

    it 'clones and freezes chunk results passed to other chunks' do
      aggregate_res.chunk(:first) { 'foo' }
      aggregate_res.chunk(:second, require: [:first]) do |first|
        expect(first).to be_frozen
      end

      aggregate_res.aggregate do |chunks|
        chunks.values.each do |chunk|
          expect(chunk).to be_frozen
        end
      end
    end
  end

  describe 'aggregating chunks' do
    it 'passes all chunk results as a hash to the aggregate block' do
      aggregate_res.chunk(:data) { 'data chunk' }
      aggregate_res.chunk(:datum) { 'datum chunk' }

      aggregate_res.aggregate do |chunks|
        expect(chunks).to eq(data: 'data chunk', datum: 'datum chunk')
      end

      aggregate_res.value
    end

    it 'uses the result of the aggregate block as the value' do
      aggregate_res.aggregate { 'who needs chunks anyways' }
      expect(aggregate_res.value).to eq 'who needs chunks anyways'
    end
  end

  describe 'evaluating' do
    it 'evaluates the block in the context of the aggregate' do
      expect(aggregate_res).to receive(:has_weight).with(5)
      aggregate_res.evaluate { has_weight(5) }
    end
  end
end
