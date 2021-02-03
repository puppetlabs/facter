# frozen_string_literal: true

Facter.add(:my_custom_fact) do
  has_weight(10_000)
  setcode do
    Facter.value('os')
  end
end
