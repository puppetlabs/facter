# frozen_string_literal: true

describe Facts::Macosx::Processors::Cores do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Macosx::Processors::Cores.new }

    let(:cores_per_socket) { 4 }

    before do
      allow(Facter::Resolvers::Macosx::Processors).to \
        receive(:resolve).with(:cores_per_socket).and_return(cores_per_socket)
    end

    it 'returns a resolved fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
        have_attributes(name: 'processors.cores', value: cores_per_socket)
    end
  end
end
