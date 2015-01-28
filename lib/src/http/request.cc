#include <facter/http/request.hpp>

using namespace std;

namespace facter { namespace http {

    request::request(string url) :
        _url(move(url)),
        _timeout(0),
        _connection_timeout(0)
    {
    }

    string const& request::url() const
    {
        return _url;
    }

    void request::add_header(string name, string value)
    {
        _headers.emplace(make_pair(move(name), move(value)));
    }

    void request::each_header(function<bool(string const&, string const&)> callback) const
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

    string* request::header(std::string const& name)
    {
        auto header = _headers.find(name);
        if (header == _headers.end()) {
            return nullptr;
        }
        return &header->second;
    }

    void request::remove_header(string const& name)
    {
        _headers.erase(name);
    }

    void request::add_cookie(string name, string value)
    {
        _cookies.emplace(make_pair(move(name), move(value)));
    }

    void request::each_cookie(function<bool(string const&, string const&)> callback) const
    {
        if (!callback) {
            return;
        }
        for (auto const& kvp : _cookies) {
            if (!callback(kvp.first, kvp.second)) {
                return;
            }
        }
    }

    string* request::cookie(std::string const& name)
    {
        auto cookie = _cookies.find(name);
        if (cookie == _cookies.end()) {
            return nullptr;
        }
        return &cookie->second;
    }

    void request::remove_cookie(string const& name)
    {
        _cookies.erase(name);
    }

    void request::body(string body, string content_type)
    {
        _body = move(body);
        add_header("Content-Type", move(content_type));
    }

    string const& request::body() const
    {
        return _body;
    }

    long request::timeout() const
    {
        return _timeout;
    }

    void request::timeout(long value)
    {
        _timeout = value < 0 ? 0 : value;
    }

    long request::connection_timeout() const
    {
        return _connection_timeout;
    }

    void request::connection_timeout(long value)
    {
        _connection_timeout = value < 0 ? 0 : value;
    }
}}
