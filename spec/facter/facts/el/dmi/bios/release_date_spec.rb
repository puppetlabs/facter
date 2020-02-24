# frozen_string_literal: true

describe Facter::El::DmiBiosReleaseDate do
  describe '#call_the_resolver' do
    it 'returns a fact' do
      value = '07/03/2018'
      expected_fact = double(Facter::ResolvedFact, name: 'dmi.bios.release_date', value: value)
      allow(Facter::Resolvers::Linux::DmiBios).to receive(:resolve).with(:bios_date).and_return(value)
      allow(Facter::ResolvedFact).to receive(:new).with('dmi.bios.release_date', value).and_return(expected_fact)

      fact = Facter::El::DmiBiosReleaseDate.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
