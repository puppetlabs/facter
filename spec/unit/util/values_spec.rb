require 'spec_helper'
require 'facter/util/values'

describe Facter::Util::Values do
  describe 'deep_freeze' do
    it "it dups and freezes strings" do
      input = "hi"
      output = described_class.deep_freeze(input)
      expect(input).to_not be_frozen
      expect(output).to be_frozen
    end

    it "freezes arrays and each element in the array" do
      input = %w[one two three]
      output = described_class.deep_freeze(input)

      input.each { |entry| expect(entry).to_not be_frozen }
      output.each { |entry| expect(entry).to be_frozen }

      expect(input).to_not be_frozen
      expect(output).to be_frozen
    end

    it "freezes hashes and each key and value in the hash" do
      input = {'one' => 'two', 'three' => 'four'}

      output = described_class.deep_freeze(input)

      input.each_pair do |key, val|
        # Ruby freezes all string keys, so these will always be frozen
        expect(key).to be_frozen
        expect(val).to_not be_frozen
      end

      output.each_pair do |key, val|
        expect(key).to be_frozen
        expect(val).to be_frozen
      end

      expect(input).to_not be_frozen
      expect(output).to be_frozen
    end

    it "raises an error when given a structure that cannot be deeply frozen" do
      expect {
        described_class.deep_freeze(Set.new)
      }.to raise_error(Facter::Util::Values::DeepFreezeError, /Cannot deep freeze.*Set/)
    end
  end

  describe 'deep_merge' do
    it "non-destructively concatenates arrays" do
      first = %w[foo bar]
      second = %w[baz quux]

      expect(described_class.deep_merge(first, second)).to eq %w[foo bar baz quux]
      expect(first).to eq %w[foo bar]
      expect(second).to eq %w[baz quux]
    end

    it "returns the left value if the right value is nil" do
      expect(described_class.deep_merge("left", nil)).to eq "left"
    end

    it "returns the right value if the left value is nil" do
      expect(described_class.deep_merge(nil, "right")).to eq "right"
    end

    it "returns nil if both values are nil" do
      expect(described_class.deep_merge(nil, nil)).to be_nil
    end

    describe "with hashes" do
      it "merges when keys do not overlap" do

        first = {:foo => 'bar'}
        second = {:baz => 'quux'}

        expect(described_class.deep_merge(first, second)).to eq(:foo => 'bar', :baz => 'quux')
        expect(first).to eq(:foo => 'bar')
        expect(second).to eq(:baz => 'quux')
      end

      it "concatenates arrays when both keys are arrays" do
        first = {:foo => %w[bar]}
        second = {:foo => %w[baz quux]}

        expect(described_class.deep_merge(first, second)).to eq(:foo => %w[bar baz quux])
        expect(first).to eq(:foo => %w[bar])
        expect(second).to eq(:foo => %w[baz quux])
      end

      it "merges hashes when both keys are hashes" do
        first = {:foo => {:pb => 'lead', :ag => 'silver'}}
        second = {:foo => {:au => 'gold', :na => 'sodium'}}

        expect(described_class.deep_merge(first, second)).to eq(
          :foo => {
            :pb => 'lead',
            :ag => 'silver',
            :au => 'gold',
            :na => 'sodium'
          }
        )
      end

      it "prints the data structure path if an error is raised" do
        first = {:foo => {:bar => {:baz => {:quux => true}}}}
        second = {:foo => {:bar => {:baz => {:quux => false}}}}

        expect {
          described_class.deep_merge(first, second)
        }.to raise_error(Facter::Util::Values::DeepMergeError, /Cannot merge .*at .*foo.*bar.*baz.*quux/)
      end
    end

    describe "with unmergable scalar values" do
      [
        [true, false],
        [1, 2],
        ['up', 'down']
      ].each do |(left, right)|
        it "raises an error when merging #{left}:#{left.class} and #{right}:#{right.class}" do
          expect {
            described_class.deep_merge(left, right)
          }.to raise_error(Facter::Util::Values::DeepMergeError, /Cannot merge #{left.inspect}:#{left.class} and #{right.inspect}:#{right.class}/)
        end
      end
    end
  end
end
