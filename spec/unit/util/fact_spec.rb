#! /usr/bin/env ruby

require 'spec_helper'
require 'facter/util/fact'

describe Facter::Util::Fact do
  it "should require a name" do
    lambda { Facter::Util::Fact.new }.should raise_error(ArgumentError)
  end

  it "should pass through it's name" do
    Facter::Util::Fact.new(:yayness).name.should == :yayness
  end

  it "should default to its name converted to a string as its ldapname" do
    Facter::Util::Fact.new(:yayness).ldapname.should == "yayness"
  end

  it "should allow specifying the ldap name at initialization" do
    Facter::Util::Fact.new(:yayness, :ldapname => "fooness").ldapname.should == "fooness"
  end

  it "should fail if an unknown option is provided" do
    lambda { Facter::Util::Fact.new(:yay, :foo => :bar) }.should raise_error(ArgumentError)
  end

  it "should have a method for adding resolution mechanisms" do
    Facter::Util::Fact.new(:yay).should respond_to(:add)
  end

  describe "when adding resolution mechanisms" do
    before do
      @fact = Facter::Util::Fact.new(:yay)

      @resolution = Facter::Util::Resolution.new(:yay)
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
    Facter::Util::Fact.new(:yay).should respond_to(:value)
  end

  describe "when returning a value" do
    before do
      @fact = Facter::Util::Fact.new(:yay)
    end

    it "should return nil if there are no resolutions" do
      Facter::Util::Fact.new(:yay).value.should be_nil
    end

    it "should return the first value returned by a resolution" do
      r1 = stub 'r1', :weight => 2, :value => nil, :suitable? => true
      r2 = stub 'r2', :weight => 1, :value => :yay, :suitable? => true
      r3 = stub 'r3', :weight => 0, :value => "foo", :suitable? => true
      Facter::Util::Resolution.expects(:new).times(3).returns(r1).returns(r2).returns(r3)
      @fact.add { }
      @fact.add { }
      @fact.add { }

      @fact.value.should == :yay
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
      r2 = stub 'r2', :weight => 1, :value => :yay, :suitable? => true
      Facter::Util::Resolution.expects(:new).times(2).returns(r1).returns(r2)
      @fact.add { }
      @fact.add { }

      @fact.value.should == :yay
    end

    it "should return nil if the value is the empty string" do
      r1 = stub 'r1', :suitable? => true, :value => ""
      Facter::Util::Resolution.expects(:new).returns r1
      @fact.add { }

      @fact.value.should be_nil
    end
  end

  describe '#flush' do
    subject do
      Facter::Util::Fact.new(:foo)
    end
    context 'basic facts using setcode' do
      it "flushes the cached value when invoked" do
        system = mock('some_system_call')
        system.expects(:data).twice.returns(100,200)

        subject.add { setcode { system.data } }
        5.times { subject.value.should == 100 }
        subject.flush
        subject.value.should == 200
      end
    end
    context 'facts using setcode and on_flush' do
      it 'invokes the block passed to on_flush' do
        model = { :data => "Hello World" }
        subject.add do
          on_flush { model[:data] = "FLUSHED!" }
          setcode { model[:data] }
        end
        subject.value.should == "Hello World"
        subject.flush
        subject.value.should == "FLUSHED!"
      end
    end
  end
end
