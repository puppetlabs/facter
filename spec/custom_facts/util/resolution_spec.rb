#! /usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper_legacy'

describe Facter::Util::Resolution do
  subject(:resolution) { Facter::Util::Resolution.new(:foo, stub_fact) }

  let(:stub_fact) { double('fact', name: :stubfact) }

  it 'requires a name' do
    expect { Facter::Util::Resolution.new }.to raise_error(ArgumentError)
  end

  it 'requires a fact' do
    expect { Facter::Util::Resolution.new('yay') }.to raise_error(ArgumentError)
  end

  it 'can return its name' do
    expect(resolution.name).to eq :foo
  end

  it 'can explicitly set a value' do
    resolution.value = 'foo'
    expect(resolution.value).to eq 'foo'
  end

  it 'defaults to nil for code' do
    expect(resolution.code).to be_nil
  end

  describe 'when setting the code' do
    before do
      allow(LegacyFacter).to receive(:warnonce)
    end

    it 'creates a block when given a command' do
      resolution.setcode 'foo'
      expect(resolution.code).to be_a_kind_of Proc
    end

    it 'stores the provided block when given a block' do
      block = -> {}
      resolution.setcode(&block)
      expect(resolution.code).to equal(block)
    end

    it 'prefers a command over a block' do
      block = -> {}
      resolution.setcode('foo', &block)
      expect(resolution.code).not_to eq block
    end

    it 'fails if neither a string nor block has been provided' do
      expect { resolution.setcode }.to raise_error(ArgumentError)
    end
  end

  describe 'when returning the value' do
    it 'returns any value that has been provided' do
      resolution.value = 'foo'
      expect(resolution.value).to eq 'foo'
    end

    describe 'and setcode has not been called' do
      it 'returns nil' do
        expect(resolution.value).to be_nil
      end
    end

    describe 'and the code is a string' do
      it 'returns the result of executing the code' do
        resolution.setcode '/bin/foo'
        expect(LegacyFacter::Core::Execution).to receive(:execute).once.with('/bin/foo', anything).and_return('yup')

        expect(resolution.value).to eq 'yup'
      end
    end

    describe 'and the code is a block' do
      it 'returns the value returned by the block' do
        resolution.setcode { 'yayness' }
        expect(resolution.value).to eq 'yayness'
      end
    end
  end

  describe 'setting options' do
    it 'can set the value' do
      resolution.options(value: 'something')
      expect(resolution.value).to eq 'something'
    end

    it 'can set the timeout' do
      resolution.options(timeout: 314)
      expect(resolution.limit).to eq 314
    end

    it 'can set the weight' do
      resolution.options(weight: 27)
      expect(resolution.weight).to eq 27
    end

    it 'fact_type does not raise error' do
      expect { resolution.options(fact_type: 'simple') }.not_to raise_error(ArgumentError)
    end

    it 'fails on unhandled options' do
      expect do
        resolution.options(foo: 'bar')
      end.to raise_error(ArgumentError, /Invalid resolution options.*foo/)
    end
  end

  describe '#has_weight' do
    it 'returns the class instance' do
      expect(resolution.has_weight(42)).to be(resolution)
    end
  end

  describe 'evaluating' do
    it 'evaluates the block in the context of the given resolution' do
      expect(resolution).to receive(:weight).with(5)
      resolution.evaluate { weight(5) }
    end

    it 'raises a warning if the resolution is evaluated twice' do
      expect(LegacyFacter).to receive(:warn).with(/Already evaluated foo at.*reevaluating anyways/)

      resolution.evaluate {}
      resolution.evaluate {}
    end
  end
end
