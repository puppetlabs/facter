# frozen_string_literal: true

describe Facter::Windows::OsRelease do
  subject(:fact) { Facter::Windows::OsRelease.new }

  before do
    allow(Facter::Resolvers::WinOsDescription).to receive(:resolve).with(:consumerrel).and_return(value)
    allow(Facter::Resolvers::WinOsDescription).to receive(:resolve).with(:description).and_return(value)
    allow(Facter::Resolvers::Kernel).to receive(:resolve).with(:kernelmajorversion).and_return(value)
    allow(Facter::Resolvers::Kernel).to receive(:resolve).with(:kernelversion).and_return(value)
  end

  describe '#call_the_resolver' do
    let(:value) { '2019' }

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

  describe '#call_the_resolver when resolvers return nil' do
    let(:value) { nil }

    it 'returns release fact as nil' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'os.release', value: value),
                        an_object_having_attributes(name: 'operatingsystemmajrelease', value: value, type: :legacy),
                        an_object_having_attributes(name: 'operatingsystemrelease', value: value, type: :legacy))
    end
  end
end
