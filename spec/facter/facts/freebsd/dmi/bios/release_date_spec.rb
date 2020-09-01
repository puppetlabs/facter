# frozen_string_literal: true

describe Facts::Freebsd::Dmi::Bios::ReleaseDate do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Freebsd::Dmi::Bios::ReleaseDate.new }

    let(:date) { '07/03/2018' }

    before do
      allow(Facter::Resolvers::Freebsd::DmiBios).to \
        receive(:resolve).with(:bios_date).and_return(date)
    end

    it 'calls Facter::Resolvers::Freebsd::DmiBios' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Freebsd::DmiBios).to have_received(:resolve).with(:bios_date)
    end

    it 'returns bios release date fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'dmi.bios.release_date', value: date),
                        an_object_having_attributes(name: 'bios_release_date', value: date, type: :legacy))
    end
  end
end
