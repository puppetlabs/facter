# frozen_string_literal: true

describe 'ResolvedFact' do
  context 'when is a legacy fact' do
    subject(:resolved_fact) { Facter::ResolvedFact.new('fact_name', 'fact_value', :legacy) }

    it 'responds to legacy? method with true' do
      expect(resolved_fact.legacy?).to eql(true)
    end

    it 'responds to core? method with false' do
      expect(resolved_fact.core?).to eql(false)
    end
  end

  context 'when is a core fact' do
    subject(:resolved_fact) { Facter::ResolvedFact.new('fact_name', 'fact_value') }

    it 'responds to legacy? method with true' do
      expect(resolved_fact.legacy?).to eql(false)
    end

    it 'responds to core? method with false' do
      expect(resolved_fact.core?).to eql(true)
    end
  end

  context 'when is an invalid type' do
    it 'raises an ArgumentError' do
      expect do
        Facter::ResolvedFact.new('fact_name', 'fact_value', :type)
      end.to raise_error(ArgumentError, 'The type provided for fact is not legacy or core!')
    end
  end
end
