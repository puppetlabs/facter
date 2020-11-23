# frozen_string_literal: true

describe Facter::FactCollection do
  subject(:fact_collection) { Facter::FactCollection.new }

  describe '#build_fact_collection!' do
    let(:user_query) { 'os' }
    let(:resolved_fact) { Facter::ResolvedFact.new(fact_name, fact_value, type) }
    let(:logger) { instance_spy(Facter::Log) }

    before do
      resolved_fact.filter_tokens = []
      resolved_fact.user_query = user_query

      allow(Facter::Log).to receive(:new).and_return(logger)
    end

    context 'when fact has some value' do
      let(:fact_name) { 'os.version' }
      let(:fact_value) { '1.2.3' }
      let(:type) { :core }

      it 'adds fact to collection' do
        fact_collection.build_fact_collection!([resolved_fact])
        expected_hash = { 'os' => { 'version' => fact_value } }

        expect(fact_collection).to eq(expected_hash)
      end
    end

    context 'when fact value is nil' do
      context 'when fact type is legacy' do
        let(:fact_name) { 'os.version' }
        let(:fact_value) { nil }
        let(:type) { :legacy }

        it 'does not add fact to collection' do
          fact_collection.build_fact_collection!([resolved_fact])
          expected_hash = {}

          expect(fact_collection).to eq(expected_hash)
        end
      end

      context 'when fact type is core' do
        let(:fact_name) { 'os.version' }
        let(:fact_value) { nil }
        let(:type) { :core }

        it 'does not add fact to collection' do
          fact_collection.build_fact_collection!([resolved_fact])
          expected_hash = {}

          expect(fact_collection).to eq(expected_hash)
        end
      end

      context 'when fact type is :custom' do
        let(:fact_name) { 'operatingsystem' }
        let(:fact_value) { nil }
        let(:type) { :custom }

        it 'does not add fact to collection' do
          fact_collection.build_fact_collection!([resolved_fact])
          expected_hash = {}

          expect(fact_collection).to eq(expected_hash)
        end
      end
    end

    context 'when fact cannot be added to collection' do
      let(:fact_name) { 'mygroup.fact1' }
      let(:fact_value) { 'g1_f1_value' }
      let(:type) { :custom }

      let(:resolved_fact2) { Facter::ResolvedFact.new('mygroup.fact1.subfact1', 'g1_sg1_f1_value', type) }

      it 'logs error' do
        fact_collection.build_fact_collection!([resolved_fact, resolved_fact2])

        expect(logger).to have_received(:error)
      end
    end
  end
end
