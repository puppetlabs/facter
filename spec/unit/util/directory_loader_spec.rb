#!/usr/bin/env ruby

require 'spec_helper'

require 'facter/util/directory_loader'

describe Facter::Util::DirectoryLoader do
  include PuppetlabsSpec::Files
  include FacterSpec::ConfigHelper

  subject { Facter::Util::DirectoryLoader.new(tmpdir('directory_loader')) }
  let(:collection) { Facter::Util::Collection.new(mock("internal loader"), subject) }

  it "should make the directory available" do
    subject.directory.should be_instance_of(String)
  end

  it "can be created with a given directory" do
    Facter::Util::DirectoryLoader.loader_for("ext").directory.should == "ext"
  end

  it "raises an error when the directory does not exist" do
    missing_dir = "missing"
    File.stubs(:directory?).with(missing_dir).returns(false)
    expect { Facter::Util::DirectoryLoader.loader_for(missing_dir) }.to raise_error Facter::Util::DirectoryLoader::NoSuchDirectoryError
  end

  it "should do nothing bad when dir doesn't exist" do
    fakepath = "/foobar/path"
    my_loader = Facter::Util::DirectoryLoader.new(fakepath)
    FileTest.exists?(my_loader.directory).should be_false
    expect { my_loader.load(collection) }.to_not raise_error
   end

  describe "when loading facts from disk" do
    it "should be able to load files from disk and set facts" do
      data = {"f1" => "one", "f2" => "two"}
      write_to_file("data.yaml", YAML.dump(data))

      subject.load(collection)

      collection.value("f1").should == "one"
      collection.value("f2").should == "two"
    end

    it "should ignore files that begin with '.'" do
      not_to_be_used_collection = mock("collection should not be used")
      not_to_be_used_collection.expects(:add).never

      data = {"f1" => "one", "f2" => "two"}
      write_to_file(".data.yaml", YAML.dump(data))

      subject.load(not_to_be_used_collection)
    end

    %w{bak orig}.each do |ext|
      it "should ignore files with an extension of '#{ext}'" do
        Facter.expects(:warn).with(regexp_matches(/#{ext}/))
        write_to_file("data" + ".#{ext}", "foo=bar")

        subject.load(collection)
      end
    end

    it "should warn when trying to parse unknown file types" do
      write_to_file("file.unknownfiletype", "stuff=bar")

      Facter.expects(:warn).with(regexp_matches(/file.unknownfiletype/))

      subject.load(collection)
    end

    it "external facts should almost always precedence over all other facts" do
      collection.add("f1", :value => "lower_weight_fact") { has_weight(Facter::Util::DirectoryLoader::EXTERNAL_FACT_WEIGHT - 1) }
      data = {"f1" => "external_fact"}
      write_to_file("data.yaml", YAML.dump(data))

      subject.load(collection)

      collection.value("f1").should == "external_fact"
    end

    describe "given a custom weight" do
      subject { Facter::Util::DirectoryLoader.new(tmpdir('directory_loader'), 10) }

      it "should set that weight for loaded external facts" do
        collection.add("f1", :value => "higher_weight_fact") { has_weight(11) }
        data = {"f1" => "external_fact"}
        write_to_file("data.yaml", YAML.dump(data))

        subject.load(collection)

        collection.value("f1").should == "higher_weight_fact"
      end
    end
  end

  def write_to_file(file_name, to_write)
    file = File.join(subject.directory, file_name)
    File.open(file, "w") { |f| f.print to_write}
  end
end
