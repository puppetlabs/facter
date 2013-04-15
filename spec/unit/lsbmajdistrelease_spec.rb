require 'spec_helper'

describe 'lsbmajdistrelease fact' do
  def stub_version(ver)
    Facter.fact(:lsbdistrelease).stubs(:value).returns(ver)
    Facter.collection.internal_loader.load(:lsbminordistrelease)
  end

  it 'is 6 when lsbdistrelease is 6.4' do
    stub_version('6.4')
    Facter.fact(:lsbmajdistrelease).value.should == '6'
  end

  it 'is 6 when lsbdistrelease is 6.4.1' do
    stub_version('6.4.1')
    Facter.fact(:lsbmajdistrelease).value.should == '6'
  end

  it 'is undefined when lsbdistrelease is nil' do
    stub_version(nil)
    Facter.fact(:lsbmajdistrelease).value.should be_nil
  end
end
