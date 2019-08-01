module Facter
  class FactLoader
    def self.load(os)
      # load facts/#{os}/*.rb
      {
        'networking.ip' => 'NetworkIP',
        'networking.interface' => 'NetworkInterface'
      }
    end
  end
end
