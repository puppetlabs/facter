#!/usr/bin/env ruby

require 'spec_helper'

require 'facter/util/directory_loader'

describe Facter::Util::DirectoryLoader do
  include PuppetlabsSpec::Files

  subject { Facter::Util::DirectoryLoader.new(tmpdir('directory_loader')) }

  it "should make the directory available" do
    subject.directory.should be_instance_of(String)
  end

  it "should default to '/usr/lib/facter/ext' for the directory" do
    Facter::Util::DirectoryLoader.new.directory.should == "/usr/lib/facter/ext"
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
