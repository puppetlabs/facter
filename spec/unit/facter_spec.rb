#! /usr/bin/env ruby

require 'spec_helper'

describe Facter do
  it "caches the collection" do
    Facter.collection.should equal(Facter.collection)
  end

  describe "methods on the collection" do
    it "delegates the :flush method to the collection" do
      Facter.collection.expects(:flush)
      Facter.flush
    end

    it "delegates the :fact method to the collection" do
      Facter.collection.expects(:fact).with("afact")
      Facter.fact("afact")
    end

    it "delegates the :list method to the collection" do
      Facter.collection.expects(:list)
      Facter.list
    end

    it "loads all facts when listing" do
      Facter.collection.expects(:load_all)
      Facter.list
    end

    it "delegates the :to_hash method to the collection" do
      Facter.collection.expects(:to_hash)
      Facter.to_hash
    end

    it "loads all facts when calling :to_hash" do
      Facter.collection.expects(:load_all)
      Facter.collection.stubs(:to_hash)
      Facter.to_hash
    end

    it "delegates the :value method to the collection" do
      Facter.collection.expects(:value).with("myvaluefact")
      Facter.value("myvaluefact")
    end

    it "delegates the :each method to the collection" do
      Facter.collection.expects(:each)
      Facter.each
    end

    it "delegates the :add method to the collection" do
      Facter.collection.expects(:add).with("factname", {})
      Facter.add("factname")
    end

    it "delegates the :define_fact method to the collection" do
      Facter.collection.expects(:define_fact).with("factname", {})
      Facter.define_fact("factname")
    end

    it "loads all facts when calling :each" do
      Facter.collection.expects(:load_all)
      Facter.collection.stubs(:each)
      Facter.each
    end
  end

  it "yields to the block when using :each" do
    Facter.collection.stubs(:load_all)
    Facter.collection.stubs(:each).yields "foo"
    result = []
    Facter.each { |f| result << f }
    result.should == %w{foo}
  end

  describe "when registering directories to search" do
    after { Facter.reset_search_path! }

    it "allows registration of a directory" do
      Facter.search "/my/dir"
    end

    it "allows registration of multiple directories" do
      Facter.search "/my/dir", "/other/dir"
    end

    it "returns all registered directories when asked" do
      Facter.search "/my/dir", "/other/dir"
      Facter.search_path.should == %w{/my/dir /other/dir}
    end
  end

  describe "when registering directories to search for external facts" do
    it "allows registration of a directory" do
      Facter.search_external ["/my/dir"]
    end

    it "allows registration of multiple directories" do
      Facter.search_external ["/my/dir", "/other/dir"]
    end

    it "returns all registered directories when asked" do
      Facter.search_external ["/my/dir", "/other/dir"]
      Facter.search_external_path.should include("/my/dir", "/other/dir")
    end
  end
end
