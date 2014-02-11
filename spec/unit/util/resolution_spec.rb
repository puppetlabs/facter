#! /usr/bin/env ruby

require 'spec_helper'
require 'facter/util/resolution'

describe Facter::Util::Resolution do
  include FacterSpec::ConfigHelper

  it "requires a name" do
    expect { Facter::Util::Resolution.new }.to raise_error(ArgumentError)
  end

  it "can return its name" do
    Facter::Util::Resolution.new("yay").name.should == "yay"
  end

  it "should be able to set the value" do
    resolve = Facter::Util::Resolution.new("yay")
    resolve.value = "foo"
    resolve.value.should == "foo"
  end

  it "should default to nil for code" do
    Facter::Util::Resolution.new("yay").code.should be_nil
  end

  describe "when setting the code" do
    before do
      Facter.stubs(:warnonce)
      @resolve = Facter::Util::Resolution.new("yay")
    end

    it "should set the code to any provided string" do
      @resolve.setcode "foo"
      @resolve.code.should == "foo"
    end

    it "should set the code to any provided block" do
      block = lambda { }
      @resolve.setcode(&block)
      @resolve.code.should equal(block)
    end

    it "should prefer the string over a block" do
      @resolve.setcode("foo") { }
      @resolve.code.should == "foo"
    end

    it "should fail if neither a string nor block has been provided" do
      expect { @resolve.setcode }.to raise_error(ArgumentError)
    end
  end

  describe "when returning the value" do
    before do
      @resolve = Facter::Util::Resolution.new("yay")
    end

    it "should return any value that has been provided" do
      @resolve.value = "foo"
      @resolve.value.should == "foo"
    end

    describe "and setcode has not been called" do
      it "should return nil" do
        Facter::Util::Resolution.expects(:exec).with(nil, nil).never
        @resolve.value.should be_nil
      end
    end

    describe "and the code is a string" do
      describe "on windows" do
        before do
          given_a_configuration_of(:is_windows => true)
        end

        it "should return the result of executing the code" do
          @resolve.setcode "/bin/foo"
          Facter::Util::Resolution.expects(:exec).once.with("/bin/foo").returns "yup"

          @resolve.value.should == "yup"
        end
      end

      describe "on non-windows systems" do
        before do
          given_a_configuration_of(:is_windows => false)
        end

        it "should return the result of executing the code" do
          @resolve.setcode "/bin/foo"
          Facter::Util::Resolution.expects(:exec).once.with("/bin/foo").returns "yup"

          @resolve.value.should == "yup"
        end
      end
    end

    describe "and the code is a block" do
      it "should warn but not fail if the code fails" do
        @resolve.setcode { raise "feh" }
        Facter.expects(:warn)
        @resolve.value.should be_nil
      end

      it "should return the value returned by the block" do
        @resolve.setcode { "yayness" }
        @resolve.value.should == "yayness"
      end
    end
  end

  describe "setting options" do
    subject(:resolution) { described_class.new(:foo) }

    it "can set the value" do
      resolution.set_options(:value => 'something')
      expect(resolution.value).to eq 'something'
    end

    it "can set the timeout" do
      resolution.set_options(:timeout => 314)
      expect(resolution.limit).to eq 314
    end

    it "can set the weight" do
      resolution.set_options(:weight => 27)
      expect(resolution.weight).to eq 27
    end

    it "fails on unhandled options" do
      expect do
        resolution.set_options(:foo => 'bar')
      end.to raise_error(ArgumentError, /Invalid resolution options.*foo/)
    end
  end
end
