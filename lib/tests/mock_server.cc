#include <cstdlib>
#include <iostream>
#include <utility>
#include "mock_server.hpp"

namespace facter {

static void session(tcp::socket sock) {
  try {
      for (;;) {
          char data[1024];

          boost::system::error_code error;
          sock.read_some(boost::asio::buffer(data), error);
          if (error == boost::asio::error::eof) {
              break;  // Connection closed cleanly by peer.
          } else if (error) {
              throw boost::system::system_error(error);  // Some other error.
          }

          std::string response = "HTTP/1.1 301 Moved Permanently\nContent-length: 0\nLocation: https://puppet.com/\nConnection: close\n\n";
          boost::asio::write(sock, boost::asio::buffer(response));
      }
  } catch (std::exception& e) {
    std::cerr << "Exception in thread: " << e.what() << "\n";
  }
}

mock_server::mock_server(int port) :
    acceptor_(io_service_, tcp::endpoint(tcp::v4(), port)),
    socket_(io_service_)
{
    acceptor_.async_accept(socket_, [this](boost::system::error_code ec) {
        if (!ec) session(std::move(socket_));
    });
    thread_ = boost::thread([this]() {io_service_.run_one();});
}

mock_server::~mock_server()
{
    thread_.join();
}

}  // namespace facter
