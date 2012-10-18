#! /usr/bin/env ruby
require 'spec_helper'
require 'facter/operatingsystem'
require 'facter/util/registry'

describe Facter::Util::Registry do
  describe "hklm_read", :if => Facter::Util::Config.is_windows? do
    before(:all) do
      require 'win32/registry'
    end
    describe "valid params" do
      [ {:key => "valid_key", :value => "valid_value",  :expected => "valid"},
        {:key => "valid_key", :value => "",             :expected => "valid"},
        {:key => "valid_key", :value => nil,            :expected => "invalid"},
        {:key => "",          :value => "valid_value",  :expected => "valid"},
        {:key => "",          :value => "",             :expected => "valid"},
        {:key => "",          :value => nil,            :expected => "invalid"},
        {:key => nil,         :value => "valid_value",  :expected => "invalid"},
        {:key => nil,         :value => "",             :expected => "invalid"},
        {:key => nil,         :value => nil,            :expected => "invalid"}
      ].each do |scenario|
        describe "with key #{scenario[:key] || "nil"} and value #{scenario[:value] || "nil"}" do
          let :fake_registry_key do
            fake = {}
            fake[scenario[:value]] = scenario[:expected]
            fake
          end
          it "should return #{scenario[:expected]} value" do
            Win32::Registry::HKEY_LOCAL_MACHINE.stubs(:open).with(scenario[:key]).returns(fake_registry_key)
            fake_registry_key.stubs(:close)

            Facter::Util::Registry.hklm_read(scenario[:key], scenario[:value]).should == scenario[:expected]
          end
        end
      end
    end

    describe "invalid params" do
      [ {:key => "valid_key",   :value => "invalid_value"},
        {:key => "valid_key",   :value => ""},
        {:key => "valid_key",   :value => nil},
      ].each do |scenario|
        describe "with valid key and value #{scenario[:value] || "nil"}" do
          let :fake_registry_key do
            {}
          end
          it "should raise an error" do
            Win32::Registry::HKEY_LOCAL_MACHINE.stubs(:open).with(scenario[:key]).returns(fake_registry_key)
            fake_registry_key.stubs(:close)

            Facter::Util::Registry.hklm_read(scenario[:key], scenario[:value]).should raise_error
          end
        end
      end
      [ {:key => "invalid_key", :value => "valid_value"},
        {:key => "invalid_key", :value => ""},
        {:key => "invalid_key", :value => nil},
        {:key => "",            :value => "valid_value"},
        {:key => "",            :value => ""},
        {:key => "",            :value => nil},
        {:key => nil,           :value => "valid_value"},
        {:key => nil,           :value => ""},
        {:key => nil,           :value => nil}
      ].each do |scenario|
        describe "with invalid key #{scenario[:key] || "nil"} and value #{scenario[:value] || "nil"}" do
          it "should raise an error" do
            Win32::Registry::HKEY_LOCAL_MACHINE.stubs(:open).with(scenario[:key]).raises(Win32::Registry::Error, 2)
            expect do
              Facter::Util::Registry.hklm_read(scenario[:key], scenario[:value])
            end.to raise_error Win32::Registry::Error
          end
        end
      end
    end
  end
end
