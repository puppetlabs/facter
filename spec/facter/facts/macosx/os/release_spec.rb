# frozen_string_literal: true

# fozen_string_literal: true

describe Facts::Macosx::Os::Release do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Macosx::Os::Release.new }

    let(:resolver_output) { '10.9' }
    let(:version) { { 'full' => '10.9', 'major' => '10', 'minor' => '9' } }

    before do
      allow(Facter::Resolvers::Uname).to \
        receive(:resolve).with(:kernelrelease).and_return(resolver_output)
    end

    it 'calls Facter::Resolvers::Uname' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Uname).to have_received(:resolve).with(:kernelrelease)
    end

    it 'returns a resolved fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'os.release', value: version),
                        an_object_having_attributes(name: 'operatingsystemmajrelease', value: version['major'],
                                                    type: :legacy),
                        an_object_having_attributes(name: 'operatingsystemrelease', value: resolver_output,
                                                    type: :legacy))
    end
  end
end
