#include <facter/util/aws_token.hpp>
#include <leatherman/logging/logging.hpp>

#ifdef USE_CURL
#include <leatherman/curl/client.hpp>
namespace lth_curl = leatherman::curl;

using namespace std;

namespace facter { namespace util {

    string get_token(string const& url, lth_curl::client& cli, int const& lifetime){
        lth_curl::request req(url);
        req.add_header("X-aws-ec2-metadata-token-ttl-seconds", to_string(lifetime));
        auto response = cli.put(req);

        if (response.status_code() != 200){
            LOG_DEBUG("request for {1} returned a status code of {2}.", req.url(), response.status_code());
            return "";
        }

        return response.body();
    }
}}
#endif  // USE_CURL
