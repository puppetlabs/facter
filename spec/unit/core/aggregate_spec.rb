require 'spec_helper'
require 'facter/core/aggregate'

describe Facter::Core::Aggregate do

  let(:fact) { stub('stub_fact', :name => 'stub_fact') }

  subject { obj = described_class.new('aggregated', fact) }

  it "can be resolved" do
    expect(subject).to be_a_kind_of Facter::Core::Resolvable
  end

  it "can be confined and weighted" do
    expect(subject).to be_a_kind_of Facter::Core::Suitable
  end

  describe "setting options" do

    it "can set the timeout" do
      subject.set_options(:timeout => 314)
      expect(subject.limit).to eq 314
    end

    it "can set the weight" do
      subject.set_options(:weight => 27)
      expect(subject.weight).to eq 27
    end

    it "can set the name" do
      subject.set_options(:name => 'something')
      expect(subject.name).to eq 'something'
    end

    it "fails on unhandled options" do
      expect do
        subject.set_options(:foo => 'bar')
      end.to raise_error(ArgumentError, /Invalid aggregate options .*foo/)
    end
  end

  describe "declaring chunks" do
    it "requires that an chunk is given a block" do
      expect { subject.chunk(:fail) }.to raise_error(ArgumentError, /requires a block/)
    end

    it "allows an chunk to have a list of requirements" do
      subject.chunk(:data, :require => [:other]) { }
      expect(subject.deps[:data]).to eq [:other]
    end

    it "converts a single chunk requirement to an array" do
      subject.chunk(:data, :require => :other) { }
      expect(subject.deps[:data]).to eq [:other]
    end

    it "raises an error when an unhandled option is passed" do
      expect {
        subject.chunk(:data, :before => [:other]) { }
      }.to raise_error(ArgumentError, /Unexpected options.*#chunk: .*before/)
    end
  end

  describe "handling interactions between chunks" do
    it "generates a warning when there is a dependency cycle in chunks" do
      subject.chunk(:first, :require => [:second]) { }
      subject.chunk(:second, :require => [:first]) { }

      Facter.expects(:warn) do |msg|
        expect(msg).to match /dependency cycles: .*[:first, :second]/
      end

      subject.value
    end

    it "passes all requested chunk results to the depending chunk" do
      subject.chunk(:first) { ['foo'] }
      subject.chunk(:second, :require => [:first]) do |first|
        [first[0] + ' bar']
      end

      output = subject.value
      expect(output).to include 'foo'
      expect(output).to include 'foo bar'
    end

    it "clones and freezes chunk results passed to other chunks" do
      subject.chunk(:first) { 'foo' }
      subject.chunk(:second, :require => [:first]) do |first|
        expect(first).to be_frozen
      end

      subject.aggregate do |chunks|
        chunks.values.each do |chunk|
          expect(chunk).to be_frozen
        end
      end
    end
  end

  describe "aggregating chunks" do
    it "passes all chunk results as a hash to the aggregate block" do
      subject.chunk(:data) { 'data chunk' }
      subject.chunk(:datum) { 'datum chunk' }

      subject.aggregate do |chunks|
        expect(chunks).to eq(:data => 'data chunk', :datum => 'datum chunk')
      end

      subject.value
    end

    it "uses the result of the aggregate block as the value" do
      subject.aggregate { "who needs chunks anyways" }
      expect(subject.value).to eq "who needs chunks anyways"
    end
  end

  describe "evaluating" do
    it "evaluates the block in the context of the aggregate" do
      subject.expects(:has_weight).with(5)
      subject.evaluate { has_weight(5) }
    end
  end
end
