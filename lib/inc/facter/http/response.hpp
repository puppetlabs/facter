/**
* @file
* Declares the HTTP response.
*/
#pragma once

#include <string>
#include <functional>

namespace facter { namespace http {

    /**
     * Implements the HTTP response.
     */
    struct response
    {
        response();

        /**
         * Moves the given response into this response.
         * @param other The response to move into this response.
         */
        response(response&& other);

        /**
         * Moves the given response into this response.
         * @param other The response to move into this response.
         * @return Returns this response.
         */
        response& operator=(response&& other);

        /**
         * Adds a header to the response.
         * @param name The header name.
         * @param value The header value.
         */
        void add_header(std::string name, std::string value);

        /**
         * Enumerates each header in the response.
         * @param callback The function to call for each header in the response.
         */
        void each_header(std::function<bool(std::string const&, std::string const&)> callback) const;

        /**
         * Gets a header by name.
         * @param name The header name to get.
         * @return Returns a pointer to the header's value or nullptr if the header is not present.
         */
        std::string* header(std::string const& name);

        /**
         * Removes a header from the response.
         * @param name The name of the header to remove.
         */
        void remove_header(std::string const& name);

        /**
         * Sets the body of the response.
         * @param body The body of the response.
         */
        void body(std::string body);

        /**
         * Gets the body of the response.
         * @return Returns the body of the response.
         */
        std::string const& body() const;

        /**
         * Sets the status code of the response.
         * @param code The status code of the response.
         */
        void status_code(int code);

        /**
         * Gets the status code of the response.
         * @return Returns the status code of the response.
         */
        int status_code() const;

     private:
        response(response const&) = delete;
        response& operator=(response const&) = delete;

        int _status_code;
        std::string _body;
        std::map<std::string, std::string> _headers;
    };

}}  // namespace facter::http
