Facter.add(:foo, :type => :aggregate) do
    chunk(:one) do
        1
    end

    chunk(:two) do
        2
    end

    chunk(:three) do
        3
    end

    chunk(:four) do
        4
    end

    aggregate do |chunks|
        raise 'nope' unless chunks.size == 4
        raise 'nope' unless chunks.has_key? :one
        raise 'nope' unless chunks.has_key? :two
        raise 'nope' unless chunks.has_key? :three
        raise 'nope' unless chunks.has_key? :four
        sum = 0
        chunks.each_value do |i|
            sum += i
        end
        sum
    end
end
