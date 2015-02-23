#include <facter/http/client.hpp>
#include <facter/http/request.hpp>
#include <facter/http/response.hpp>
#include <leatherman/logging/logging.hpp>
#include <facter/util/regex.hpp>
#include <boost/utility/string_ref.hpp>
#include <boost/algorithm/string.hpp>
#include <sstream>

using namespace std;
using namespace facter::util;

namespace facter { namespace http {

    // Helper for globally initializing curl
    struct curl_init_helper
    {
        curl_init_helper()
        {
            _result = curl_global_init(CURL_GLOBAL_DEFAULT);
        }

        ~curl_init_helper()
        {
            if (_result == CURLE_OK) {
                curl_global_cleanup();
            }
        }

        CURLcode result() const
        {
            return _result;
        }

     private:
        CURLcode _result;
    };

    curl_handle::curl_handle() :
        scoped_resource(nullptr, cleanup)
    {
        // Perform initialization
        static curl_init_helper init_helper;
        if (init_helper.result() != CURLE_OK) {
            throw http_exception(curl_easy_strerror(init_helper.result()));
        }

        _resource = curl_easy_init();
    }

    void curl_handle::cleanup(CURL* curl)
    {
        if (curl) {
            curl_easy_cleanup(curl);
        }
    }

    curl_list::curl_list() :
        scoped_resource(nullptr, cleanup)
    {
    }

    void curl_list::append(string const& value)
    {
        _resource = curl_slist_append(_resource, value.c_str());
    }

    void curl_list::cleanup(curl_slist* list)
    {
        if (list) {
            curl_slist_free_all(list);
        }
    }

    curl_escaped_string::curl_escaped_string(curl_handle const& handle, string const& str) :
        scoped_resource(nullptr, cleanup)
    {
        _resource = curl_easy_escape(handle, str.c_str(), str.size());
        if (!_resource) {
            throw http_exception("curl_easy_escape failed to escape string.");
        }
    }

    void curl_escaped_string::cleanup(char const* str)
    {
        if (str) {
            curl_free(const_cast<char*>(str));
        }
    }

    client::client()
    {
        if (!_handle) {
            throw http_exception("failed to create cURL handle.");
        }
    }

    client::client(client&& other)
    {
        *this = std::move(other);
    }

    client& client::operator=(client&& other)
    {
        _handle = move(other._handle);
        return *this;
    }

    response client::get(request const& req)
    {
        return perform(http_method::get, req);
    }

    response client::post(request const& req)
    {
        return perform(http_method::post, req);
    }

    response client::put(request const& req)
    {
        return perform(http_method::put, req);
    }

    response client::perform(http_method method, request const& req)
    {
        response res;
        context ctx(req, res);

        // Reset the options
        curl_easy_reset(_handle);

        // Set common options
        auto result = curl_easy_setopt(_handle, CURLOPT_NOPROGRESS, 1);
        if (result != CURLE_OK) {
            throw http_request_exception(req, curl_easy_strerror(result));
        }
        result = curl_easy_setopt(_handle, CURLOPT_FOLLOWLOCATION, 1);
        if (result != CURLE_OK) {
            throw http_request_exception(req, curl_easy_strerror(result));
        }

        // Set tracing from libcurl if enabled (we don't care if this fails)
        if (LOG_IS_DEBUG_ENABLED()) {
            curl_easy_setopt(_handle, CURLOPT_DEBUGFUNCTION, debug);
            curl_easy_setopt(_handle, CURLOPT_VERBOSE, 1);
        }

        // Setup the request
        set_method(ctx, method);
        set_url(ctx);
        set_headers(ctx);
        set_cookies(ctx);
        set_body(ctx);
        set_timeouts(ctx);
        set_write_callbacks(ctx);

        // Perform the request
        result = curl_easy_perform(_handle);
        if (result != CURLE_OK) {
            throw http_request_exception(req, curl_easy_strerror(result));
        }

        LOG_DEBUG("request completed (status %1%).", res.status_code());

        // Set the body of the response
        res.body(move(ctx.response_buffer));
        return res;
    }

    void client::set_method(context& ctx, http_method method)
    {
        switch (method) {
            case http_method::get:
                // Unnecessary since we're resetting the handle before calling this function
                return;

            case http_method::post: {
                auto result = curl_easy_setopt(_handle, CURLOPT_POST, 1);
                if (result != CURLE_OK) {
                    throw http_request_exception(ctx.req, curl_easy_strerror(result));
                }
                break;
            }

            case http_method::put: {
                auto result = curl_easy_setopt(_handle, CURLOPT_PUT, 1);
                if (result != CURLE_OK) {
                    throw http_request_exception(ctx.req, curl_easy_strerror(result));
                }
                break;
            }

            default:
                throw http_request_exception(ctx.req, "unexpected HTTP method specified.");
        }
    }

    void client::set_url(context& ctx)
    {
        // TODO: support an easy interface for setting escaped query parameters
        auto result = curl_easy_setopt(_handle, CURLOPT_URL, ctx.req.url().c_str());
        if (result != CURLE_OK) {
            throw http_request_exception(ctx.req, curl_easy_strerror(result));
        }

        LOG_DEBUG("requesting %1%.", ctx.req.url());
    }

    void client::set_headers(context& ctx)
    {
        ctx.req.each_header([&](string const& name, string const& value) {
            ctx.request_headers.append(name + ": " + value);
            return true;
        });
        auto result = curl_easy_setopt(_handle, CURLOPT_HTTPHEADER, static_cast<curl_slist*>(ctx.request_headers));
        if (result != CURLE_OK) {
            throw http_request_exception(ctx.req, curl_easy_strerror(result));
        }
    }

