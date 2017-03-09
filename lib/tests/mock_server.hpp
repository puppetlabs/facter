#pragma once

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wunused-variable"
#pragma GCC diagnostic ignored "-Wstrict-aliasing"
#include <boost/asio.hpp>
#include <boost/thread.hpp>
#pragma GCC diagnostic pop

namespace facter {

    using boost::asio::ip::tcp;

    class mock_server {
    public:
        mock_server(int port);
        ~mock_server();
    private:
        boost::asio::io_service io_service_;
        tcp::acceptor acceptor_;
        tcp::socket socket_;
        boost::thread thread_;
    };

}  // namespace facter
