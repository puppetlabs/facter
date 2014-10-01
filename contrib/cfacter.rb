# This formula requires that you be using Homebrew (http://brew.sh/) for
# 3rd party package management. To install this, run:
#   brew install ./cfacter.rb
#
# Documentation: https://github.com/Homebrew/homebrew/wiki/Formula-Cookbook
#                /usr/local/Library/Contributions/example-formula.rb


require "formula"

class Cfacter < Formula
  homepage "https://github.com/puppetlabs/cfacter"
  url "https://github.com/puppetlabs/cfacter/archive/0.2.0.tar.gz"
  version '0.2.0'
  sha1 "d0996773e3e6640c4e031509e6832cae8b74e774"

  head "git@github.com:puppetlabs/cfacter.git", :using => :git

  depends_on "cmake"
  depends_on "boost"
  depends_on "openssl"
  depends_on "yaml-cpp"

  def install
    system "cmake", ".", *std_cmake_args
    system "make", "install"
  end

end
