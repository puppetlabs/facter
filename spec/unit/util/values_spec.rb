require 'spec_helper'
require 'facter/util/values'

describe Facter::Util::Values do
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
        }.to raise_error(ArgumentError, /Cannot merge .*at .*foo.*bar.*baz.*quux/)
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
          }.to raise_error(ArgumentError, /Cannot merge #{left.inspect}:#{left.class} and #{right.inspect}:#{right.class}/)
        end
      end
    end
  end
end
