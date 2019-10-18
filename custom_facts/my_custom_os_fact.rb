# frozen_string_literal: true

LegacyFacter.add(:oss) do
  has_weight(10_000)
  setcode do
    'my_custom_os'
  end
end
