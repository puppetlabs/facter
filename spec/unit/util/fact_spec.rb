#! /usr/bin/env ruby

require 'spec_helper'
require 'facter/util/fact'

describe Facter::Util::Fact do

  subject(:fact) { Facter::Util::Fact.new("yay") }

  let(:resolution) { Facter::Util::Resolution.new("yay", fact) }

  it "requires a name" do
    expect { Facter::Util::Fact.new }.to raise_error(ArgumentError)
  end

  it "downcases the name and converts it to a symbol" do
    Facter::Util::Fact.new("YayNess").name.should == :yayness
  end

  it "issues a deprecation warning for use of ldapname" do
    Facter.expects(:warnonce).with("ldapname is deprecated and will be removed in a future version")
    Facter::Util::Fact.new("YayNess", :ldapname => "fooness")
  end

  describe "when adding resolution mechanisms" do
    it "instance_evals the passed block on the new resolution" do
      fact.add {
        setcode { "foo" }
      }
      expect(fact.value).to eq "foo"
    end
  end

  describe "looking up resolutions by name" do
    subject(:fact) { described_class.new('yay') }

    it "returns nil if no such resolution exists" do
      expect(fact.resolution('nope')).to be_nil
    end

    it "never returns anonymous resolutions" do
      fact.add() { setcode { 'anonymous' } }

      expect(fact.resolution(nil)).to be_nil
    end
  end

  describe "adding resolution mechanisms by name" do

    it "creates a new resolution if no such resolution exists" do
      res = stub 'resolution', :name => 'named'
      Facter::Util::Resolution.expects(:new).once.with('named', fact).returns(res)

      fact.define_resolution('named')

      expect(fact.resolution('named')).to eq res
    end

    it "returns existing resolutions by name" do
      res = stub 'resolution', :name => 'named'
      Facter::Util::Resolution.expects(:new).once.with('named', fact).returns(res)

      fact.define_resolution('named')
      fact.define_resolution('named')

      expect(fact.resolution('named')).to eq res
    end
  end

  describe "when returning a value" do
    before do
      fact = Facter::Util::Fact.new("yay")
    end

    it "returns nil if there are no resolutions" do
      Facter::Util::Fact.new("yay").value.should be_nil
    end

    it "prefers the highest weight resolution" do
      fact.add { has_weight 1; setcode { "1" } }
      fact.add { has_weight 2; setcode { "2" } }
      fact.add { has_weight 0; setcode { "0" } }
      expect(fact.value).to eq "2"
    end

    it "returns the first value returned by a resolution" do
      fact.add { has_weight 1; setcode { "1" } }
      fact.add { has_weight 2; setcode { nil } }
      fact.add { has_weight 0; setcode { "0" } }
      expect(fact.value).to eq "1"
    end

    it "skips unsuitable resolutions" do
      fact.add { has_weight 1; setcode { "1" } }
      fact.add do
        def suitable?; false; end
        has_weight 2
        setcode { 2 }
      end

      expect(fact.value).to eq "1"
    end

    it "returns nil if the value is the empty string" do
      fact.add { setcode { "" } }

      expect(fact.value).to be_nil
    end
  end

  describe '#flush' do
    subject do
      Facter::Util::Fact.new(:foo)
    end
    context 'basic facts using setcode' do
      it "flushes the cached value when invoked" do
        system = mock('some_system_call')
        system.expects(:data).twice.returns(100,200)

        subject.add { setcode { system.data } }
        5.times { subject.value.should == 100 }
        subject.flush
        subject.value.should == 200
      end
    end
    context 'facts using setcode and on_flush' do
      it 'invokes the block passed to on_flush' do
        model = { :data => "Hello World" }
        subject.add do
          on_flush { model[:data] = "FLUSHED!" }
          setcode { model[:data] }
        end
        subject.value.should == "Hello World"
        subject.flush
        subject.value.should == "FLUSHED!"
      end
    end
  end
end
