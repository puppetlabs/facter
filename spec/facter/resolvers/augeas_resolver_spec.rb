# frozen_string_literal: true

describe Facter::Resolvers::Augeas do
  subject(:augeas) { Facter::Resolvers::Augeas }

  let(:log_spy) { instance_spy(Facter::Log) }

  before do
    augeas.instance_variable_set(:@log, log_spy)
  end

  after do
    augeas.invalidate_cache
  end

  context 'when augparse is installed' do
    before do
      allow(Facter::Core::Execution).to receive(:execute)
        .with('augparse --version 2>&1', logger: log_spy)
        .and_return('augparse 1.12.0 <http://augeas.net/>')
    end

    it 'returns build' do
      expect(augeas.resolve(:augeas_version)).to eq('1.12.0')
    end
  end

  context 'when augparse is not installed' do
    before do
      allow(Facter::Core::Execution).to receive(:execute)
        .with('augparse --version 2>&1', logger: log_spy)
        .and_return('sh: augparse: command not found')
    end

    context 'when augeas gem > 0.5.0 is installed' do
      before do
        allow(Gem).to receive(:loaded_specs).and_return({ 'augeas' => true })
        allow(Augeas).to receive(:create).and_return('1.12.0')
      end

      it 'returns build' do
        expect(augeas.resolve(:augeas_version)).to eq('1.12.0')
      end
    end

    context 'when augeas gem <= 0.5.0 is installed' do
      before do
        allow(Gem).to receive(:loaded_specs).and_return({})
        allow(Augeas).to receive(:open).and_return('1.12.0')
      end

      it 'returns build' do
        expect(augeas.resolve(:augeas_version)).to eq('1.12.0')
      end
    end

    context 'when augeas gem is not installed' do
      let(:exception) { LoadError.new('load_error_message') }

      before do
        allow(Facter::Resolvers::Augeas).to receive(:require).with('augeas').and_raise(exception)
      end

      it 'raises a LoadError error' do
        augeas.resolve(:augeas_version)

        expect(log_spy).to have_received(:debug).with('augeas is not available')
      end
    end
  end
end
