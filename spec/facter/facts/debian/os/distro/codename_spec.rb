# frozen_string_literal: true

describe Facts::Debian::Os::Distro::Codename do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Debian::Os::Distro::Codename.new }

    context 'when version codename exists in os-release' do
      let(:value) { 'stretch' }

      before do
        allow(Facter::Resolvers::OsRelease).to receive(:resolve).with(:version_codename).and_return(value)
      end

      it 'calls Facter::Resolvers::OsRelease' do
        fact.call_the_resolver
        expect(Facter::Resolvers::OsRelease).to have_received(:resolve).with(:version_codename)
      end

      it 'returns os.distro.codename fact' do
        expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
          have_attributes(name: 'os.distro.codename', value: value)
      end
    end

    context 'when version codename does not exists in os-release on Ubuntu' do
      let(:value) { nil }
      let(:version) { '14.04.2 LTS, Trusty Tahr' }
      let(:result) { 'trusty' }

      before do
        allow(Facter::Resolvers::OsRelease).to receive(:resolve).with(:version_codename).and_return(value)
        allow(Facter::Resolvers::OsRelease).to receive(:resolve).with(:version).and_return(version)
      end

      it 'calls Facter::Resolvers::OsRelease with version_codename' do
        fact.call_the_resolver
        expect(Facter::Resolvers::OsRelease).to have_received(:resolve).with(:version_codename)
      end

      it 'calls Facter::Resolvers::OsRelease with version' do
        fact.call_the_resolver
        expect(Facter::Resolvers::OsRelease).to have_received(:resolve).with(:version)
      end

      it 'returns os.distro.codename fact' do
        expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
          have_attributes(name: 'os.distro.codename', value: result)
      end
    end

    context 'when version codename does not exists in os-release on Debian' do
      let(:value) { nil }
      let(:version) { '9 (stretch)' }
      let(:result) { 'stretch' }

      before do
        allow(Facter::Resolvers::OsRelease).to receive(:resolve).with(:version_codename).and_return(value)
        allow(Facter::Resolvers::OsRelease).to receive(:resolve).with(:version).and_return(version)
      end

      it 'calls Facter::Resolvers::OsRelease with version_codename' do
        fact.call_the_resolver
        expect(Facter::Resolvers::OsRelease).to have_received(:resolve).with(:version_codename)
      end

      it 'calls Facter::Resolvers::OsRelease with version' do
        fact.call_the_resolver
        expect(Facter::Resolvers::OsRelease).to have_received(:resolve).with(:version)
      end

      it 'returns os.distro.codename fact' do
        expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
          have_attributes(name: 'os.distro.codename', value: result)
      end
    end

    context 'when version codename and version do not exist in os-release' do
      let(:value) { nil }
      let(:version) { nil }
      let(:result) { nil }

      before do
        allow(Facter::Resolvers::OsRelease).to receive(:resolve).with(:version_codename).and_return(value)
        allow(Facter::Resolvers::OsRelease).to receive(:resolve).with(:version).and_return(version)
      end

      it 'calls Facter::Resolvers::OsRelease with version_codename' do
        fact.call_the_resolver
        expect(Facter::Resolvers::OsRelease).to have_received(:resolve).with(:version_codename)
      end

      it 'calls Facter::Resolvers::OsRelease with version' do
        fact.call_the_resolver
        expect(Facter::Resolvers::OsRelease).to have_received(:resolve).with(:version)
      end

      it 'returns os.distro.codename fact' do
        expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
          have_attributes(name: 'os.distro.codename', value: result)
      end
    end
  end
end
