# frozen_string_literal: true

describe Facts::Sles::Os::Selinux::CurrentMode do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Sles::Os::Selinux::CurrentMode.new }

    let(:current_mode) { 'permissive' }

    before do
      allow(Facter::Resolvers::SELinux).to receive(:resolve).with(:current_mode).and_return(current_mode)
    end

    it 'calls Facter::Resolvers::SELinux' do
      fact.call_the_resolver
      expect(Facter::Resolvers::SELinux).to have_received(:resolve).with(:current_mode)
    end

    it 'returns architecture fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'os.selinux.current_mode', value: current_mode),
                        an_object_having_attributes(name: 'selinux_current_mode', value: current_mode, type: :legacy))
    end
  end
end
