#!/usr/bin/env ruby

require 'spec_helper'

require 'facter/util/directory_loader'

describe Facter::Util::DirectoryLoader do
  include PuppetlabsSpec::Files

  before :each do
    @loader = Facter::Util::DirectoryLoader.new(tmpdir('directory_loader'))
  end

  it "should make the directory available" do
    @loader.directory.should be_instance_of(String)
  end

  it "should default to '/usr/lib/facter/ext' for the directory" do
    Facter::Util::DirectoryLoader.new.directory.should == "/usr/lib/facter/ext"
  end

  describe "when loading facts from disk" do
    it "should be able to load files from disk and set facts" do
      data = {"f1" => "one", "f2" => "two"}
      file = File.join(@loader.directory, "data" + ".yaml")
      File.open(file, "w") { |f| f.print YAML.dump(data) }

      @loader.load

      Facter.value("f1").should == "one"
      Facter.value("f2").should == "two"
    end

    it "should ignore files that begin with '.'" do
      file = File.join(@loader.directory, ".data.yaml")
      data = {"f1" => "one", "f2" => "two"}
      File.open(file, "w") { |f| f.print YAML.dump(data) }

      @loader.load
      Facter.value("f1").should be_nil
    end

    %w{bak orig}.each do |ext|
      it "should ignore files with an extension of '#{ext}'" do
        file = File.join(@loader.directory, "data" + ".#{ext}")
        File.open(file, "w") { |f| f.print "foo=bar" }

        @loader.load
      end
    end

    it "should fail when trying to parse unknown file types" do
      file = File.join(@loader.directory, "file.unknownfiletype")
      File.open(file, "w") { |f| f.print "stuff=bar" }

      lambda { @loader.load }.should raise_error(ArgumentError)
    end
  end
end
