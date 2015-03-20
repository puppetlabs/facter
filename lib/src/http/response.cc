#include <facter/http/response.hpp>

using namespace std;

namespace facter { namespace http {

    response::response() :
        _status_code(0)
    {
    }

    void response::add_header(string name, string value)
    {
        _headers.emplace(make_pair(move(name), move(value)));
    }

    void response::each_header(function<bool(string const&, string const&)> callback) const
    {
        if (!callback) {
            return;
        }
        for (auto const& kvp : _headers) {
            if (!callback(kvp.first, kvp.second)) {
                return;
            }
        }
    }

    string* response::header(std::string const& name)
    {
        auto header = _headers.find(name);
        if (header == _headers.end()) {
            return nullptr;
        }
        return &header->second;
    }

    void response::remove_header(string const& name)
    {
        _headers.erase(name);
    }

    void response::body(string body)
    {
        _body = move(body);
    }

    string const& response::body() const
    {
        return _body;
    }

    int response::status_code() const
    {
        return _status_code;
    }

    void response::status_code(int status)
    {
        _status_code = status;
    }
}}
