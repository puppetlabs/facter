/**
 * @file
 * Defines an abstraction for using regular expression calls.
 * It should be extended when new match methods are needed, and allows easily
 * switching between regex libraries.
 */
#ifndef FACTER_UTIL_REGEX_HPP_
#define FACTER_UTIL_REGEX_HPP_

#ifdef USE_RE2
#include <re2/re2.h>
#else
#include <boost/regex.hpp>
#include <boost/lexical_cast.hpp>
#endif

namespace facter { namespace util {
#ifdef USE_RE2
    using re_adapter = re2::RE2;

    template <typename... Args>
    inline bool re_search(const re2::StringPiece &txt, const re2::RE2 &r, Args&&... args)
    {
        return re2::RE2::PartialMatch(txt, r, std::forward<Args>(args)...);
    }
#else
    class re_adapter : public boost::regex {
        std::string _err;
     public:
        re_adapter(const char* pattern) try : boost::regex(pattern)
        {
        } catch (const boost::regex_error &e) {
            _err = e.what();
        }

        re_adapter(const std::string &pattern) try : boost::regex(pattern)
        {
        } catch (const boost::regex_error &e) {
            _err = e.what();
        }

        const std::string& error() const { return _err; }
        bool ok() const { return error().empty(); }
    };

    template <typename Text>
    inline bool re_search_helper(Text &txt, const boost::smatch &what, size_t depth)
    {
        return true;
    }

    template <typename Text, typename Arg, typename... Args>
    inline bool re_search_helper(Text &txt, const boost::smatch &what, size_t depth, Arg arg, Args&&... args)
    {
        if (depth >= what.size()) {
            return false;
        }

        try {
            using ArgType = typename std::pointer_traits<Arg>::element_type;
            auto val = boost::lexical_cast<ArgType>(what[depth]);
            *arg = val;
        } catch (const boost::bad_lexical_cast &e) {
            return false;
        }

        return re_search_helper(txt, what, depth+1, std::forward<Args>(args)...);
    }

    template <typename Text, typename... Args>
    inline bool re_search(Text &txt, const re_adapter &r, Args&&... args)
    {
        if (!r.ok()) {
            return false;
        }

        boost::smatch what;
        if (!boost::regex_search(txt, what, r)) {
            return false;
        }

        return re_search_helper(txt, what, 1, std::forward<Args>(args)...);
    }
#endif

}}  // namespace facter::util

#endif  // FACTER_UTIL_REGEX_HPP_

