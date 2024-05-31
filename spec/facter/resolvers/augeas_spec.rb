# frozen_string_literal: true

describe Facter::Resolvers::Augeas do
  subject(:augeas) { Facter::Resolvers::Augeas }

  let(:readable) { false }

  before do
    allow(File).to receive(:readable?).with('/opt/puppetlabs/puppet/bin/augparse').and_return(readable)
  end

  after do
    augeas.invalidate_cache
  end

  context 'when augparse is installed' do
    before do
      allow(Facter::Core::Execution).to receive(:execute)
        .with('augparse --version 2>&1', logger: an_instance_of(Facter::Log))
        .and_return('augparse 1.12.0 <http://augeas.net/>')
    end

    it 'returns build' do
      expect(augeas.resolve(:augeas_version)).to eq('1.12.0')
    end
  end

  context 'when augparse is installed with puppet-agent package on unix based systems' do
    let(:readable) { true }

    before do
      allow(Facter::Core::Execution).to receive(:execute)
        .with('/opt/puppetlabs/puppet/bin/augparse --version 2>&1', logger: an_instance_of(Facter::Log))
        .and_return('augparse 1.12.0 <http://augeas.net/>')
    end

    it 'returns build' do
      expect(augeas.resolve(:augeas_version)).to eq('1.12.0')
    end
  end

  context 'when augparse is not installed' do
    before do
      allow(Facter::Core::Execution).to receive(:execute)
        .with('augparse --version 2>&1', logger: an_instance_of(Facter::Log))
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

      it 'rescues LoadError error and logs at debug level' do
        allow(augeas.log).to receive(:debug)
        expect(augeas.log).to receive(:debug).with(/Resolving fact augeas_version, but got load_error_message/)

        augeas.resolve(:augeas_version)
      end
    end
  end
end
