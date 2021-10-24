# frozen_string_literal: true

test_name 'Can use environment facts' do
  step 'FACTER_ env fact is correctly resolved' do
    fact_name = 'env_name'
    fact_value = 'env_value'

    on(agent, facter(fact_name, environment: { "FACTER_#{fact_name}" => fact_value })) do |facter_output|
      assert_equal(
        fact_value,
        facter_output.stdout.chomp,
        'Expected `FACTER_` to be resolved from environment'
      )
    end
  end

  step 'FACTER_ env fact is correctly resolved when the fact name is upcased' do
    fact_name = 'env_name'
    fact_value = 'env_value'

    on(agent, facter(fact_name, environment: { "FACTER_#{fact_name.upcase}" => fact_value })) do |facter_output|
      assert_equal(
        fact_value,
        facter_output.stdout.chomp,
        'Expected `FACTER_` to be resolved from environment'
      )
    end
  end
end
