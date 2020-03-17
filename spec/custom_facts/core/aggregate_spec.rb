# frozen_string_literal: true

require_relative '../../spec_helper_legacy'

describe LegacyFacter::Core::Aggregate do
  subject(:resolution) { LegacyFacter::Core::Aggregate.new('aggregated', fact) }

  let(:fact) { double('stub_fact', name: 'stub_fact') }

  it 'can be resolved' do
    expect(resolution).to be_a_kind_of LegacyFacter::Core::Resolvable
  end

  it 'can be confined and weighted' do
    expect(resolution).to be_a_kind_of LegacyFacter::Core::Suitable
  end

  describe 'setting options' do
    it 'can set the timeout' do
      resolution.options(timeout: 314)
      expect(resolution.limit).to eq 314
    end

    it 'can set the weight' do
      resolution.options(weight: 27)
      expect(resolution.weight).to eq 27
    end

    it 'can set the name' do
      resolution.options(name: 'something')
      expect(resolution.name).to eq 'something'
    end

    it 'fails on unhandled options' do
      expect do
        resolution.options(foo: 'bar')
      end.to raise_error(ArgumentError, /Invalid aggregate options .*foo/)
    end
  end

  describe 'declaring chunks' do
    it 'requires that an chunk is given a block' do
      expect { resolution.chunk(:fail) }.to raise_error(ArgumentError, /requires a block/)
    end

    it 'allows an chunk to have a list of requirements' do
      resolution.chunk(:data, require: [:other]) {}
      expect(resolution.deps[:data]).to eq [:other]
    end

    it 'converts a single chunk requirement to an array' do
      resolution.chunk(:data, require: :other) {}
      expect(resolution.deps[:data]).to eq [:other]
    end

    it 'raises an error when an unhandled option is passed' do
      expect do
        resolution.chunk(:data, before: [:other]) {}
      end.to raise_error(ArgumentError, /Unexpected options.*#chunk: .*before/)
    end
  end

  describe 'handling interactions between chunks' do
    it 'generates a warning when there is a dependency cycle in chunks' do
      resolution.chunk(:first, require: [:second]) {}
      resolution.chunk(:second, require: [:first]) {}

      expect(LegacyFacter).to receive(:warn).with(/dependency cycles: .*[:first, :second]/)

      expect { resolution.value }.to raise_error(Facter::ResolveCustomFactError)
    end

    it 'passes all requested chunk results to the depending chunk' do
      resolution.chunk(:first) { ['foo'] }
      resolution.chunk(:second, require: [:first]) do |first|
        [first[0] + ' bar']
      end

      output = resolution.value
      expect(output).to include 'foo'
      expect(output).to include 'foo bar'
    end

    it 'clones and freezes chunk results passed to other chunks' do
      resolution.chunk(:first) { 'foo' }
      resolution.chunk(:second, require: [:first]) do |first|
        expect(first).to be_frozen
      end

      resolution.aggregate do |chunks|
        chunks.values.each do |chunk|
          expect(chunk).to be_frozen
        end
      end
    end
  end

  describe 'aggregating chunks' do
    it 'passes all chunk results as a hash to the aggregate block' do
      resolution.chunk(:data) { 'data chunk' }
      resolution.chunk(:datum) { 'datum chunk' }

      resolution.aggregate do |chunks|
        expect(chunks).to eq(data: 'data chunk', datum: 'datum chunk')
      end

      resolution.value
    end

    it 'uses the result of the aggregate block as the value' do
      resolution.aggregate { 'who needs chunks anyways' }
      expect(resolution.value).to eq 'who needs chunks anyways'
    end
  end

  describe 'evaluating' do
    it 'evaluates the block in the context of the aggregate' do
      expect(resolution).to receive(:has_weight).with(5)
      resolution.evaluate { has_weight(5) }
    end
  end
end
