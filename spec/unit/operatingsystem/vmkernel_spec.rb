require 'spec_helper'
require 'facter/operatingsystem/vmkernel'

describe Facter::Operatingsystem::VMkernel do
  subject { described_class.new }

  describe "Operating system fact" do
    it "should be ESXi" do
      os = subject.get_operatingsystem
      expect(os).to eq "ESXi"
    end
  end
end
