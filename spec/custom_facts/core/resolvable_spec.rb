# frozen_string_literal: true

require_relative '../../spec_helper_legacy'

describe LegacyFacter::Core::Resolvable do
  class ResolvableClass
    def initialize(name)
      @name = name
      @fact = LegacyFacter::Util::Fact.new('stub fact')
    end
    attr_accessor :name, :resolve_value
    attr_reader :fact
    include LegacyFacter::Core::Resolvable
  end

  subject(:resolvable) { ResolvableClass.new('resolvable') }

  let(:logger) { instance_double(Facter::Log) }

  it 'has a default timeout of 0 seconds' do
    expect(resolvable.limit).to eq 0
  end

  it 'can specify a custom timeout' do
    resolvable.timeout = 10
    expect(resolvable.limit).to eq 10
  end

  describe 'generating a value' do
    it 'returns the results of #resolve_value' do
      resolvable.resolve_value = 'stuff'
      expect(resolvable.value).to eq 'stuff'
    end

    it 'normalizes the resolved value' do
      # Facter::Util::Normalization.expects(:normalize).returns 'stuff'
      expect(LegacyFacter::Util::Normalization).to receive(:normalize).and_return('stuff')
      resolvable.resolve_value = 'stuff'
      expect(resolvable.value).to eq('stuff')
    end

    it 'logs a warning if an exception was raised' do
      allow(Facter::Log).to receive(:new).and_return(logger)
      resolvable.instance_variable_set(:@logger, logger)

      expect(resolvable).to receive(:resolve_value).and_raise RuntimeError, 'kaboom!'
      expect(resolvable.logger).to receive(:error)
        .with("Error while resolving custom fact fact='stub fact', " \
          "resolution='resolvable': kaboom!")
      expect { resolvable.value }.to raise_error(Facter::ResolveCustomFactError)
    end
  end

  describe 'timing out' do
    it 'uses #limit instead of #timeout to determine the timeout period' do
      expect(resolvable).not_to receive(:timeout)
      expect(resolvable).to receive(:limit).and_return(25)
      expect(Timeout).to receive(:timeout).with(25)

      resolvable.value
    end

    it 'returns nil if the timeout was reached' do
      allow(Facter::Log).to receive(:new).and_return(logger)
      resolvable.instance_variable_set(:@logger, logger)

      expect(resolvable.logger).to receive(:error).with(/Timed out after 0\.1 seconds while resolving/)
      expect(Timeout).to receive(:timeout).and_raise Timeout::Error

      resolvable.timeout = 0.1

      expect(resolvable.value).to be_nil
    end
  end

  describe 'callbacks when flushing facts' do
    class FlushFakeError < StandardError; end

    describe '#on_flush' do
      it 'accepts a block with on_flush' do
        resolvable.on_flush { raise NotImplementedError }
      end
    end

    describe '#flush' do
      it 'calls the block passed to on_flush' do
        resolvable.on_flush { raise FlushFakeError }
        expect { resolvable.flush }.to raise_error FlushFakeError
      end
    end
  end
end
