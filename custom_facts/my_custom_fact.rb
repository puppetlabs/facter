# frozen_string_literal: true

LegacyFacter.add(:my_custom_fact) do
  has_weight(10_000)
  setcode do
    # 'my_custom_fact'
    LegacyFacter.value('os')
  end
end
