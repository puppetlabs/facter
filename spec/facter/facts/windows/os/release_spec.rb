# frozen_string_literal: true

describe 'Windows OsRelease' do
  context '#call_the_resolver' do
    let(:value) { '2019' }
    subject(:fact) { Facter::Windows::OsRelease.new }

    before do
      allow(Facter::Resolvers::WinOsDescription).to receive(:resolve).with(:consumerrel).and_return('consumerrel')
      allow(Facter::Resolvers::WinOsDescription).to receive(:resolve).with(:description).and_return('description')
      allow(Facter::Resolvers::Kernel).to receive(:resolve).with(:kernelmajorversion).and_return(value)
      allow(Facter::Resolvers::Kernel).to receive(:resolve).with(:kernelversion).and_return('kernel_version')
    end

    it 'calls Facter::Resolvers::WinOsDescription and Facter::Resolvers::Kernel resolvers' do
      expect(Facter::Resolvers::WinOsDescription).to receive(:resolve).with(:consumerrel)
      expect(Facter::Resolvers::WinOsDescription).to receive(:resolve).with(:description)
      expect(Facter::Resolvers::Kernel).to receive(:resolve).with(:kernelmajorversion)
      expect(Facter::Resolvers::Kernel).to receive(:resolve).with(:kernelversion)
      fact.call_the_resolver
    end

    it 'returns release fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'os.release', value: { full: value, major: value }),
                        an_object_having_attributes(name: 'operatingsystemmajrelease', value: value, type: :legacy),
                        an_object_having_attributes(name: 'operatingsystemrelease', value: value, type: :legacy))
    end
  end
end
