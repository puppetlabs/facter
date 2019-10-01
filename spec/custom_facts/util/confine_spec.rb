#! /usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper_legacy'

describe LegacyFacter::Util::Confine do
  it 'should require a fact name' do
    expect(LegacyFacter::Util::Confine.new('yay', true).fact).to eq 'yay'
  end

  it 'should accept a value specified individually' do
    expect(LegacyFacter::Util::Confine.new('yay', 'test').values).to eq ['test']
  end

  it 'should accept multiple values specified at once' do
    expect(LegacyFacter::Util::Confine.new('yay', 'test', 'other').values).to eq %w[test other]
  end

  it 'should fail if no fact name is provided' do
    expect(-> { LegacyFacter::Util::Confine.new(nil, :test) }).to raise_error(ArgumentError)
  end

  it 'should fail if no values were provided' do
    expect(-> { LegacyFacter::Util::Confine.new('yay') }).to raise_error(ArgumentError)
  end

  it 'should have a method for testing whether it matches' do
    expect(LegacyFacter::Util::Confine.new('yay', :test)).to respond_to(:true?)
  end

  describe 'when evaluating' do
    def confined(fact_value, *confines)
      allow(@fact).to receive(:value).and_return fact_value
      LegacyFacter::Util::Confine.new('yay', *confines).true?
    end

    before do
      @fact = double 'fact'
      allow(LegacyFacter).to receive(:[]).and_return @fact
    end

    it 'should return false if the fact does not exist' do
      expect(LegacyFacter).to receive(:[]).with('yay').and_return nil

      expect(LegacyFacter::Util::Confine.new('yay', 'test').true?).to be false
    end

    it 'should use the returned fact to get the value' do
      expect(LegacyFacter).to receive(:[]).with('yay').and_return @fact

      expect(@fact).to receive(:value).and_return nil

      LegacyFacter::Util::Confine.new('yay', 'test').true?
    end

    it 'should return false if the fact has no value' do
      expect(confined(nil, 'test')).to be false
    end

    it "should return true if any of the provided values matches the fact's value" do
      expect(confined('two', 'two')).to be true
    end

    it "should return true if any of the provided symbol values matches the fact's value" do
      expect(confined(:xy, :xy)).to be true
    end

    it "should return true if any of the provided integer values matches the fact's value" do
      expect(confined(1, 1)).to be true
    end

    it "should return true if any of the provided boolan values matches the fact's value" do
      expect(confined(true, true)).to be true
    end

    it "should return true if any of the provided array values matches the fact's value" do
      expect(confined([3, 4], [3, 4])).to be true
    end

    it "should return true if any of the provided symbol values matches the fact's string value" do
      expect(confined(:one, 'one')).to be true
    end

    it "should return true if any of the provided string values matches case-insensitive the fact's value" do
      expect(confined('four', 'Four')).to be true
    end

    it "should return true if any of the provided symbol values matches case-insensitive the fact's string value" do
      expect(confined(:four, 'Four')).to be true
    end

    it "should return true if any of the provided symbol values matches the fact's string value" do
      expect(confined('xy', :xy)).to be true
    end

    it "should return true if any of the provided regexp values matches the fact's string value" do
      expect(confined('abc', /abc/)).to be true
    end

    it "should return true if any of the provided ranges matches the fact's value" do
      expect(confined(6, (5..7))).to be true
    end

    it "should return false if none of the provided values matches the fact's value" do
      expect(confined('three', 'two', 'four')).to be false
    end

    it "should return false if none of the provided integer values matches the fact's value" do
      expect(confined(2, 1, [3, 4], (5..7))).to be false
    end

    it "should return false if none of the provided boolan values matches the fact's value" do
      expect(confined(false, true)).to be false
    end

    it "should return false if none of the provided array values matches the fact's value" do
      expect(confined([1, 2], [3, 4])).to be false
    end

    it "should return false if none of the provided ranges matches the fact's value" do
      expect(confined(8, (5..7))).to be false
    end

    it 'should accept and evaluate a block argument against the fact' do
      expect(@fact).to receive(:value).and_return 'foo'
      confine = LegacyFacter::Util::Confine.new(:yay) { |f| f === 'foo' }
      expect(confine.true?).to be true
    end

    it 'should return false if the block raises a StandardError when checking a fact' do
      allow(@fact).to receive(:value).and_return 'foo'
      confine = LegacyFacter::Util::Confine.new(:yay) { |_f| raise StandardError }
      expect(confine.true?).to be false
    end

    it 'should accept and evaluate only a block argument' do
      expect(LegacyFacter::Util::Confine.new { true }.true?).to be true
      expect(LegacyFacter::Util::Confine.new { false }.true?).to be false
    end

    it 'should return false if the block raises a StandardError' do
      expect(LegacyFacter::Util::Confine.new { raise StandardError }.true?).to be false
    end
  end
end
