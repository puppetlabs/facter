#!/usr/bin/env ruby

require File.dirname(__FILE__) + '/../spec_helper'

describe Facter do

    it "should have a version" do
        Facter.version.should =~ /^[0-9]+(\.[0-9]+)*$/
    end

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
            Facter.add("shell_testing") do
                setcode "echo yup"
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
        Facter.value(:macaddress).should_not be_include(" ")
    end

    it "should have a method for registering directories to search" do
        Facter.should respond_to(:search)
    end

    it "should have a method for returning the registered search directories" do
        Facter.should respond_to(:search_path)
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
