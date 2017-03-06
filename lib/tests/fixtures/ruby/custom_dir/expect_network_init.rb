require 'net/http'
Facter.add('sometest') do
  setcode do
    begin
      s = Socket::new(:INET, :STREAM);
      sockaddr = Socket.pack_sockaddr_in(5555, '127.0.0.1')
      s.bind(sockaddr)
      s.listen(1)
      s.close
      "Yay"
    rescue
      "Nay"
    end
  end
end
