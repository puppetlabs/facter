# frozen_string_literal: true

describe Facter::ResolvedFact do
  context 'when is a legacy fact' do
    subject(:resolved_fact) { Facter::ResolvedFact.new('fact_name', 'fact_value', :legacy) }

    it 'responds to legacy? method with true' do
      expect(resolved_fact.legacy?).to be(true)
    end

    it 'responds to core? method with false' do
      expect(resolved_fact.core?).to be(false)
    end
  end

  context 'when is a core fact' do
    subject(:resolved_fact) { Facter::ResolvedFact.new('fact_name', 'fact_value') }

    it 'responds to legacy? method with true' do
      expect(resolved_fact.legacy?).to be(false)
    end

    it 'responds to core? method with false' do
      expect(resolved_fact.core?).to be(true)
    end

    # rubocop:disable Style/UnneededInterpolation
    it 'can be interpolated' do
      expect("#{resolved_fact}").to eq('fact_value')
    end

    it 'interpolation of nil value will be empty string' do
      resolved = Facter::ResolvedFact.new('fact_name', nil)
      expect("#{resolved}").to eq('')
    end
    # rubocop:enable Style/UnneededInterpolation
  end
end