    void client::set_cookies(context& ctx)
    {
        ostringstream cookies;
        ctx.req.each_cookie([&](string const& name, string const& value) {
            if (cookies.tellp() != 0) {
                cookies << "; ";
            }
            cookies << name << "=" << value;
            return true;
        });
        auto result = curl_easy_setopt(_handle, CURLOPT_COOKIE, cookies.str().c_str());
        if (result != CURLE_OK) {
            throw http_request_exception(ctx.req, curl_easy_strerror(result));
        }
    }

    void client::set_body(context& ctx)
    {
        auto result = curl_easy_setopt(_handle, CURLOPT_READFUNCTION, read_body);
        if (result != CURLE_OK) {
            throw http_request_exception(ctx.req, curl_easy_strerror(result));
        }
        result = curl_easy_setopt(_handle, CURLOPT_READDATA, &ctx);
        if (result != CURLE_OK) {
            throw http_request_exception(ctx.req, curl_easy_strerror(result));
        }
    }

    void client::set_timeouts(context& ctx)
    {
        auto result = curl_easy_setopt(_handle, CURLOPT_CONNECTTIMEOUT_MS, ctx.req.connection_timeout());
        if (result != CURLE_OK) {
            throw http_request_exception(ctx.req, curl_easy_strerror(result));
        }
        result = curl_easy_setopt(_handle, CURLOPT_TIMEOUT_MS, ctx.req.timeout());
        if (result != CURLE_OK) {
            throw http_request_exception(ctx.req, curl_easy_strerror(result));
        }
    }

    void client::set_write_callbacks(context& ctx)
    {
        auto result = curl_easy_setopt(_handle, CURLOPT_HEADERFUNCTION, write_header);
        if (result != CURLE_OK) {
            throw http_request_exception(ctx.req, curl_easy_strerror(result));
        }
        result = curl_easy_setopt(_handle, CURLOPT_HEADERDATA, &ctx);
        if (result != CURLE_OK) {
            throw http_request_exception(ctx.req, curl_easy_strerror(result));
        }
        result = curl_easy_setopt(_handle, CURLOPT_WRITEFUNCTION, write_body);
        if (result != CURLE_OK) {
            throw http_request_exception(ctx.req, curl_easy_strerror(result));
        }
        result = curl_easy_setopt(_handle, CURLOPT_WRITEDATA, &ctx);
        if (result != CURLE_OK) {
            throw http_request_exception(ctx.req, curl_easy_strerror(result));
        }
    }

    size_t client::read_body(char* buffer, size_t size, size_t count, void* ptr)
    {
        auto ctx = reinterpret_cast<context*>(ptr);
        size_t requested = size * count;

        auto const& body = ctx->req.body();

        if (requested > (body.size() - ctx->read_offset)) {
            requested = (body.size() - ctx->read_offset);
        }
        if (requested > 0) {
            memcpy(buffer, body.c_str() + ctx->read_offset, requested);
            ctx->read_offset += requested;
        }
        return requested;
    }

    size_t client::write_header(char* buffer, size_t size, size_t count, void* ptr)
    {
        size_t written = size * count;
        boost::string_ref input(buffer, written);

        auto ctx = reinterpret_cast<context*>(ptr);

        // If the header starts with "HTTP/", then we have the response status
        if (input.starts_with("HTTP/")) {
            // Reset the response buffer
            ctx->response_buffer.clear();

            // Parse out the error code
            re_adapter regex("HTTP/\\d\\.\\d (\\d\\d\\d).*");
            int status_code = 0;
            if (re_search(input.to_string(), regex, &status_code)) {
                ctx->res.status_code(status_code);
            }
            return written;
        } else if (input == "\r\n") {
            // Ignore the response delimiter
            return written;
        }

        auto pos = input.find_first_of(':');
        if (pos == boost::string_ref::npos) {
            LOG_WARNING("unexpected HTTP response header: %1%.", input);
            return written;
        }

        auto name = input.substr(0, pos).to_string();
        auto value = input.substr(pos + 1).to_string();
        boost::trim(name);
        boost::trim(value);

        // If this is the "Content-Length" header, reserve the response buffer as an optimization
        if (name == "Content-Length") {
            try {
                ctx->response_buffer.reserve(stoi(value));
            } catch (logic_error&) {
            }
        }

        ctx->res.add_header(move(name), move(value));
        return written;
    }

    size_t client::write_body(char* buffer, size_t size, size_t count, void* ptr)
    {
        size_t written = size * count;

        auto ctx = reinterpret_cast<context*>(ptr);
        if (written > 0) {
            ctx->response_buffer.append(buffer, written);
        }

        return written;
    }

    int client::debug(CURL* handle, curl_infotype type, char* data, size_t size, void* ptr)
    {
        if (type > CURLINFO_DATA_OUT) {
            return 0;
        }
        string str(data, size);
        boost::trim(str);
        if (str.empty()) {
            return 0;
        }

        // Only log cURL's text to debug
        if (type == CURLINFO_TEXT) {
            LOG_DEBUG(str);
            return 0;
        } else if (!LOG_IS_TRACE_ENABLED()) {
            return 0;
        }

        ostringstream header;
        if (type == CURLINFO_HEADER_IN) {
            header << "[response headers: " << size << " bytes]\n";
        } else if (type == CURLINFO_HEADER_OUT) {
            header << "[request headers: " << size << " bytes]\n";
        } else if (type == CURLINFO_DATA_IN) {
            header << "[response body: " << size << " bytes]\n";
        } else if (type == CURLINFO_DATA_OUT) {
            header << "[request body: " << size << " bytes]\n";
        }
        LOG_TRACE("%1%%2%", header.str(), str);
        return 0;
    }
}}
