#!/usr/bin/env ruby

require 'spec_helper'

require 'facter/util/directory_loader'

describe Facter::Util::DirectoryLoader do
  include PuppetlabsSpec::Files
  include FacterSpec::ConfigHelper

  subject { Facter::Util::DirectoryLoader.new(tmpdir('directory_loader')) }

  it "should make the directory available" do
    subject.directory.should be_instance_of(String)
  end

  it "defaults to ext directory in data_dir" do 
    path = "data_dir"
    given_a_configuration_of(:data_dir => path)
    Facter::Util::DirectoryLoader.default_loader.directory.should == File.join(path, "ext")
  end 
  
  it "can be created with a given directory" do 
    Facter::Util::DirectoryLoader.loader_for("ext").directory.should == "ext"
  end 
  
  it "raises an error when the directory does not exist" do 
    missing_dir = "missing"
    File.stubs(:directory?).with(missing_dir).returns(false)
    expect { Facter::Util::DirectoryLoader.loader_for(missing_dir) }.should raise_error Facter::Util::DirectoryLoader::NoSuchDirectoryError
  end 

  it "should do nothing bad when dir doesn't exist" do
    fakepath = "/foobar/path"
    my_loader = Facter::Util::DirectoryLoader.new(fakepath)
    FileTest.exists?(my_loader.directory).should be_false
    expect { my_loader.load }.should_not raise_error
   end

  describe "when loading facts from disk" do
    it "should be able to load files from disk and set facts" do
      data = {"f1" => "one", "f2" => "two"}
      file = File.join(subject.directory, "data" + ".yaml")
      File.open(file, "w") { |f| f.print YAML.dump(data) }

      subject.load

      Facter.value("f1").should == "one"
      Facter.value("f2").should == "two"
    end

    it "should ignore files that begin with '.'" do
      # Since we know we won't load any facts, suppress the warning message 
      Facter.stubs(:warnonce)
      file = File.join(subject.directory, ".data.yaml")
      data = {"f1" => "one", "f2" => "two"}
      File.open(file, "w") { |f| f.print YAML.dump(data) }

      subject.load
      Facter.value("f1").should be_nil
    end

    %w{bak orig}.each do |ext|
      it "should ignore files with an extension of '#{ext}'" do
        file = File.join(subject.directory, "data" + ".#{ext}")
        File.open(file, "w") { |f| f.print "foo=bar" }

        subject.load
      end
    end

    it "should fail when trying to parse unknown file types" do
      file = File.join(subject.directory, "file.unknownfiletype")
      File.open(file, "w") { |f| f.print "stuff=bar" }

      expect { subject.load }.should raise_error(ArgumentError)
    end
  end
end
