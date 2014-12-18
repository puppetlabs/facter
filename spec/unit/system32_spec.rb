require 'spec_helper'

describe "system32 fact" do
  let(:systemroot) { 'D:\Windows' }
  let(:sysnative)  { "#{systemroot}\\sysnative" }
  let(:system32)   { "#{systemroot}\\system32" }

  before(:each) do
    Facter.fact(:kernel).stubs(:value).returns("windows")
    ENV['SYSTEMROOT'] = systemroot
  end

  describe "when running in 32-bit ruby" do
    it "resolves to sysnative" do
      File.expects(:exist?).with(sysnative).returns(true)

      expect(Facter.fact(:system32).value).to eq(sysnative)
    end
  end

  describe "when running in 64-bit ruby" do
    it "resolves to system32" do
      File.expects(:exist?).with(sysnative).returns(false)

      expect(Facter.fact(:system32).value).to eq(system32)
    end
  end
end
