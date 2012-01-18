require 'facter'

Facter.add('zonename') do
  confine :kernel => :sunos
  setcode('zonename')
end
