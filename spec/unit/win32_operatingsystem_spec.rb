require 'spec_helper'

describe 'WMI win32_operatingsystem class based facts' do
  before :each do
    Facter.clear
    Facter.fact(:kernel).stubs(:value).returns("windows")
  end

  def load(props)
    require 'facter/util/wmi'

    os_ole = stubs 'result'
    os_ole.stubs(:properties_).returns(props)

    Facter::Util::WMI.stubs(:connect).with("winmgmts:{impersonationLevel=impersonate}!//./root/cimv2:win32_operatingsystem=@").returns(os_ole)
    Facter.collection.internal_loader.load(:win32_operatingsystem)
  end

  describe 'for properties with a value' do
    before :each do
      props = []
      3.times do |i|
        prop = stubs 'property'
        prop.stubs(:name).returns("property_#{i}")
        prop.stubs(:value).returns("value_#{i}")
        props << prop
      end

      load(props)
    end

    it 'should be created for each property' do
      3.times do |i|
        Facter.fact("wmi_win32_operatingsystem_property_#{i}".to_sym).value.should == "value_#{i}"
      end
    end
  end

  describe 'for properties with nil value' do
    before :each do
      prop = stubs 'prop'
      prop.stubs(:name).returns('property_nil')
      prop.stubs(:value).returns(nil)

      load(Array(prop))
    end

    it 'should be nil' do
      Facter.fact('wmi_win32_operatingsystem_property_nil').value.should == nil
    end
  end
end
