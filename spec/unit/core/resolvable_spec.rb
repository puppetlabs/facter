require 'spec_helper'
require 'facter/core/resolvable'

describe Facter::Core::Resolvable do

  class ResolvableClass
    def initialize(name)
      @name = name
      @fact = Facter::Util::Fact.new("stub fact")
    end
    attr_accessor :name, :resolve_value
    attr_reader :fact
    include Facter::Core::Resolvable
  end

  subject { ResolvableClass.new('resolvable') }

  it "has a default timeout of 0 seconds" do
    expect(subject.limit).to eq 0
  end

  it "can specify a custom timeout" do
    subject.timeout = 10
    expect(subject.limit).to eq 10
  end

  describe "generating a value" do
    it "returns the results of #resolve_value" do
      subject.resolve_value = 'stuff'
      expect(subject.value).to eq 'stuff'
    end

    it "normalizes the resolved value" do
      Facter::Util::Normalization.expects(:normalize).returns 'stuff'
      subject.resolve_value = 'stuff'
      expect(subject.value).to eq('stuff')
    end

    it "logs a warning if an exception was raised" do
      subject.expects(:resolve_value).raises RuntimeError, "kaboom!"
      Facter.expects(:warn).with(regexp_matches(/Could not retrieve .*: kaboom!/))
      expect(subject.value).to eq nil
    end
  end

  describe "timing out" do
    it "uses #limit instead of #timeout to determine the timeout period" do
      subject.expects(:timeout).never
      subject.expects(:limit).returns 25

      Timeout.expects(:timeout).with(25)
      subject.value
    end

    it "returns nil if the timeout was reached" do
      Facter.expects(:warn).with(regexp_matches(/Timed out after 0\.1 seconds while resolving/))
      Timeout.expects(:timeout).raises Timeout::Error

      subject.timeout = 0.1

      expect(subject.value).to be_nil
    end
  end

  describe 'callbacks when flushing facts' do
    class FlushFakeError < StandardError; end

    context '#on_flush' do
      it 'accepts a block with on_flush' do
        subject.on_flush() { raise NotImplementedError }
      end
    end

    context '#flush' do
      it 'calls the block passed to on_flush' do
        subject.on_flush() { raise FlushFakeError }
        expect { subject.flush }.to raise_error FlushFakeError
      end
    end
  end
end
