# frozen_string_literal: true

require_relative '../../spec_helper_legacy'

describe LegacyFacter::Core::Suitable do
  class SuitableClass
    def initialize
      @confines = []
    end
    attr_reader :confines
    include LegacyFacter::Core::Suitable
  end

  subject(:suitable_obj) { SuitableClass.new }

  describe 'confining on facts' do
    it 'can add confines with a fact and a single value' do
      suitable_obj.confine kernel: 'Linux'
    end

    it 'creates a Facter::Util::Confine object for the confine call' do
      suitable_obj.confine kernel: 'Linux'
      conf = suitable_obj.confines.first
      expect(conf).to be_an_instance_of(LegacyFacter::Util::Confine).and(
        having_attributes(fact: :kernel, values: ['Linux'])
      )
    end
  end

  describe 'confining on blocks' do
    it 'can add a single fact with a block parameter' do
      suitable_obj.confine(:one) { true }
    end

    it 'creates a Util::Confine instance for the provided fact with block parameter' do
      block = -> { true }
      # Facter::Util::Confine.expects(:new).with("one")
      expect(LegacyFacter::Util::Confine).to receive(:new).with('one')
      suitable_obj.confine('one', &block)
    end

    it 'accepts a single block parameter' do
      suitable_obj.confine { true }
    end

    it 'creates a Util::Confine instance for the provided block parameter' do
      block = -> { true }
      expect(LegacyFacter::Util::Confine).to receive :new

      suitable_obj.confine(&block)
    end
  end

  describe 'determining weight' do
    it 'is zero if no confines are set' do
      expect(suitable_obj.weight).to eq 0
    end

    it 'defaults to the number of confines' do
      suitable_obj.confine kernel: 'Linux'
      expect(suitable_obj.weight).to eq 1
    end

    it 'can be explicitly set' do
      suitable_obj.has_weight 10
      expect(suitable_obj.weight).to eq 10
    end

    it 'prefers an explicit weight over the number of confines' do
      suitable_obj.confine kernel: 'Linux'
      suitable_obj.has_weight 11
      expect(suitable_obj.weight).to eq 11
    end

    it 'returns the class instance' do
      expect(suitable_obj.has_weight(10)).to be(suitable_obj)
    end
  end

  describe 'determining suitability' do
    it 'is true if all confines for the object evaluate to true' do
      suitable_obj.confine kernel: 'Linux'
      suitable_obj.confine operatingsystem: 'Redhat'

      suitable_obj.confines.each { |confine| allow(confine).to receive(:true?).and_return(true) }

      expect(suitable_obj).to be_suitable
    end

    it 'is false if any confines for the object evaluate to false' do
      suitable_obj.confine kernel: 'Linux'
      suitable_obj.confine operatingsystem: 'Redhat'
      allow(suitable_obj.confines.first).to receive(:true?).and_return(false)

      expect(suitable_obj).not_to be_suitable
    end

    it 'recalculates suitability on every invocation' do
      suitable_obj.confine kernel: 'Linux'

      allow(suitable_obj.confines.first).to receive(:true?).and_return(false)
      allow(suitable_obj.confines.first).to receive(:true?).and_return(true)

      expect(suitable_obj).to be_suitable
    end
  end
end
