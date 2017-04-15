require "spec_helper"

class Puppet
  @@settings = {}

  def self.[]
    @@settings
  end

  def self.[] key, val
    @@settings[key] = val
  end
end

describe "puppet parser facts" do
  it "when puppet parser is future returns future" do
    Puppet.stubs(:[]).with(:parser).returns("future")
    Facter.fact(:puppetparser).value.should == "future"
  end

  it "when puppet parser is current returns current" do
    Puppet.stubs(:[]).with(:parser).returns("current")
    Facter.fact(:puppetparser).value.should == "current"
  end

  it "when puppet cannot be required returns nil" do
    Puppet.stubs(:[]).with(:parser).raises(LoadError)
    Facter.fact(:puppetparser).value.should == nil
  end
end
