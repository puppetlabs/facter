#!/usr/bin/env rspec

require 'spec_helper'
require 'facter/util/fact'

describe Facter::Util::Fact do
  it "should require a name" do
    lambda { Facter::Util::Fact.new }.should raise_error(ArgumentError)
  end

  it "should always downcase the name and convert it to a symbol" do
    Facter::Util::Fact.new("YayNess").name.should == :yayness
  end

  it "should default to its name converted to a string as its ldapname" do
    Facter::Util::Fact.new("YayNess").ldapname.should == "yayness"
  end

  it "should allow specifying the ldap name at initialization" do
    Facter::Util::Fact.new("YayNess", :ldapname => "fooness").ldapname.should == "fooness"
  end

  it "should fail if an unknown option is provided" do
    lambda { Facter::Util::Fact.new('yay', :foo => :bar) }.should raise_error(ArgumentError)
  end

  it "should have a method for adding resolution mechanisms" do
    Facter::Util::Fact.new("yay").should respond_to(:add)
  end

  describe "when adding resolution mechanisms" do
    before do
      @fact = Facter::Util::Fact.new("yay")

      @resolution = Facter::Util::Resolution.new("yay")
    end

    it "should be to create a new resolution instance with a block" do
      Facter::Util::Resolution.expects(:new).returns @resolution

      @fact.add { }
    end
    it "should instance_eval the passed block on the new resolution" do
      @fact.add {
        setcode { "foo" }
      }
      @fact.value.should == "foo"
    end

    it "should re-sort the resolutions by weight, so the most restricted resolutions are first" do
      @fact.add { self.value = "1"; self.weight = 1 }
      @fact.add { self.value = "2"; self.weight = 2 }
      @fact.add { self.value = "0"; self.weight = 0 }
      @fact.value.should == "2"
    end
  end

  it "should be able to return a value" do
    Facter::Util::Fact.new("yay").should respond_to(:value)
  end

  describe "when validating fact resolutions" do
    before do
      @fact = Facter::Util::Fact.new("yay")
    end

    [
      true,
      false,
      "string",
      1.0,
      1000,
      true,
      false,
      ["yay"],
      {"test" => "fact"},
      {"test" => ["fact","value","var"]},
      {"test" => { "test2" => { "test3" => { "test4" => "value" }}}},
      {"foo" => [], "bar" => [{}, {}, []]},
      "",
      [],
      {},
    ].each do |valid|
      it "should return the valid value \"#{valid.inspect}\"" do
        r1 = stub 'r1', :suitable? => true, :value => valid
        Facter::Util::Resolution.expects(:new).returns r1
        @fact.add { }

        @fact.value.should == valid
      end
    end

    [
      nil,
      :yay,
      {:foo => nil},
      {:foo => ""},
      {:foo => [], :bar => [{}, {}, []]},
      Object.new,
      {"test" => Object.new},
      [nil, nil, "", :yay],
      {:foo => "bar"},
      {:foo => [], :yay => "hi"},
      {:foo => [false], :yay => "hi"},
      {"test" => ["fact", { "deep" => Object.new }, "value"] },
      {"" => "value"},
      {"" => {"" => "value"}},
      [Object.new],
      [{Object.new => "test"}],
    ].each do |invalid|
      it "should return nil for the invalid value \"#{invalid.inspect}\"" do
        # Stop warning messages being sent to the console
        Kernel.stubs(:warn)

        r1 = stub 'r1', :suitable? => true, :value => invalid
        Facter::Util::Resolution.expects(:new).returns r1
        @fact.add { }

        @fact.value.should be_nil
      end
    end
  end

  describe "when returning a value" do
    before do
      @fact = Facter::Util::Fact.new("yay")
    end

    it "should return nil if there are no resolutions" do
      Facter::Util::Fact.new("yay").value.should be_nil
    end

    it "should return the first value returned by a resolution" do
      r1 = stub 'r1', :weight => 2, :value => nil, :suitable? => true
      r2 = stub 'r2', :weight => 1, :value => "yay", :suitable? => true
      r3 = stub 'r3', :weight => 0, :value => "foo", :suitable? => true
      Facter::Util::Resolution.expects(:new).times(3).returns(r1).returns(r2).returns(r3)
      @fact.add { }
      @fact.add { }
      @fact.add { }

      @fact.value.should == "yay"
    end

    it "should short-cut returning the value once one is found" do
      r1 = stub 'r1', :weight => 2, :value => "foo", :suitable? => true
      r2 = stub 'r2', :weight => 1, :suitable? => true # would fail if 'value' were asked for
      Facter::Util::Resolution.expects(:new).times(2).returns(r1).returns(r2)
      @fact.add { }
      @fact.add { }

      @fact.value
    end

    it "should skip unsuitable resolutions" do
      r1 = stub 'r1', :weight => 2, :suitable? => false # would fail if 'value' were asked for'
      r2 = stub 'r2', :weight => 1, :value => "yay", :suitable? => true
      Facter::Util::Resolution.expects(:new).times(2).returns(r1).returns(r2)
      @fact.add { }
      @fact.add { }

      @fact.value.should == "yay"
    end
  end

  it "should have a method for flushing the cached fact" do
    Facter::Util::Fact.new(:foo).should respond_to(:flush)
  end
end
