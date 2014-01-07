require 'spec_helper'
require 'facter/core/resolvable'

describe Facter::Core::Resolvable do

  class ResolvableClass
    def initialize(name)
      @name = name
    end
    attr_accessor :name, :resolve_value
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
    let(:fact_value) { "" }

    let(:utf16_string) do
      if String.method_defined?(:encode) && defined?(::Encoding)
        fact_value.encode(Encoding::UTF_16LE).freeze
      else
        [0x00, 0x00].pack('C*').freeze
      end
    end

    let(:expected_value) do
      if String.method_defined?(:encode) && defined?(::Encoding)
        fact_value.encode(Encoding::UTF_8).freeze
      else
        [0x00, 0x00].pack('C*').freeze
      end
    end

    it "returns the results of #resolve_value" do
      subject.resolve_value = 'stuff'
      expect(subject.value).to eq 'stuff'
    end

    it "normalizes the resolved value" do
      subject.resolve_value = fact_value
      expect(subject.value).to eq(expected_value)
    end

    it "returns nil if an exception was raised" do
      subject.expects(:resolve_value).raises RuntimeError, "kaboom!"
      expect(subject.value).to eq nil
    end

    it "logs a warning if an exception was raised" do
      subject.expects(:resolve_value).raises RuntimeError, "kaboom!"
      Facter.expects(:warn).with('Could not retrieve resolvable: kaboom!')
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

    it "times out after the provided timeout" do
      def subject.resolve_value
        sleep 2
      end
      subject.timeout = 0.1
      subject.value
    end

    it "returns nil if the timeout was reached" do
      Timeout.expects(:timeout).raises Timeout::Error

      expect(subject.value).to be_nil
    end


    it "starts a thread to wait on all child processes if the timeout was reached" do
      Thread.expects(:new).yields
      Process.expects(:waitall)

      Timeout.expects(:timeout).raises Timeout::Error

      subject.value
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
