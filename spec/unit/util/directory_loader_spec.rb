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
      write_to_file("data.yaml", YAML.dump(data))

      subject.load

      Facter.value("f1").should == "one"
      Facter.value("f2").should == "two"
    end

    it "should ignore files that begin with '.'" do
      # Since we know we won't load any facts, suppress the warning message 
      Facter.stubs(:warnonce)
    
      data = {"f1" => "one", "f2" => "two"}
      write_to_file(".data.yaml", YAML.dump(data))

      subject.load
      Facter.value("f1").should be_nil
    end

    %w{bak orig}.each do |ext|
      it "should ignore files with an extension of '#{ext}'" do
        write_to_file("data" + ".#{ext}", "foo=bar")

        subject.load
      end
    end

    it "should warn when trying to parse unknown file types" do
      write_to_file("file.unknownfiletype", "stuff=bar") 
      
      Facter.expects(:warn).with(regexp_matches(/file.unknownfiletype/))

      subject.load
    end
    
    it "external facts should almost always precedence over all other facts" do 
      Facter.add("f1", :value => "lower_weight_fact") { has_weight(Facter::Util::DirectoryLoader::EXTERNAL_FACT_WEIGHT - 1) }
      data = {"f1" => "external_fact"}
      write_to_file("data.yaml", YAML.dump(data)) 

      subject.load

      Facter.value("f1").should == "external_fact"
    end 
  end
  
  def write_to_file(file_name, to_write)
    file = File.join(subject.directory, file_name)
    File.open(file, "w") { |f| f.print to_write} 
  end 
end
