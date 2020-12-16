# frozen_string_literal: true

class Ifaddr
  def name; end

  def addr; end

  def netmask; end
end

class AddrInfo
  def ip_address; end

  def ip?; end

  def ipv4?; end

  def getnameinfo; end

  def inspect_sockaddr; end
end
