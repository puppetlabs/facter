Facter.add("timezone") do
     setcode do
         Time.new.zone
     end
end
