# frozen_string_literal: true

describe Facts::Windows::Os::Release do
  subject(:fact) { Facts::Windows::Os::Release.new }

  before do
    allow(Facter::Resolvers::WinOsDescription).to receive(:resolve).with(:consumerrel).and_return(value)
    allow(Facter::Resolvers::WinOsDescription).to receive(:resolve).with(:description).and_return(value)
    allow(Facter::Resolvers::Kernel).to receive(:resolve).with(:kernelmajorversion).and_return(value)
    allow(Facter::Resolvers::Kernel).to receive(:resolve).with(:kernelversion).and_return(value)
  end

  describe '#call_the_resolver' do
    let(:value) { '2019' }

    it 'calls Facter::Resolvers::WinOsDescription with consumerrel' do
      fact.call_the_resolver
      expect(Facter::Resolvers::WinOsDescription).to have_received(:resolve).with(:consumerrel)
    end

    it 'calls Facter::Resolvers::WinOsDescription with description' do
      fact.call_the_resolver
      expect(Facter::Resolvers::WinOsDescription).to have_received(:resolve).with(:description)
    end

    it 'calls Facter::Resolvers::Kernel with kernelmajorversion' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Kernel).to have_received(:resolve).with(:kernelmajorversion)
    end

    it 'calls Facter::Resolvers::Kernel with kernelversion' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Kernel).to have_received(:resolve).with(:kernelversion)
    end

    it 'returns release fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'os.release', value: { 'full' => value, 'major' => value }),
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
