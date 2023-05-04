# frozen_string_literal: true

describe Facts::Macosx::Os::Macosx::Version do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Macosx::Os::Macosx::Version.new }

    context 'when macOS version < 11' do
      let(:resolver_output) { '10.9.8' }
      let(:resolver_extra_output) { nil }
      let(:version) { { 'full' => '10.9.8', 'major' => '10.9', 'minor' => '8' } }

      before do
        allow(Facter::Resolvers::SwVers).to \
          receive(:resolve).with(:productversion).and_return(resolver_output)
        allow(Facter::Resolvers::SwVers).to \
          receive(:resolve).with(:productversionextra).and_return(resolver_extra_output)
      end

      it 'calls Facter::Resolvers::SwVers' do
        fact.call_the_resolver
        expect(Facter::Resolvers::SwVers).to have_received(:resolve).with(:productversion)
      end

      it 'returns a resolved fact' do
        expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
          contain_exactly(an_object_having_attributes(name: 'os.macosx.version', value: version),
                          an_object_having_attributes(name: 'macosx_productversion', value: resolver_output,
                                                      type: :legacy),
                          an_object_having_attributes(name: 'macosx_productversion_major', value: version['major'],
                                                      type: :legacy),
                          an_object_having_attributes(name: 'macosx_productversion_minor', value: version['minor'],
                                                      type: :legacy),
                          an_object_having_attributes(name: 'macosx_productversion_patch', value: version['patch'],
                                                      type: :legacy))
      end
    end

    context 'when macOS version >= 11 and < 13' do
      let(:resolver_output) { '11.2.1' }
      let(:resolver_extra_output) { nil }
      let(:version) { { 'full' => '11.2.1', 'major' => '11', 'minor' => '2', 'patch' => '1' } }

      before do
        allow(Facter::Resolvers::SwVers).to \
          receive(:resolve).with(:productversion).and_return(resolver_output)
        allow(Facter::Resolvers::SwVers).to \
          receive(:resolve).with(:productversionextra).and_return(resolver_extra_output)
      end

      it 'calls Facter::Resolvers::SwVers' do
        fact.call_the_resolver
        expect(Facter::Resolvers::SwVers).to have_received(:resolve).with(:productversion)
      end

      it 'returns a resolved fact' do
        expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
          contain_exactly(an_object_having_attributes(name: 'os.macosx.version', value: version),
                          an_object_having_attributes(name: 'macosx_productversion', value: resolver_output,
                                                      type: :legacy),
                          an_object_having_attributes(name: 'macosx_productversion_major', value: version['major'],
                                                      type: :legacy),
                          an_object_having_attributes(name: 'macosx_productversion_minor', value: version['minor'],
                                                      type: :legacy),
                          an_object_having_attributes(name: 'macosx_productversion_patch', value: version['patch'],
                                                      type: :legacy))
      end
    end

    context 'when macOS version >= 13' do
      let(:resolver_output) { '13.3.1' }
      let(:resolver_extra_output) { nil }
      let(:version) { { 'full' => '13.3.1', 'major' => '13', 'minor' => '3', 'patch' => '1' } }

      before do
        allow(Facter::Resolvers::SwVers).to \
          receive(:resolve).with(:productversion).and_return(resolver_output)
        allow(Facter::Resolvers::SwVers).to \
          receive(:resolve).with(:productversionextra).and_return(resolver_extra_output)
      end

      it 'calls Facter::Resolvers::SwVers' do
        fact.call_the_resolver
        expect(Facter::Resolvers::SwVers).to have_received(:resolve).with(:productversion)
        expect(Facter::Resolvers::SwVers).to have_received(:resolve).with(:productversionextra)
      end

      it 'returns a resolved fact' do
        expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
          contain_exactly(an_object_having_attributes(name: 'os.macosx.version', value: version),
                          an_object_having_attributes(name: 'macosx_productversion', value: resolver_output,
                                                      type: :legacy),
                          an_object_having_attributes(name: 'macosx_productversion_major', value: version['major'],
                                                      type: :legacy),
                          an_object_having_attributes(name: 'macosx_productversion_minor', value: version['minor'],
                                                      type: :legacy),
                          an_object_having_attributes(name: 'macosx_productversion_patch', value: version['patch'],
                                                      type: :legacy))
      end
    end

    context 'when macOS version >= 13 with RSR' do
      let(:resolver_output) { '13.3.1' }
      let(:resolver_extra_output) { '(a)' }
      let(:version) { { 'full' => '13.3.1', 'major' => '13', 'minor' => '3', 'patch' => '1', 'extra' => '(a)' } }

      before do
        allow(Facter::Resolvers::SwVers).to \
          receive(:resolve).with(:productversion).and_return(resolver_output)
        allow(Facter::Resolvers::SwVers).to \
          receive(:resolve).with(:productversionextra).and_return(resolver_extra_output)
      end

      it 'calls Facter::Resolvers::SwVers' do
        fact.call_the_resolver
        expect(Facter::Resolvers::SwVers).to have_received(:resolve).with(:productversion)
        expect(Facter::Resolvers::SwVers).to have_received(:resolve).with(:productversionextra)
      end

      it 'returns a resolved fact' do
        expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
          contain_exactly(an_object_having_attributes(name: 'os.macosx.version', value: version),
                          an_object_having_attributes(name: 'macosx_productversion', value: resolver_output,
                                                      type: :legacy),
                          an_object_having_attributes(name: 'macosx_productversion_major', value: version['major'],
                                                      type: :legacy),
                          an_object_having_attributes(name: 'macosx_productversion_minor', value: version['minor'],
                                                      type: :legacy),
                          an_object_having_attributes(name: 'macosx_productversion_patch', value: version['patch'],
                                                      type: :legacy))
      end
    end
  end
end
