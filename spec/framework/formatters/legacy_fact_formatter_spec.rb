# frozen_string_literal: true

describe Facter::LegacyFactFormatter do
  let(:resolved_fact1) do
    Facter::ResolvedFact.new('resolved_fact1', 'resolved_fact1_value')
  end

  let(:resolved_fact2) do
    Facter::ResolvedFact.new('resolved_fact2', 'resolved_fact2_value')
  end

  let(:nested_fact1) do
    Facter::ResolvedFact.new('my.nested.fact1', 'my_nested_fact_value')
  end

  let(:nested_fact2) do
    Facter::ResolvedFact.new('my.nested.fact2', 'my_nested_fact_value')
  end

  let(:nested_fact3) do
    Facter::ResolvedFact.new('my.nested.fact3', 'value')
  end

  let(:nil_resolved_fact1) do
    Facter::ResolvedFact.new('nil_resolved_fact1', nil)
  end

  let(:nil_resolved_fact2) do
    Facter::ResolvedFact.new('nil_resolved_fact2', nil)
  end

  let(:nil_nested_fact1) do
    Facter::ResolvedFact.new('my.nested.fact1', nil)
  end

  let(:nil_nested_fact2) do
    Facter::ResolvedFact.new('my.nested.fact2', nil)
  end

  before do
    resolved_fact1.user_query = 'resolved_fact1'
    resolved_fact1.filter_tokens = []

    resolved_fact2.user_query = 'resolved_fact2'
    resolved_fact2.filter_tokens = []

    nested_fact1.user_query = 'my.nested.fact1.4'
    nested_fact1.filter_tokens = [4]

    nested_fact2.user_query = 'my.nested.fact2.3'
    nested_fact2.filter_tokens = [3]

    nested_fact3.user_query = 'my.nested.fact3.my_nested_fact_value.1.another'
    nested_fact3.filter_tokens = ['my_nested_fact_value', 1, 'another']

    nil_resolved_fact1.user_query = 'nil_resolved_fact1'
    nil_resolved_fact1.filter_tokens = []

    nil_resolved_fact2.user_query = 'nil_resolved_fact2'
    nil_resolved_fact2.filter_tokens = []

    nil_nested_fact1.user_query = 'my'
    nil_nested_fact1.filter_tokens = []

    nil_nested_fact2.user_query = 'my.nested.fact2'
    nil_nested_fact2.filter_tokens = []
  end

  context 'format when no user query' do
    let(:expected_output) { "resolved_fact1 => resolved_fact1_value\nresolved_fact2 => resolved_fact2_value" }

    context 'facts have value' do
      it 'returns output' do
        formatted_output = Facter::LegacyFactFormatter.new.format([resolved_fact1, resolved_fact2])

        expect(formatted_output).to eq(expected_output)
      end
    end

    context 'facts value is nil' do
      before do
        nil_resolved_fact1.user_query = ''
        nil_resolved_fact2.user_query = ''
        resolved_fact2.user_query = ''
        nil_nested_fact1.user_query = ''
        nil_nested_fact2.user_query = ''
      end

      context 'root level fact' do
        it 'prints facts with nill values' do
          formatted_output = Facter::LegacyFactFormatter.new.format([nil_resolved_fact1, nil_resolved_fact2])
          expect(formatted_output).to eq("nil_resolved_fact1 => null\nnil_resolved_fact2 => null")
        end

        it 'prints one fact with nil value and one fact with a value' do
          formatted_output = Facter::LegacyFactFormatter.new.format([nil_resolved_fact1, resolved_fact2])
          expect(formatted_output).to eq("nil_resolved_fact1 => null\nresolved_fact2 => resolved_fact2_value")
        end
      end

      context 'facts are nested' do
        it 'prints facts with nil values' do
          formatted_output = Facter::LegacyFactFormatter.new.format([nil_nested_fact1, nil_nested_fact2])
          expect(formatted_output).to eq("my => {\n  nested => {\n    fact1 => null,\n    fact2 => null\n  }\n}")
        end

        it 'prints one fact with nil value and one fact with a value' do
          formatted_output =
            Facter::LegacyFactFormatter.new.format([nil_nested_fact1, nil_nested_fact2, resolved_fact2])
          facter_output = "my => {\n  nested => {\n    fact1 => null,\n    fact2 => null\n  }\n}\n" \
                          'resolved_fact2 => resolved_fact2_value'

          expect(formatted_output).to eq(facter_output)
        end
      end
    end
  end

  context 'format when one user query' do
    context 'facts have values' do
      it 'returns single value' do
        formatted_output = Facter::LegacyFactFormatter.new.format([resolved_fact1])

        expect(formatted_output).to eq('resolved_fact1_value')
      end

      it 'returns a single value for a nested fact' do
        formatted_output = Facter::LegacyFactFormatter.new.format([nested_fact1])

        expect(formatted_output).to eq('my_nested_fact_value')
      end

      context 'formats to legacy for a single user query that contains :' do
        let(:resolved_fact) do
          double(Facter::ResolvedFact, name: 'networking.ip6', value: 'fe80::7ca0:ab22:703a:b329',
                                       user_query: 'networking.ip6', filter_tokens: [])
        end

        it 'returns single value without replacing : with =>' do
          formatted_output = Facter::LegacyFactFormatter.new.format([resolved_fact])

          expect(formatted_output).to eq('fe80::7ca0:ab22:703a:b329')
        end
      end
    end

    context 'fact value is nil' do
      context 'root level fact' do
        it 'prints no values if all facts are nil' do
          formatted_output = Facter::LegacyFactFormatter.new.format([nil_resolved_fact1])
          expect(formatted_output).to eq('')
        end
      end

      context 'facts are nested' do
        it 'returns empty strings for first level query' do
          formatted_output = Facter::LegacyFactFormatter.new.format([nil_nested_fact1])
          expect(formatted_output).to eq("{\n  nested => {\n    fact1 => null\n  }\n}")
        end

        it 'returns empty strings for leaf level query' do
          nil_nested_fact1.user_query = 'my.nested.fact1'
          formatted_output = Facter::LegacyFactFormatter.new.format([nil_nested_fact1])
          expect(formatted_output).to eq('')
        end
      end
    end
  end

  context 'format when multiple user queries' do
    context 'facts have values' do
      let(:expected_output) { "resolved_fact1 => resolved_fact1_value\nresolved_fact2 => resolved_fact2_value" }
      let(:nested_expected_output) do
        "my.nested.fact1.4 => my_nested_fact_value\nmy.nested.fact2.3 => my_nested_fact_value"
      end

      it 'returns output' do
        formatted_output = Facter::LegacyFactFormatter.new.format([resolved_fact1, resolved_fact2])

        expect(formatted_output).to eq(expected_output)
      end

      it 'returns output for multiple user queries' do
        formatted_output = Facter::LegacyFactFormatter.new.format([nested_fact1, nested_fact2])

        expect(formatted_output).to eq(nested_expected_output)
      end

      context 'when value is a hash' do
        it "returns 'value'" do
          formatted_output = Facter::LegacyFactFormatter.new.format([nested_fact3])

          expect(formatted_output).to eq('value')
        end
      end
    end

    context 'fact value is nil' do
      context 'root level fact' do
        it 'prints no values if all facts are nil' do
          formatted_output = Facter::LegacyFactFormatter.new.format([nil_resolved_fact1, nil_resolved_fact2])
          expect(formatted_output).to eq("nil_resolved_fact1 => \nnil_resolved_fact2 => ")
        end

        it 'prints a value only for the fact that is not nil' do
          formatted_output = Facter::LegacyFactFormatter.new.format([nil_resolved_fact1, resolved_fact2])
          expect(formatted_output).to eq("nil_resolved_fact1 => \nresolved_fact2 => resolved_fact2_value")
        end
      end

      context 'facts are nested' do
        it 'returns empty strings for first and leaf level query' do
          formatted_output = Facter::LegacyFactFormatter.new.format([nil_resolved_fact1, nil_nested_fact2])
          expect(formatted_output).to eq("my.nested.fact2 => \nnil_resolved_fact1 => ")
        end

        it 'returns empty strings for leaf level query' do
          nil_nested_fact1.user_query = 'my.nested.fact1'
          formatted_output = Facter::LegacyFactFormatter.new.format([nil_resolved_fact1, resolved_fact2])
          expect(formatted_output).to eq("nil_resolved_fact1 => \nresolved_fact2 => resolved_fact2_value")
        end
      end
    end
  end

  context 'formats to legacy for empty resolved fact array' do
    it 'returns nil' do
      formatted_output = Facter::LegacyFactFormatter.new.format([])

      expect(formatted_output).to eq(nil)
    end
  end
end
