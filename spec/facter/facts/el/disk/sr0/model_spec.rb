# frozen_string_literal: true

describe 'Fedora DiskSr0Model' do
  context '#call_the_resolver' do
    it 'returns a fact' do
      expected_fact = double(Facter::ResolvedFact, name: 'disk.sr0.model', value: 'value')
      allow(Facter::Resolvers::Linux::Disk).to receive(:resolve).with(:sr0_model).and_return('value')
      allow(Facter::ResolvedFact).to receive(:new).with('disk.sr0.model', 'value').and_return(expected_fact)

      fact = Facter::El::DiskSr0Model.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
