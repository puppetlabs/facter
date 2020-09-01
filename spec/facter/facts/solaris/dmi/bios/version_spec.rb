# frozen_string_literal: true

describe Facts::Solaris::Dmi::Bios::Version do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Solaris::Dmi::Bios::Version.new }

    let(:version) { '6.00' }

    before do
      allow(Facter::Resolvers::Solaris::Dmi).to \
        receive(:resolve).with(:bios_version).and_return(version)
      allow(Facter::Resolvers::Uname).to \
        receive(:resolve).with(:processor).and_return('i386')
    end

    it 'calls Facter::Resolvers::Solaris::Dmi' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Solaris::Dmi).to have_received(:resolve).with(:bios_version)
    end

    it 'returns bios version fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'dmi.bios.version', value: version),
                        an_object_having_attributes(name: 'bios_version', value: version, type: :legacy))
    end
  end
end
