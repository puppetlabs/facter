# frozen_string_literal: true

describe Facter::FactCollection do
  subject(:fact_collection) { Facter::FactCollection.new }

  describe '#build_fact_collection!' do
    let(:user_query) { 'os' }
    let(:resolved_fact) { Facter::ResolvedFact.new(fact_name, fact_value, type, user_query) }
    let(:logger) { instance_spy(Facter::Log) }

    before do
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

      context 'when fact type is :legacy' do
        context 'when fact name contains dots' do
          let(:fact_name) { 'my.dotted.external.fact.name' }
          let(:fact_value) { 'legacy_fact_value' }
          let(:type) { :legacy }

          it 'returns a fact with dot in it`s name' do
            fact_collection.build_fact_collection!([resolved_fact])

            expected_hash = { 'my.dotted.external.fact.name' => 'legacy_fact_value' }

            expect(fact_collection).to eq(expected_hash)
          end
        end
      end
    end

    context 'when fact cannot be added to collection' do
      let(:fact_name) { 'mygroup.fact1' }
      let(:fact_value) { 'g1_f1_value' }
      let(:type) { :custom }

      let(:resolved_fact2) { Facter::ResolvedFact.new('mygroup.fact1.subfact1', 'g1_sg1_f1_value', type) }

      it 'logs error' do
        allow(Facter::Options).to receive(:[]).with(:force_dot_resolution).and_return(true)
        fact_collection.build_fact_collection!([resolved_fact, resolved_fact2])

        expect(logger).to have_received(:error)
      end
    end
  end

  describe '#value' do
    it 'raises KeyError for a non-existent key' do
      expect { fact_collection.value('non-existent') }.to raise_error(KeyError)
    end

    context 'when string value' do
      before do
        fact_collection['fact_name'] = 'value'
      end

      it 'returns the value by key' do
        expect(fact_collection.value('fact_name')).to eql('value')
      end
    end

    context 'when array value' do
      before do
        fact_collection['fact_name'] = [1, 2, 3]
      end

      it 'returns the value by key' do
        expect(fact_collection.value('fact_name')).to eql([1, 2, 3])
      end

      it 'returns the value by index' do
        expect(fact_collection.value('fact_name.1')).to be(2)
      end

      it 'raises KeyError when nested key is not found in array' do
        expect { fact_collection.value('fact_name.1.2') }.to raise_error(KeyError)
      end

      it 'raises TypeError for a non-existent index' do
        expect { fact_collection.value('fact_name.4') }.to raise_error(TypeError)
      end
    end

    context 'when hash value' do
      before do
        fact_collection['fact_name'] = { 'key1' => 'value' }
      end

      it 'returns the value by key' do
        expect(fact_collection.value('fact_name')).to eql({ 'key1' => 'value' })
      end

      it 'returns the value by nested key' do
        expect(fact_collection.value('fact_name.key1')).to eql('value')
      end

      it 'raises KeyError when nested key is not found in array' do
        expect { fact_collection.value('fact_name.key1.2') }.to raise_error(KeyError)
      end
    end

    context 'when deeply nested hash and array value' do
      before do
        fact_collection['fact_name'] = { 'key1' => [0, { 'key2' => 'value2' }, 2] }
      end

      it 'returns the value by key' do
        expect(fact_collection.value('fact_name')).to eql({ 'key1' => [0, { 'key2' => 'value2' }, 2] })
      end

      it 'returns the value by nested key and index' do
        expect(fact_collection.value('fact_name.key1.1.key2')).to eql('value2')
      end

      it 'raises KeyError when nested key is not found' do
        expect { fact_collection.value('fact_name.key1.2.not') }.to raise_error(KeyError)
      end

      it 'raises TypeError when nested index is not found' do
        expect { fact_collection.value('fact_name.key1.5') }.to raise_error(TypeError)
      end
    end
  end
end
