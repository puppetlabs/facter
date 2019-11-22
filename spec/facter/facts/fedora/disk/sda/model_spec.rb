# frozen_string_literal: true

describe 'Fedora DiskSdaModel' do
  context '#call_the_resolver' do
    it 'returns a fact' do
      expected_fact = double(Facter::ResolvedFact, name: 'disk.sda.model', value: 'value')
      allow(Facter::Resolvers::Linux::Disk).to receive(:resolve).with(:sda_model).and_return('value')
      allow(Facter::ResolvedFact).to receive(:new).with('disk.sda.model', 'value').and_return(expected_fact)

      fact = Facter::Fedora::DiskSdaModel.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
