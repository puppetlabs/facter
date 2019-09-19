# frozen_string_literal: true

def mock_os(os_name)
  allow(CurrentOs.instance)
    .to receive(:identifier)
    .and_return(os_name)
end

def mock_fact_loader_with_legacy(os_name, loaded_facts_hash)
  allow(Facter::FactLoader)
    .to receive(:load_with_legacy)
    .with(os_name)
    .and_return(loaded_facts_hash)
end

def mock_fact_loader(os_name, loaded_fact_hash)
  allow(Facter::FactLoader)
    .to receive(:load)
    .with(os_name)
    .and_return(loaded_fact_hash)
end

def mock_query_parser(user_query, loaded_fact_hash)
  allow_any_instance_of(Facter::QueryParser)
    .to receive(:parse)
    .with(user_query, loaded_fact_hash)
end

private_methods def allow_attr_change(resolved_fact_mock, fact_name, fact_value)
  allow(resolved_fact_mock)
    .to receive(:value=)
    .with(fact_value)

  allow(resolved_fact_mock)
    .to receive(:name=)
    .with(fact_name)

  allow(resolved_fact_mock)
    .to receive(:user_query=)

  allow(resolved_fact_mock)
    .to receive(:filter_tokens=)
end

def mock_resolved_fact(fact_name, fact_value, user_query = nil, filter_tokens = [])
  resolved_fact_mock = double(Facter::ResolvedFact, name: fact_name, value: fact_value,
                                                    user_query: user_query, filter_tokens: filter_tokens)

  allow_attr_change(resolved_fact_mock, fact_name, fact_value)
  resolved_fact_mock
end

def mock_fact(fact_class_name, resolved_fact_to_return, fact_name = nil)
  fact_mock = double(fact_class_name)

  allow_any_instance_of(fact_class_name)
    .to receive(:new)
    .and_return(fact_mock)

  allow_any_instance_of(fact_class_name)
    .to receive(:call_the_resolver)
    .and_return(resolved_fact_to_return)

  stub_const(fact_class_name.to_s, fact_name) if fact_name.present?

  fact_mock
end

def load_fixture(filename)
  File.open(File.join('spec', 'fixtures', filename))
end
