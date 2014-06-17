require 'spec_helper'
require 'facter'
require 'facter/util/partitions'

describe 'Facter::Util::Partitions' do
  describe 'on unsupported OSs' do
    before :each do
      Facter.fact(:kernel).stubs(:value).returns("SunOS")
    end
    
    it 'list should return empty array' do
      Facter::Util::Partitions.list.should == []
    end

    it 'available? should return false' do
      Facter::Util::Partitions.available?.should == false
    end
  end
end
