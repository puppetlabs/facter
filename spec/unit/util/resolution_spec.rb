#! /usr/bin/env ruby

require 'spec_helper'
require 'facter/util/resolution'

describe Facter::Util::Resolution do
  include FacterSpec::ConfigHelper

  subject(:resolution) { described_class.new(:foo, stub_fact) }

  let(:stub_fact) { stub('fact', :name => :stubfact) }

  it "requires a name" do
    expect { Facter::Util::Resolution.new }.to raise_error(ArgumentError)
  end

  it "requires a fact" do
    expect { Facter::Util::Resolution.new('yay') }.to raise_error(ArgumentError)
  end

  it "can return its name" do
    expect(resolution.name).to eq :foo
  end

  it "can explicitly set a value" do
    resolution.value = "foo"
    expect(resolution.value).to eq "foo"
  end

  it "defaults to nil for code" do
    expect(resolution.code).to be_nil
  end

  describe "when setting the code" do
    before do
      Facter.stubs(:warnonce)
    end

    it "creates a block when given a command" do
      resolution.setcode "foo"
      expect(resolution.code).to be_a_kind_of Proc
    end

    it "stores the provided block when given a block" do
      block = lambda { }
      resolution.setcode(&block)
      resolution.code.should equal(block)
    end


    it "prefers a command over a block" do
      block = lambda { }
      resolution.setcode("foo", &block)
      expect(resolution.code).to_not eq block
    end

    it "fails if neither a string nor block has been provided" do
      expect { resolution.setcode }.to raise_error(ArgumentError)
    end
  end

  describe "when returning the value" do
    it "returns any value that has been provided" do
      resolution.value = "foo"
      expect(resolution.value).to eq "foo"
    end

    describe "and setcode has not been called" do
      it "returns nil" do
        expect(resolution.value).to be_nil
      end
    end

    describe "and the code is a string" do
      it "returns the result of executing the code" do
        resolution.setcode "/bin/foo"
        Facter::Core::Execution.expects(:execute).once.with("/bin/foo", anything).returns "yup"

        expect(resolution.value).to eq "yup"
      end
    end

    describe "and the code is a block" do
      it "returns the value returned by the block" do
        resolution.setcode { "yayness" }
        expect(resolution.value).to eq "yayness"
      end
    end
  end

  describe "setting options" do
    it "can set the value" do
      resolution.set_options(:value => 'something')
      expect(resolution.value).to eq 'something'
    end

    it "can set the timeout" do
      resolution.set_options(:timeout => 314)
      expect(resolution.limit).to eq 314
    end

    it "can set the weight" do
      resolution.set_options(:weight => 27)
      expect(resolution.weight).to eq 27
    end

    it "fails on unhandled options" do
      expect do
        resolution.set_options(:foo => 'bar')
      end.to raise_error(ArgumentError, /Invalid resolution options.*foo/)
    end
  end

  describe "evaluating" do
    it "evaluates the block in the context of the given resolution" do
      subject.expects(:has_weight).with(5)
      subject.evaluate { has_weight(5) }
    end

    it "raises a warning if the resolution is evaluated twice" do
      Facter.expects(:warn).with do |msg|
        expect(msg).to match /Already evaluated foo at.*reevaluating anyways/
      end

      subject.evaluate { }
      subject.evaluate { }
    end
  end
end
