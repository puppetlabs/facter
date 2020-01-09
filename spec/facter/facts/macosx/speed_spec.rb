# frozen_string_literal: true

describe 'Macosx ProcessorsSpeed' do
  context '#call_the_resolver' do
    it 'returns processors fact' do
      value = 1_800_000_000

      expected_fact = double(Facter::ResolvedFact, name: 'processors.speed', value: value)
      allow(Facter::Resolvers::Macosx::Processors).to receive(:resolve).with(:speed).and_return(value)
      allow(Facter::ResolvedFact).to receive(:new).with('processors.speed', value).and_return(expected_fact)

      fact = Facter::Macosx::ProcessorsSpeed.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
