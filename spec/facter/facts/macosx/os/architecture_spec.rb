# frozen_string_literal: true

describe Facter::Macosx::OsArchitecture do
  describe '#call_the_resolver' do
    subject(:fact) { Facter::Macosx::OsArchitecture.new }

    let(:value) { 'x86_64' }

    before do
      allow(Facter::Resolvers::Uname).to receive(:resolve).with(:machine).and_return(value)
    end

    it 'calls Facter::Resolvers::Uname' do
      expect(Facter::Resolvers::Uname).to receive(:resolve).with(:machine)
      fact.call_the_resolver
    end

    it 'returns architecture fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'os.architecture', value: value),
                        an_object_having_attributes(name: 'architecture', value: value, type: :legacy))
    end
  end
end
