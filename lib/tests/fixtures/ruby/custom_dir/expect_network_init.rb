require 'net/http'
Facter.add('sometest') do
  setcode do
    begin
      uri = URI("http://www.puppet.com")
      if (Net::HTTP.get_response(uri))
        'Yay'
      else
        'Nay'
      end
    rescue => e
      e.message
    end
  end
end