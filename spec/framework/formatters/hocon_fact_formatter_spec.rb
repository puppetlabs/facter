# frozen_string_literal: true

describe Facter::HoconFactFormatter do
  it 'formats to hocon when no user query' do
    resolved_fact1 =
      double(Facter::ResolvedFact, name: 'os.name', value: 'Darwin',
                                   user_query: '', filter_tokens: [], type: :core)
    resolved_fact2 =
      double(Facter::ResolvedFact, name: 'os.family', value: 'Darwin',
                                   user_query: '', filter_tokens: [], type: :core)
    resolved_fact3 =
      double(Facter::ResolvedFact, name: 'os.architecture', value: 'x86_64',
                                   user_query: '', filter_tokens: [], type: :core)
    resolved_fact_list = [resolved_fact1, resolved_fact2, resolved_fact3]

    formatted_output = Facter::HoconFactFormatter.new.format(resolved_fact_list)

    expected_output = "os={\n  \s\sarchitecture=\"x86_64\"\n  \s\sfamily=Darwin\n  \s\sname=Darwin\n}\n"

    expect(formatted_output).to eq(expected_output)
  end

  it 'formats to hocon for a single user query' do
    resolved_fact =
      double(Facter::ResolvedFact, name: 'os.name', value: 'Darwin',
                                   user_query: 'os.name', filter_tokens: [], type: :core)
    resolved_fact_list = [resolved_fact]
    formatted_output = Facter::HoconFactFormatter.new.format(resolved_fact_list)

    expected_output = 'Darwin'

    expect(formatted_output).to eq(expected_output)
  end

  it 'formats to hocon for multiple user queries' do
    resolved_fact1 =
      double(Facter::ResolvedFact, name: 'os.name', value: 'Darwin',
                                   user_query: 'os.name', filter_tokens: [], type: :core)
    resolved_fact2 =
      double(Facter::ResolvedFact, name: 'os.family', value: 'Darwin',
                                   user_query: 'os.family', filter_tokens: [], type: :core)
    resolved_fact_list = [resolved_fact1, resolved_fact2]
    formatted_output = Facter::HoconFactFormatter.new.format(resolved_fact_list)

    expected_output = "\"os.family\"=Darwin\n\"os.name\"=Darwin\n"

    expect(formatted_output).to eq(expected_output)
  end

  it 'formats to hocon for empty resolved fact array' do
    formatted_output = Facter::HoconFactFormatter.new.format([])

    expect(formatted_output).to eq(nil)
  end

  it 'returns empty string when the fact value is nil' do
    resolved_fact1 =
      double(Facter::ResolvedFact, name: 'my_external_fact', value: nil,
                                   user_query: 'my_external_fact', filter_tokens: [], type: :core)
    resolved_fact_list = [resolved_fact1]

    formatted_output = Facter::HoconFactFormatter.new.format(resolved_fact_list)
    expect(formatted_output).to eq('')
  end
end
