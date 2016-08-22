#! /usr/bin/env ruby

require 'spec_helper'

describe Facter do
  it "should have a method for returning its collection" do
    Facter.should respond_to(:collection)
  end

  it "should cache the collection" do
    Facter.collection.should equal(Facter.collection)
  end

  it "should delegate the :flush method to the collection" do
    Facter.collection.expects(:flush)
    Facter.flush
  end

  it "should delegate the :fact method to the collection" do
    Facter.collection.expects(:fact)
    Facter.fact
  end

  it "should delegate the :list method to the collection" do
    Facter.collection.expects(:list)
    Facter.list
  end

  it "should load all facts when listing" do
    Facter.collection.expects(:load_all)
    Facter.collection.stubs(:list)
    Facter.list
  end

  it "should delegate the :to_hash method to the collection" do
    Facter.collection.expects(:to_hash)
    Facter.to_hash
  end

  it "should load all facts when calling :to_hash" do
    Facter.collection.expects(:load_all)
    Facter.collection.stubs(:to_hash)
    Facter.to_hash
  end

  it "should delegate the :value method to the collection" do
    Facter.collection.expects(:value)
    Facter.value
  end

  it "should delegate the :each method to the collection" do
    Facter.collection.expects(:each)
    Facter.each
  end

  it "should load all facts when calling :each" do
    Facter.collection.expects(:load_all)
    Facter.collection.stubs(:each)
    Facter.each
  end

  it "should yield to the block when using :each" do
    Facter.collection.stubs(:load_all)
    Facter.collection.stubs(:each).yields "foo"
    result = []
    Facter.each { |f| result << f }
    result.should == %w{foo}
  end

  describe "when provided code as a string" do
    it "should execute the code in the shell" do
      test_command = Facter::Util::Config.is_windows? ? 'cmd.exe /c echo yup' : 'echo yup'
      Facter.add("shell_testing") do
        setcode test_command
      end

      Facter["shell_testing"].value.should == "yup"
    end
  end

  describe "when asked for a fact as an undefined Facter class method" do
    describe "and the collection is already initialized" do
      it "should return the fact's value" do
        Facter.collection
        Facter.ipaddress.should == Facter['ipaddress'].value
      end
    end

    describe "and the collection has been just reset" do
      it "should return the fact's value" do
        Facter.reset
        Facter.ipaddress.should == Facter['ipaddress'].value
      end
    end
  end

  describe "when passed code as a block" do
    it "should execute the provided block" do
      Facter.add("block_testing") { setcode { "foo" } }

      Facter["block_testing"].value.should == "foo"
    end
  end

  describe Facter[:hostname] do
    it "should have its ldapname set to 'cn'" do
      Facter[:hostname].ldapname.should == "cn"
    end
  end

  describe Facter[:ipaddress] do
    it "should have its ldapname set to 'iphostnumber'" do
      Facter[:ipaddress].ldapname.should == "iphostnumber"
    end
  end

  # #33 Make sure we only get one mac address
  it "should only return one mac address" do
    if macaddress = Facter.value(:macaddress)
      macaddress.should_not be_include(" ")
    end
  end

  it "should have a method for registering directories to search" do
    Facter.should respond_to(:search)
  end

  it "should have a method for returning the registered search directories" do
    Facter.should respond_to(:search_path)
  end

  it "should have a method to query debugging mode" do
    Facter.should respond_to(:debugging?)
  end

  it "should have a method to query timing mode" do
    Facter.should respond_to(:timing?)
  end

  it "should have a method to show timing information" do
    Facter.should respond_to(:show_time)
  end

  it "should have a method to warn" do
    Facter.should respond_to(:warn)
  end

  describe "when warning" do
    it "should warn if debugging is enabled" do
      Facter.debugging(true)
      Kernel.stubs(:warn)
      Kernel.expects(:warn).with('foo')
      Facter.warn('foo')
    end

    it "should not warn if debugging is enabled but nil is passed" do
      Facter.debugging(true)
      Kernel.stubs(:warn)
      Kernel.expects(:warn).never
      Facter.warn(nil)
    end

    it "should not warn if debugging is enabled but an empyt string is passed" do
      Facter.debugging(true)
      Kernel.stubs(:warn)
      Kernel.expects(:warn).never
      Facter.warn('')
    end

    it "should not warn if debugging is disabled" do
      Facter.debugging(false)
      Kernel.stubs(:warn)
      Kernel.expects(:warn).never
      Facter.warn('foo')
    end

    it "should warn for any given element for an array if debugging is enabled" do
      Facter.debugging(true)
      Kernel.stubs(:warn)
      Kernel.expects(:warn).with('foo')
      Kernel.expects(:warn).with('bar')
      Facter.warn( ['foo','bar'])
    end
  end

  describe "when warning once" do
    it "should only warn once" do
      Kernel.stubs(:warnonce)
      Kernel.expects(:warn).with('foo').once
      Facter.warnonce('foo')
      Facter.warnonce('foo')
    end

    it "should not warnonce if nil is passed" do
      Kernel.stubs(:warn)
      Kernel.expects(:warnonce).never
      Facter.warnonce(nil)
    end

    it "should not warnonce if an empty string is passed" do
      Kernel.stubs(:warn)
      Kernel.expects(:warnonce).never
      Facter.warnonce('')
    end
  end

  describe "when using bitcheck method" do
    it "should return true if set to 1" do
      Facter.bitcheck(1).should == 1
    end
    it "should return true if set to true" do
      Facter.bitcheck(1).should == 1
    end
    it "should return true if any string except off" do
      Facter.bitcheck('aaaaa').should == 1
    end
    it "should return false if set to 0" do
      Facter.bitcheck(0).should be_zero
    end
    it "should return false if set to false" do
      Facter.bitcheck(false).should be_zero
    end
    it "should return false if set to off" do
      Facter.bitcheck('off').should be_zero
    end
  end

  describe "when setting debugging mode" do
    it "should have debugging enabled using 1" do
      Facter.debugging(1)
      Facter.should be_debugging
    end
    it "should have debugging enabled using true" do
      Facter.debugging(true)
      Facter.should be_debugging
    end
    it "should have debugging enabled using any string except off" do
      Facter.debugging('aaaaa')
      Facter.should be_debugging
    end
    it "should have debugging disabled using 0" do
      Facter.debugging(0)
      Facter.should_not be_debugging
    end
    it "should have debugging disabled using false" do
      Facter.debugging(false)
      Facter.should_not be_debugging
    end
    it "should have debugging disabled using the string 'off'" do
      Facter.debugging('off')
      Facter.should_not be_debugging
    end
  end

  describe "when setting timing mode" do
    it "should have timing enabled using 1" do
      Facter.timing(1)
      Facter.should be_timing
    end
    it "should have timing enabled using true" do
      Facter.timing(true)
      Facter.should be_timing
    end
    it "should have timing disabled using 0" do
      Facter.timing(0)
      Facter.should_not be_timing
    end
    it "should have timing disabled using false" do
      Facter.timing(false)
      Facter.should_not be_timing
    end
  end

  describe "when setting tracing mode" do
    it "should have tracing enabled using 1" do
      Facter.tracing(1)
      Facter.should be_tracing
    end
    it "should have tracing enabled using true" do
      Facter.tracing(true)
      Facter.should be_tracing
    end
    it "should have tracing disabled using 0" do
      Facter.tracing(0)
      Facter.should_not be_tracing
    end
    it "should have tracing disabled using false" do
      Facter.tracing(false)
      Facter.should_not be_tracing
    end
  end

  describe "when registering directories to search" do
    after { Facter.instance_variable_set("@search_path", []) }

    it "should allow registration of a directory" do
      Facter.search "/my/dir"
    end

    it "should allow registration of multiple directories" do
      Facter.search "/my/dir", "/other/dir"
    end

    it "should return all registered directories when asked" do
      Facter.search "/my/dir", "/other/dir"
      Facter.search_path.should == %w{/my/dir /other/dir}
    end
  end
end
