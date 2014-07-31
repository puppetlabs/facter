Facter.add(:foo) do
    setcode do
        begin
            raise "what's up doc?"
        rescue Exception => ex
            Facter.log_exception ex
        end
    end
end
