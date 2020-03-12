# frozen_string_literal: true

describe Facts::El::Os::Selinux::ConfigPolicy do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::El::Os::Selinux::ConfigPolicy.new }

    let(:config_policy) { 'targeted' }

    before do
      allow(Facter::Resolvers::SELinux).to receive(:resolve).with(:config_policy).and_return(config_policy)
    end

    it 'calls Facter::Resolvers::SELinux' do
      fact.call_the_resolver
      expect(Facter::Resolvers::SELinux).to have_received(:resolve).with(:config_policy)
    end

    it 'returns architecture fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'os.selinux.config_policy', value: config_policy),
                        an_object_having_attributes(name: 'selinux_config_policy', value: config_policy, type: :legacy))
    end
  end
end
