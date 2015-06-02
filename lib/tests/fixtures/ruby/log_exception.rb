Facter.add(:foo) do
    setcode do
        begin
            raise "first"
        rescue Exception => ex
            Facter.log_exception ex
        end

        begin
            raise "second"
        rescue Exception => ex
            Facter.log_exception ex, :default
        end

        begin
            raise "nope"
        rescue Exception => ex
            Facter.log_exception ex, 'third'
        end
    end
end
