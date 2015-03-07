/**
* @file
* Declares the HTTP request.
*/
#pragma once

#include "../export.h"
#include <string>
#include <map>
#include <functional>

namespace facter { namespace http {

    /**
     * Implements the HTTP request.
     */
    struct LIBFACTER_EXPORT request
    {
        /**
         * Constructs a HTTP request.
         * @param url The URL for the request.
         */
        explicit request(std::string url);

        /**
         * Gets the URL for the request.
         * @return Returns the URL for the request.
         */
        std::string const& url() const;

        /**
         * Adds a header to the request.
         * @param name The header name.
         * @param value The header value.
         */
        void add_header(std::string name, std::string value);

        /**
         * Enumerates each header in the request.
         * @param callback The function to call for each header in the request.
         */
        void each_header(std::function<bool(std::string const&, std::string const&)> callback) const;

        /**
         * Gets a header by name.
         * @param name The header name to get.
         * @return Returns a pointer to the header's value or nullptr if the header is not present.
         */
        std::string* header(std::string const& name);

        /**
         * Removes a header from the request.
         * @param name The name of the header to remove.
         */
        void remove_header(std::string const& name);

        /**
         * Adds a cookie to the request.
         * @param name The cookie name.
         * @param value The cookie value.
         */
        void add_cookie(std::string name, std::string value);

        /**
         * Enumerates each cookie in the request.
         * @param callback The function to call for each cookie in the request.
         */
        void each_cookie(std::function<bool(std::string const&, std::string const&)> callback) const;

        /**
         * Gets a cookie by name.
         * @param name The cookie name to get.
         * @return Returns a pointer to the cookie's value or nullptr if the cookie is not present.
         */
        std::string* cookie(std::string const& name);

        /**
         * Removes a cookie from the request.
         * @param name The name of the cookie to remove.
         */
        void remove_cookie(std::string const& name);

        /**
         * Sets the body of the request.
         * @param body The body of the request.
         * @param content_type The type of content (sets the Content-Type header).
         */
        void body(std::string body, std::string content_type);

        /**
         * Gets the body of the request.
         * The type of the content is represented by the Content-Type header.
         * @return Returns the body of the request.
         */
        std::string const& body() const;

        /**
         * Gets the overall request timeout, in milliseconds.
         * @return Returns the overall request timeout, in milliseconds.
         */
        long timeout() const;

        /**
         * Sets the overall request timeout, in milliseconds.
         * @param value The timeout value, in milliseconds.
         */
        void timeout(long value);

        /**
         * Gets the timeout for connecting to the remote host, in milliseconds.
         * @return Returns the connection timeout, in milliseconds.
         */
        long connection_timeout() const;

        /**
         * Sets the timeout for connecting to the remote host, in milliseconds.
         * @param value The timeout value, in milliseconds.
         */
        void connection_timeout(long value);

     private:
        std::string _url;
        std::string _body;
        long _timeout;
        long _connection_timeout;
        std::map<std::string, std::string> _headers;
        std::map<std::string, std::string> _cookies;
    };

}}  // namespace facter::http
