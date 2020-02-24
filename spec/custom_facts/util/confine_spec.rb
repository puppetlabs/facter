#! /usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper_legacy'

describe LegacyFacter::Util::Confine do
  it 'requires a fact name' do
    expect(LegacyFacter::Util::Confine.new('yay', true).fact).to eq 'yay'
  end

  it 'accepts a value specified individually' do
    expect(LegacyFacter::Util::Confine.new('yay', 'test').values).to eq ['test']
  end

  it 'accepts multiple values specified at once' do
    expect(LegacyFacter::Util::Confine.new('yay', 'test', 'other').values).to eq %w[test other]
  end

  it 'fails if no fact name is provided' do
    expect { LegacyFacter::Util::Confine.new(nil, :test) }.to raise_error(ArgumentError)
  end

  it 'fails if no values were provided' do
    expect { LegacyFacter::Util::Confine.new('yay') }.to raise_error(ArgumentError)
  end

  it 'has a method for testing whether it matches' do
    expect(LegacyFacter::Util::Confine.new('yay', :test)).to respond_to(:true?)
  end

  describe 'when evaluating' do
    def confined(fact_value, *confines)
      allow(@fact).to receive(:value).and_return fact_value
      LegacyFacter::Util::Confine.new('yay', *confines).true?
    end

    before do
      @fact = double 'fact'
      allow(Facter).to receive(:[]).and_return @fact
    end

    it 'returns false if the fact does not exist' do
      expect(Facter).to receive(:[]).with('yay').and_return nil

      expect(LegacyFacter::Util::Confine.new('yay', 'test').true?).to be false
    end

    it 'uses the returned fact to get the value' do
      expect(Facter).to receive(:[]).with('yay').and_return @fact

      expect(@fact).to receive(:value).and_return nil

      LegacyFacter::Util::Confine.new('yay', 'test').true?
    end

    it 'returns false if the fact has no value' do
      expect(confined(nil, 'test')).to be false
    end

    it "returns true if any of the provided values matches the fact's value" do
      expect(confined('two', 'two')).to be true
    end

    it "returns true if any of the provided symbol values matches the fact's value" do
      expect(confined(:xy, :xy)).to be true
    end

    it "returns true if any of the provided integer values matches the fact's value" do
      expect(confined(1, 1)).to be true
    end

    it "returns true if any of the provided boolan values matches the fact's value" do
      expect(confined(true, true)).to be true
    end

    it "returns true if any of the provided array values matches the fact's value" do
      expect(confined([3, 4], [3, 4])).to be true
    end

    it "returns true if any of the provided symbol values matches the fact's string value" do
      expect(confined(:one, 'one')).to be true
    end

    it "returns true if any of the provided string values matches case-insensitive the fact's value" do
      expect(confined('four', 'Four')).to be true
    end

    it "returns true if any of the provided symbol values matches case-insensitive the fact's string value" do
      expect(confined(:four, 'Four')).to be true
    end

    it "returns true if any of the provided symbol values matches the fact's string value" do
      expect(confined('xy', :xy)).to be true
    end

    it "returns true if any of the provided regexp values matches the fact's string value" do
      expect(confined('abc', /abc/)).to be true
    end

    it "returns true if any of the provided ranges matches the fact's value" do
      expect(confined(6, (5..7))).to be true
    end

    it "returns false if none of the provided values matches the fact's value" do
      expect(confined('three', 'two', 'four')).to be false
    end

    it "returns false if none of the provided integer values matches the fact's value" do
      expect(confined(2, 1, [3, 4], (5..7))).to be false
    end

    it "returns false if none of the provided boolan values matches the fact's value" do
      expect(confined(false, true)).to be false
    end

    it "returns false if none of the provided array values matches the fact's value" do
      expect(confined([1, 2], [3, 4])).to be false
    end

    it "returns false if none of the provided ranges matches the fact's value" do
      expect(confined(8, (5..7))).to be false
    end

    it 'accepts and evaluate a block argument against the fact' do
      expect(@fact).to receive(:value).and_return 'foo'
      confine = LegacyFacter::Util::Confine.new(:yay) { |f| f === 'foo' }
      expect(confine.true?).to be true
    end

    it 'returns false if the block raises a StandardError when checking a fact' do
      allow(@fact).to receive(:value).and_return 'foo'
      confine = LegacyFacter::Util::Confine.new(:yay) { |_f| raise StandardError }
      expect(confine.true?).to be false
    end

    it 'accepts and evaluate only a block argument' do
      expect(LegacyFacter::Util::Confine.new { true }.true?).to be true
      expect(LegacyFacter::Util::Confine.new { false }.true?).to be false
    end

    it 'returns false if the block raises a StandardError' do
      expect(LegacyFacter::Util::Confine.new { raise StandardError }.true?).to be false
    end
  end
end
