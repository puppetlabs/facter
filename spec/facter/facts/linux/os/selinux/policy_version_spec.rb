# frozen_string_literal: true

describe Facts::Linux::Os::Selinux::PolicyVersion do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Linux::Os::Selinux::PolicyVersion.new }

    let(:policy_version) { '31' }

    before do
      allow(Facter::Resolvers::SELinux).to receive(:resolve).with(:policy_version).and_return(policy_version)
    end

    it 'calls Facter::Resolvers::SELinux' do
      fact.call_the_resolver
      expect(Facter::Resolvers::SELinux).to have_received(:resolve).with(:policy_version)
    end

    it 'returns architecture fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'os.selinux.policy_version', value: policy_version),
                        an_object_having_attributes(name: 'selinux_policyversion',
                                                    value: policy_version, type: :legacy))
    end
  end
end
