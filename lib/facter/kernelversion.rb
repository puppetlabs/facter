Facter.add("kernelversion") do
  setcode do
   Facter['kernelrelease'].value.split('-')[0]
  end	
end        
