# frozen_string_literal: true

describe Facts::Debian::Os::Architecture do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Debian::Os::Architecture.new }

    %w[amd64 arm64 i386].each do |arch|
      it 'calls Facter::Core::Execution and returns architecture fact' do
        allow(Facter::Core::Execution).to receive(:execute).and_return(arch)

        fact.call_the_resolver
        expect(Facter::Core::Execution).to have_received(:execute).with('dpkg --print-architecture')

        expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
          contain_exactly(an_object_having_attributes(name: 'os.architecture', value: arch),
                          an_object_having_attributes(name: 'architecture', value: arch, type: :legacy))
      end
    end
  end
end
