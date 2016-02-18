#! /usr/bin/env ruby

require 'spec_helper'

describe "Facter::Util::Windows::User", :if => Facter::Util::Config.is_windows? do
  describe "2003 without UAC" do
    before :each do
      Facter::Util::Windows::Process.stubs(:windows_major_version).returns(5)
    end

    it "should be an admin if user's token contains the Administrators SID" do
      Facter::Util::Windows::User.expects(:check_token_membership).returns(true)
      Facter::Util::Windows::Process.expects(:elevated_security?).never

      expect(Facter::Util::Windows::User).to be_admin
    end

    it "should not be an admin if user's token doesn't contain the Administrators SID" do
      Facter::Util::Windows::User.expects(:check_token_membership).returns(false)
      Facter::Util::Windows::Process.expects(:elevated_security?).never

      expect(Facter::Util::Windows::User).not_to be_admin
    end

    it "should raise an exception if we can't check token membership" do
      Facter::Util::Windows::User.expects(:check_token_membership).raises(Facter::Util::Windows::Error, "Access denied.")
      Facter::Util::Windows::Process.expects(:elevated_security?).never

      expect { Facter::Util::Windows::User.admin? }.to raise_error(Facter::Util::Windows::Error, /Access denied./)
    end
  end

  describe "2008 with UAC" do
    before :each do
      Facter::Util::Windows::Process.stubs(:windows_major_version).returns(6)
    end

    it "should be an admin if user is running with elevated privileges" do
      Facter::Util::Windows::Process.stubs(:elevated_security?).returns(true)
      Facter::Util::Windows::User.expects(:check_token_membership).never

      expect(Facter::Util::Windows::User).to be_admin
    end

    it "should not be an admin if user is not running with elevated privileges" do
      Facter::Util::Windows::Process.stubs(:elevated_security?).returns(false)
      Facter::Util::Windows::User.expects(:check_token_membership).never

      expect(Facter::Util::Windows::User).not_to be_admin
    end

    it "should raise an exception if the process fails to open the process token" do
      Facter::Util::Windows::Process.stubs(:elevated_security?).raises(Facter::Util::Windows::Error, "Access denied.")
      Facter::Util::Windows::User.expects(:check_token_membership).never

      expect { Facter::Util::Windows::User.admin? }.to raise_error(Facter::Util::Windows::Error, /Access denied./)
    end
  end
end
