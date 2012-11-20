#! /usr/bin/env ruby

require 'facter/util/file_read'
require 'spec_helper'

describe Facter::Util::FileRead do
  let(:issue) { "Ubuntu 10.04.4 LTS \\n \\l\n\n" }

  it "reads a file" do
    File.expects(:read).with("/etc/issue").returns(issue)
    Facter::Util::FileRead.read("/etc/issue").should == issue
  end

  it "returns nil if the file cannot be accessed" do
    File.stubs(:read).with("/etc/issue").raises(Errno::EACCES.new("/etc/issue"))
    Facter::Util::FileRead.read("/etc/issue").should be_nil
  end

  it "returns nil if the file does not exist" do
    File.stubs(:read).with("/etc/issue").raises(Errno::ENOENT.new("/etc/issue"))
    Facter::Util::FileRead.read("/etc/issue").should be_nil
  end

  it "logs a message when handing exceptions" do
    File.stubs(:read).with("/etc/issue").raises(Errno::EACCES.new("/etc/issue"))
    Facter.expects(:debug).with("Could not read /etc/issue: Permission denied - /etc/issue")
    Facter::Util::FileRead.read("/etc/issue")
  end
end
