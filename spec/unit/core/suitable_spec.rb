require 'spec_helper'
require 'facter/core/suitable'

describe Facter::Core::Suitable do

  class SuitableClass
    def initialize
      @confines = []
    end
    attr_reader :confines
    include Facter::Core::Suitable
  end

  subject { SuitableClass.new }

  it "can add confines" do
    subject.confine :kernel => 'Linux'
  end

  it "creates a Facter::Util::Confine object for the confine call" do
    subject.confine :kernel => 'Linux'
    conf = subject.confines.first
    expect(conf).to be_a_kind_of Facter::Util::Confine
    expect(conf.fact).to eq :kernel
    expect(conf.values).to eq ['Linux']
  end

  describe "determining weight" do
    it "is zero if no confines are set" do
      expect(subject.weight).to eq 0
    end

    it "defaults to the number of confines" do
      subject.confine :kernel => 'Linux'
      expect(subject.weight).to eq 1
    end

    it "can be explicitly set" do
      subject.has_weight 10
      expect(subject.weight).to eq 10
    end

    it "prefers an explicit weight over the number of confines" do
      subject.confine :kernel => 'Linux'
      subject.has_weight 11
      expect(subject.weight).to eq 11
    end
  end

  describe "determining suitability" do
    it "is true if all confines for the object evaluate to true" do
      subject.confine :kernel => 'Linux'
      subject.confine :operatingsystem => 'Redhat'

      subject.confines.each { |confine| confine.stubs(:true?).returns true }

      expect(subject).to be_suitable
    end

    it "is false if any confines for the object evaluate to false" do
      subject.confine :kernel => 'Linux'
      subject.confine :operatingsystem => 'Redhat'

      subject.confines.first.stubs(:true?).returns true
      subject.confines.first.stubs(:true?).returns false

      expect(subject).to_not be_suitable
    end
  end
end
