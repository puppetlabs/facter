#include <internal/ruby/module.hpp>
#include <internal/ruby/api.hpp>
#include <internal/ruby/aggregate_resolution.hpp>
#include <internal/ruby/confine.hpp>
#include <internal/ruby/simple_resolution.hpp>
#include <facter/facts/collection.hpp>
#include <facter/util/directory.hpp>
#include <facter/execution/execution.hpp>
#include <facter/version.h>
#include <facter/export.h>
#include <leatherman/logging/logging.hpp>
#include <boost/filesystem.hpp>
#include <boost/algorithm/string.hpp>
#include <boost/nowide/iostream.hpp>
#include <boost/nowide/convert.hpp>
#include <stdexcept>
#include <functional>

using namespace std;
using namespace facter::facts;
using namespace facter::util;
using namespace facter::execution;
using namespace boost::filesystem;

using namespace leatherman::logging;

namespace facter { namespace ruby {

    /**
     * Helper for maintaining context when initialized via a Ruby require.
     */
    struct require_context
    {
        /**
         * Constructs a new require context.
         */
        require_context()
        {
            // Create a collection and a facter module
            _facts.reset(new collection());
            _module.reset(new module(*_facts));

            // Ruby doesn't have a proper way of notifying extensions that the VM is shutting down
            // The easiest way to get notified is to have a global data object that never gets collected
            // until the VM shuts down
            auto const& ruby = *api::instance();
            _canary = ruby.rb_data_object_alloc(*ruby.rb_cObject, this, nullptr, cleanup);
            ruby.rb_gc_register_address(&_canary);
            ruby.register_data_object(_canary);
        }

        /**
         * Destructs the require context.
         */
        ~require_context()
        {
            _module.reset();
            _facts.reset();

            // Remove the finalizer and let Ruby collect the object
            auto const& ruby = *api::instance();
            ruby.rb_gc_unregister_address(&_canary);
            ruby.unregister_data_object(_canary);
        }

        /**
         * Creates the require context.
         */
        static void create()
        {
            // Reset first before allocating a new context
            reset();

            _instance.reset(new require_context());
        }

        /**
         * Resets the require context.
         */
        static void reset()
        {
           _instance.reset();
        }

     private:
        static void cleanup(void* ptr)
        {
            if (ptr == _instance.get()) {
                reset();
            }
        }

        unique_ptr<collection> _facts;
        unique_ptr<module> _module;
        VALUE _canary;

        static unique_ptr<require_context> _instance;
    };

    unique_ptr<require_context> require_context::_instance;
}}

// Exports for a Ruby extension.
extern "C" {
    /**
     * Called by the Ruby VM when native facter is required.
     */
    void LIBFACTER_EXPORT Init_libfacter()
    {
        setup_logging(boost::nowide::cerr);
        set_level(log_level::warning);

        // Initialize ruby
        auto ruby = facter::ruby::api::instance();
        if (!ruby) {
            return;
        }
        ruby->initialize();

        // Create the context
        facter::ruby::require_context::create();
    }
}

namespace facter { namespace ruby {

    map<VALUE, module*> module::_instances;

    module::module(collection& facts, vector<string> const& paths) :
        _collection(facts),
        _loaded_all(false)
    {
        if (!api::instance()) {
            throw runtime_error("Ruby API is not present.");
        }
        auto const& ruby = *api::instance();
        if (!ruby.initialized()) {
            throw runtime_error("Ruby API is not initialized.");
        }

        // Initialize the search paths
        initialize_search_paths(paths);

        // Register the block for logging callback with the GC
        _on_message_block = ruby.nil_value();
        ruby.rb_gc_register_address(&_on_message_block);

        // Install a logging message handler
        on_message([this](log_level level, string const& message) {
            auto const& ruby = *api::instance();
            if (ruby.is_nil(_on_message_block)) {
                return true;
            }

            // Call the block and don't log messages
            ruby.rescue([&]() {
                ruby.rb_funcall(_on_message_block, ruby.rb_intern("call"), 2, level_to_symbol(level), ruby.utf8_value(message));
                return ruby.nil_value();
            }, [&](VALUE) {
                // Logging can take place from locations where we do not expect Ruby exceptions to be raised
                // Therefore, intentionally swallow any exceptions.
                return ruby.nil_value();
            });
            return false;
        });

        // Define the Facter module
        _self = ruby.rb_define_module("Facter");
        _instances[_self] = this;

        VALUE core = ruby.rb_define_module_under(_self, "Core");
        VALUE execution = ruby.rb_define_module_under(core, "Execution");
        ruby.rb_define_module_under(_self, "Util");

        // Define the methods on the Facter module
        volatile VALUE version = ruby.utf8_value(LIBFACTER_VERSION);
        ruby.rb_const_set(_self, ruby.rb_intern("FACTERVERSION"), version);
        ruby.rb_define_singleton_method(_self, "version", RUBY_METHOD_FUNC(ruby_version), 0);
        ruby.rb_define_singleton_method(_self, "add", RUBY_METHOD_FUNC(ruby_add), -1);
        ruby.rb_define_singleton_method(_self, "define_fact", RUBY_METHOD_FUNC(ruby_define_fact), -1);
        ruby.rb_define_singleton_method(_self, "value", RUBY_METHOD_FUNC(ruby_value), 1);
        ruby.rb_define_singleton_method(_self, "[]", RUBY_METHOD_FUNC(ruby_fact), 1);
        ruby.rb_define_singleton_method(_self, "fact", RUBY_METHOD_FUNC(ruby_fact), 1);
        ruby.rb_define_singleton_method(_self, "debug", RUBY_METHOD_FUNC(ruby_debug), 1);
        ruby.rb_define_singleton_method(_self, "debugonce", RUBY_METHOD_FUNC(ruby_debugonce), 1);
        ruby.rb_define_singleton_method(_self, "warn", RUBY_METHOD_FUNC(ruby_warn), 1);
        ruby.rb_define_singleton_method(_self, "warnonce", RUBY_METHOD_FUNC(ruby_warnonce), 1);
        ruby.rb_define_singleton_method(_self, "log_exception", RUBY_METHOD_FUNC(ruby_log_exception), -1);
        ruby.rb_define_singleton_method(_self, "debugging", RUBY_METHOD_FUNC(ruby_set_debugging), 1);
        ruby.rb_define_singleton_method(_self, "debugging?", RUBY_METHOD_FUNC(ruby_get_debugging), 0);
        ruby.rb_define_singleton_method(_self, "trace", RUBY_METHOD_FUNC(ruby_set_trace), 1);
        ruby.rb_define_singleton_method(_self, "trace?", RUBY_METHOD_FUNC(ruby_get_trace), 0);
        ruby.rb_define_singleton_method(_self, "flush", RUBY_METHOD_FUNC(ruby_flush), 0);
        ruby.rb_define_singleton_method(_self, "list", RUBY_METHOD_FUNC(ruby_list), 0);
        ruby.rb_define_singleton_method(_self, "to_hash", RUBY_METHOD_FUNC(ruby_to_hash), 0);
        ruby.rb_define_singleton_method(_self, "each", RUBY_METHOD_FUNC(ruby_each), 0);
        ruby.rb_define_singleton_method(_self, "clear", RUBY_METHOD_FUNC(ruby_clear), 0);
        ruby.rb_define_singleton_method(_self, "reset", RUBY_METHOD_FUNC(ruby_reset), 0);
        ruby.rb_define_singleton_method(_self, "loadfacts", RUBY_METHOD_FUNC(ruby_loadfacts), 0);
        ruby.rb_define_singleton_method(_self, "search", RUBY_METHOD_FUNC(ruby_search), -1);
        ruby.rb_define_singleton_method(_self, "search_path", RUBY_METHOD_FUNC(ruby_search_path), 0);
        ruby.rb_define_singleton_method(_self, "search_external", RUBY_METHOD_FUNC(ruby_search_external), 1);
        ruby.rb_define_singleton_method(_self, "search_external_path", RUBY_METHOD_FUNC(ruby_search_external_path), 0);
        ruby.rb_define_singleton_method(_self, "on_message", RUBY_METHOD_FUNC(ruby_on_message), 0);

        // Define the execution module
        ruby.rb_define_singleton_method(execution, "which", RUBY_METHOD_FUNC(ruby_which), 1);
        ruby.rb_define_singleton_method(execution, "exec", RUBY_METHOD_FUNC(ruby_exec), 1);
        ruby.rb_define_singleton_method(execution, "execute", RUBY_METHOD_FUNC(ruby_execute), -1);
        ruby.rb_define_class_under(execution, "ExecutionFailure", *ruby.rb_eStandardError);

        // Define the Fact and resolution classes
        fact::define();
        simple_resolution::define();
        aggregate_resolution::define();

        // Custom facts may `require 'facter'`
        // To allow those custom facts to still function, add facter.rb to loaded features using the first directory in the load path
        // Note: use forward slashes in the path even on Windows because that's what Ruby expects in $LOADED_FEATURES
        volatile VALUE first = ruby.rb_ary_entry(ruby.rb_gv_get("$LOAD_PATH"), 0);
        if (!ruby.is_nil(first)) {
            ruby.rb_ary_push(ruby.rb_gv_get("$LOADED_FEATURES"), ruby.utf8_value(ruby.to_string(first) + "/facter.rb"));
        }
    }

    module::~module()
    {
        _instances.erase(_self);

        clear_facts(false);

        auto ruby = api::instance();
        if (!ruby) {
            // Ruby has been uninitialized
            return;
        }

        // Unregister the on message block
        ruby->rb_gc_unregister_address(&_on_message_block);
        on_message(nullptr);

        // Undefine the module
        ruby->rb_const_remove(*ruby->rb_cObject, ruby->rb_intern("Facter"));
    }

    void module::load_facts()
    {
        if (_loaded_all) {
            return;
        }

        LOG_DEBUG("loading all custom facts.");

        for (auto const& directory : _search_paths) {
            LOG_DEBUG("searching for custom facts in %1%.", directory);
            directory::each_file(directory, [&](string const& file) {
                load_file(file);
                return true;
            }, "\\.rb$");
        }

        _loaded_all = true;
    }

    void module::resolve_facts()
    {
        // Before we do anything, call facts to ensure the collection is populated
        facts();

        load_facts();

        auto const& ruby = *api::instance();

        // Get the value from all facts
        for (auto const& kvp : _facts) {
            ruby.to_native<fact>(kvp.second)->value();
        }
    }

    void module::clear_facts(bool clear_collection)
    {
        auto ruby = api::instance();

        // Unregister all the facts
        if (ruby) {
            for (auto& kvp : _facts) {
                ruby->rb_gc_unregister_address(&kvp.second);
            }
        }

        // Clear the custom facts
        _facts.clear();

        // Clear the collection
        if (clear_collection) {
            _collection.clear();
        }
    }

    VALUE module::fact_value(VALUE name)
    {
        auto const& ruby = *api::instance();

        VALUE fact_self = load_fact(name);
        if (ruby.is_nil(fact_self)) {
            return ruby.nil_value();
        }

        return ruby.to_native<fact>(fact_self)->value();
    }

    VALUE module::normalize(VALUE name) const
    {
        auto const& ruby = *api::instance();

        if (ruby.is_symbol(name)) {
            name = ruby.rb_sym_to_s(name);
        }
        if (ruby.is_string(name)) {
            name = ruby.rb_funcall(name, ruby.rb_intern("downcase"), 0);
        }
        return name;
    }

    collection& module::facts()
    {
        if (_collection.empty()) {
            bool include_ruby_facts = true;
            _collection.add_default_facts(include_ruby_facts);
            _collection.add_external_facts(_external_search_paths);

            auto const& ruby = *api::instance();
            _collection.add_environment_facts([&](string const& name) {
                // Create a fact and explicitly set the value
                // We honor environment variables above custom fact resolutions
                ruby.to_native<fact>(create_fact(ruby.utf8_value(name)))->value(ruby.to_ruby(_collection[name]));
            });
        }
        return _collection;
    }

    VALUE module::self() const
    {
        return _self;
    }

    module* module::current()
    {
        auto const& ruby = *api::instance();
        return from_self(ruby.lookup({"Facter"}));
    }

    VALUE module::ruby_version(VALUE self)
    {
        auto const& ruby = *api::instance();
        return ruby.lookup({ "Facter", "FACTERVERSION" });
    }

    VALUE module::ruby_add(int argc, VALUE* argv, VALUE self)
    {
        auto const& ruby = *api::instance();

        if (argc == 0 || argc > 2) {
            ruby.rb_raise(*ruby.rb_eArgError, "wrong number of arguments (%d for 2)", argc);
        }

        VALUE fact_self = from_self(self)->create_fact(argv[0]);

        // Read the resolution name from the options hash, if present
        volatile VALUE name = ruby.nil_value();
        VALUE options = argc == 2 ? argv[1] : ruby.nil_value();
        if (!ruby.is_nil(options)) {
            name = ruby.rb_funcall(options, ruby.rb_intern("delete"), 1, ruby.to_symbol("name"));
        }

        ruby.to_native<fact>(fact_self)->define_resolution(name, options);
        return fact_self;
    }

    VALUE module::ruby_define_fact(int argc, VALUE* argv, VALUE self)
    {
        auto const& ruby = *api::instance();

        if (argc == 0 || argc > 2) {
            ruby.rb_raise(*ruby.rb_eArgError, "wrong number of arguments (%d for 2)", argc);
        }

        VALUE fact_self = from_self(self)->create_fact(argv[0]);

        // Call the block if one was given
        if (ruby.rb_block_given_p()) {
            ruby.rb_funcall_passing_block(fact_self, ruby.rb_intern("instance_eval"), 0, nullptr);
        }
        return fact_self;
    }

    VALUE module::ruby_value(VALUE self, VALUE name)
    {
        return from_self(self)->fact_value(name);
    }

    VALUE module::ruby_fact(VALUE self, VALUE name)
    {
        return from_self(self)->load_fact(name);
    }

    VALUE module::ruby_debug(VALUE self, VALUE message)
    {
        auto const& ruby = *api::instance();
        LOG_DEBUG(ruby.to_string(message));
        return ruby.nil_value();
    }

    VALUE module::ruby_debugonce(VALUE self, VALUE message)
    {
        auto const& ruby = *api::instance();

        string msg = ruby.to_string(message);
        if (from_self(self)->_debug_messages.insert(msg).second) {
            LOG_DEBUG(msg);
        }
        return ruby.nil_value();
    }

    VALUE module::ruby_warn(VALUE self, VALUE message)
    {
        auto const& ruby = *api::instance();
        LOG_WARNING(ruby.to_string(message));
        return ruby.nil_value();
    }

    VALUE module::ruby_warnonce(VALUE self, VALUE message)
    {
        auto const& ruby = *api::instance();

        string msg = ruby.to_string(message);
        if (from_self(self)->_warning_messages.insert(msg).second) {
            LOG_WARNING(msg);
        }
        return ruby.nil_value();
    }

    VALUE module::ruby_set_debugging(VALUE self, VALUE value)
    {
        auto const& ruby = *api::instance();

        if (ruby.is_true(value)) {
            set_level(log_level::debug);
        } else {
            set_level(log_level::warning);
        }
        return ruby_get_debugging(self);
    }

    VALUE module::ruby_get_debugging(VALUE self)
    {
        auto const& ruby = *api::instance();
        return is_enabled(log_level::debug) ? ruby.true_value() : ruby.false_value();
    }

    VALUE module::ruby_set_trace(VALUE self, VALUE value)
    {
        auto& ruby = *api::instance();
        ruby.include_stack_trace(ruby.is_true(value));
        return ruby_get_trace(self);
    }

    VALUE module::ruby_get_trace(VALUE self)
    {
        auto const& ruby = *api::instance();
        return ruby.include_stack_trace() ? ruby.true_value() : ruby.false_value();
    }

    VALUE module::ruby_log_exception(int argc, VALUE* argv, VALUE self)
    {
        auto const& ruby = *api::instance();

        if (argc == 0 || argc > 2) {
            ruby.rb_raise(*ruby.rb_eArgError, "wrong number of arguments (%d for 2)", argc);
        }

        string message;
        if (argc == 2) {
            // Use the given argument provided it is not a symbol equal to :default
            if (!ruby.is_symbol(argv[1]) || ruby.rb_to_id(argv[1]) != ruby.rb_intern("default")) {
                message = ruby.to_string(argv[1]);
            }
        }

        LOG_ERROR(ruby.exception_to_string(argv[0], message));
        return ruby.nil_value();
    }

    VALUE module::ruby_flush(VALUE self)
    {
        auto const& ruby = *api::instance();

        for (auto& kvp : from_self(self)->_facts)
        {
            ruby.to_native<fact>(kvp.second)->flush();
        }
        return ruby.nil_value();
    }

    VALUE module::ruby_list(VALUE self)
    {
        auto const& ruby = *api::instance();
        module* instance = from_self(self);

        instance->resolve_facts();

        volatile VALUE array = ruby.rb_ary_new_capa(instance->facts().size());

        instance->facts().each([&](string const& name, value const*) {
            ruby.rb_ary_push(array, ruby.utf8_value(name));
            return true;
        });
        return array;
    }

    VALUE module::ruby_to_hash(VALUE self)
    {
        auto const& ruby = *api::instance();
        module* instance = from_self(self);

        instance->resolve_facts();

        volatile VALUE hash = ruby.rb_hash_new();

        instance->facts().each([&](string const& name, value const* val) {
            ruby.rb_hash_aset(hash, ruby.utf8_value(name), ruby.to_ruby(val));
            return true;
        });
        return hash;
    }

    VALUE module::ruby_each(VALUE self)
    {
        auto const& ruby = *api::instance();
        module* instance = from_self(self);

        instance->resolve_facts();

        instance->facts().each([&](string const& name, value const* val) {
            ruby.rb_yield_values(2, ruby.utf8_value(name), ruby.to_ruby(val));
            return true;
        });
        return self;
    }

    VALUE module::ruby_clear(VALUE self)
    {
        auto const& ruby = *api::instance();

        ruby_flush(self);
        ruby_reset(self);

        return ruby.nil_value();
    }

    VALUE module::ruby_reset(VALUE self)
    {
        auto const& ruby = *api::instance();
        module* instance = from_self(self);

        instance->clear_facts();
        instance->initialize_search_paths({});
        instance->_external_search_paths.clear();
        instance->_loaded_all = false;
        instance->_loaded_files.clear();

        return ruby.nil_value();
    }

    VALUE module::ruby_loadfacts(VALUE self)
    {
        auto const& ruby = *api::instance();

        from_self(self)->load_facts();
        return ruby.nil_value();
    }

    VALUE module::ruby_search(int argc, VALUE* argv, VALUE self)
    {
        auto const& ruby = *api::instance();
        module* instance = from_self(self);

        for (int i = 0; i < argc; ++i) {
            if (!ruby.is_string(argv[i])) {
                continue;
            }
            instance->_additional_search_paths.emplace_back(ruby.to_string(argv[i]));

            // Get the canonical directory name
            boost::system::error_code ec;
            path directory = canonical(instance->_additional_search_paths.back(), ec);
            if (ec) {
                continue;
            }

            instance->_search_paths.push_back(directory.string());
        }
        return ruby.nil_value();
    }

    VALUE module::ruby_search_path(VALUE self)
    {
        auto const& ruby = *api::instance();
        module* instance = from_self(self);

        volatile VALUE array = ruby.rb_ary_new_capa(instance->_additional_search_paths.size());

        for (auto const& path : instance->_additional_search_paths) {
            ruby.rb_ary_push(array, ruby.utf8_value(path));
        }
        return array;
    }

    VALUE module::ruby_search_external(VALUE self, VALUE paths)
    {
        auto const& ruby = *api::instance();
        module* instance = from_self(self);

        ruby.array_for_each(paths, [&](VALUE element) {
            if (!ruby.is_string(element)) {
                return true;
            }
            instance->_external_search_paths.emplace_back(ruby.to_string(element));
            return true;
        });
        return ruby.nil_value();
    }

    VALUE module::ruby_search_external_path(VALUE self)
    {
        auto const& ruby = *api::instance();
        module* instance = from_self(self);

        volatile VALUE array = ruby.rb_ary_new_capa(instance->_external_search_paths.size());

        for (auto const& path : instance->_external_search_paths) {
            ruby.rb_ary_push(array, ruby.utf8_value(path));
        }
        return array;
    }

    VALUE module::ruby_which(VALUE self, VALUE binary)
    {
        // Note: self is Facter::Core::Execution
        auto const& ruby = *api::instance();

        string path = execution::which(ruby.to_string(binary));
        if (path.empty()) {
            return ruby.nil_value();
        }

        return ruby.utf8_value(path);
    }

    VALUE module::ruby_exec(VALUE self, VALUE command)
    {
        // Note: self is Facter::Core::Execution
        auto const& ruby = *api::instance();
        return execute_command(ruby.to_string(command), ruby.nil_value(), false);
    }

    VALUE module::ruby_execute(int argc, VALUE* argv, VALUE self)
    {
        // Note: self is Facter::Core::Execution
        auto const& ruby = *api::instance();

        if (argc == 0 || argc > 2) {
            ruby.rb_raise(*ruby.rb_eArgError, "wrong number of arguments (%d for 2)", argc);
        }

        if (argc == 1) {
            return execute_command(ruby.to_string(argv[0]), ruby.nil_value(), true);
        }

        // Unfortunately we have to call to_sym rather than using ID2SYM, which is Ruby version dependent
        uint32_t timeout = 0;
        volatile VALUE timeout_option = ruby.rb_hash_lookup(argv[1], ruby.to_symbol("timeout"));
        if (ruby.is_fixednum(timeout_option)) {
            timeout = static_cast<uint32_t>(ruby.rb_num2ulong(timeout_option));
        }

        // Get the on_fail option (defaults to :raise)
        bool raise = false;
        volatile VALUE raise_value = ruby.to_symbol("raise");
        volatile VALUE fail_option = ruby.rb_hash_lookup2(argv[1], ruby.to_symbol("on_fail"), raise_value);
        if (ruby.equals(fail_option, raise_value)) {
            raise = true;
            fail_option = ruby.nil_value();
        }
        return execute_command(ruby.to_string(argv[0]), fail_option, raise, timeout);
    }

    VALUE module::ruby_on_message(VALUE self)
    {
        auto const& ruby = *api::instance();

        from_self(self)->_on_message_block = ruby.rb_block_given_p() ? ruby.rb_block_proc() : ruby.nil_value();
        return ruby.nil_value();
    }

    module* module::from_self(VALUE self)
    {
        auto it = _instances.find(self);
        if (it == _instances.end()) {
            auto const& ruby = *api::instance();
            ruby.rb_raise(*ruby.rb_eArgError, "unexpected self value %d", self);
            return nullptr;
        }
        return it->second;
    }

    VALUE module::execute_command(std::string const& command, VALUE failure_default, bool raise, uint32_t timeout)
    {
        auto const& ruby = *api::instance();

        // Expand the command
        auto expanded = execution::expand_command(command);

        if (!expanded.empty()) {
            try {
                bool success = false;
                string output, none;
                tie(success, output, none) = execution::execute(execution::command_shell, {execution::command_args, expanded}, timeout);
                return ruby.utf8_value(output);
            } catch (timeout_exception const& ex) {
                // Always raise for timeouts
                ruby.rb_raise(ruby.lookup({ "Facter", "Core", "Execution", "ExecutionFailure"}), ex.what());
            }
        }
        // Command was not found
        if (raise) {
            if (expanded.empty()) {
                ruby.rb_raise(ruby.lookup({ "Facter", "Core", "Execution", "ExecutionFailure"}), "execution of command \"%s\" failed: command not found.", command.c_str());
            }
            ruby.rb_raise(ruby.lookup({ "Facter", "Core", "Execution", "ExecutionFailure"}), "execution of command \"%s\" failed.", command.c_str());
        }
        return failure_default;
    }

    void module::initialize_search_paths(vector<string> const& paths)
    {
        auto const& ruby = *api::instance();

        _search_paths.clear();
        _additional_search_paths.clear();

        // Look for "facter" subdirectories on the load path
        for (auto const& directory : ruby.get_load_path()) {
            // Get the canonical directory name
            boost::system::error_code ec;
            path dir = canonical(directory, ec);
            if (ec) {
                continue;
            }

            // Ignore facter itself if it's on the load path
            if (is_regular_file(dir / "facter.rb", ec)) {
                continue;
            }

            dir = dir / "facter";
            if (!is_directory(dir, ec)) {
                continue;
            }
            _search_paths.push_back(dir.string());
        }

        // Append the FACTERLIB paths
        string variable;
        if (environment::get("FACTERLIB", variable)) {
            vector<string> env_paths;
            boost::split(env_paths, variable, bind(equal_to<char>(), placeholders::_1, environment::get_path_separator()), boost::token_compress_on);
            _search_paths.insert(_search_paths.end(), make_move_iterator(env_paths.begin()), make_move_iterator(env_paths.end()));
        }

        // Insert the given paths last
        _search_paths.insert(_search_paths.end(), paths.begin(), paths.end());

        // Do a canonical transform
        transform(_search_paths.begin(), _search_paths.end(), _search_paths.begin(), [](string const& directory) -> string {
            // Get the canonical directory name
            boost::system::error_code ec;
            path dir = canonical(directory, ec);
            if (ec) {
                LOG_DEBUG("path \"%1%\" will not be searched for custom facts: %2%.", directory, ec.message());
                return {};
            }
            return dir.string();
        });

        // Remove anything that is empty using the erase-remove idiom.
        _search_paths.erase(
            remove_if(begin(_search_paths), end(_search_paths), [](string const& path) { return path.empty(); }),
            end(_search_paths));
    }

    VALUE module::load_fact(VALUE name)
    {
        auto const& ruby = *api::instance();

        name = normalize(name);
        string fact_name = ruby.to_string(name);

        // First check to see if we have that fact already
        auto it = _facts.find(fact_name);
        if (it != _facts.end()) {
            return it->second;
        }

        // Try to load it by file name
        if (!_loaded_all) {
            // Next, attempt to load it by file
            string filename = fact_name + ".rb";
            LOG_DEBUG("searching for custom fact \"%1%\".", fact_name);

            for (auto const& directory : _search_paths) {
                LOG_DEBUG("searching for %1% in %2%.", filename, directory);

                // Check to see if there's a file of a matching name in this directory
                path full_path = path(directory) / filename;
                boost::system::error_code ec;
                if (!is_regular_file(full_path, ec)) {
                    continue;
                }

                // Load the fact file
                load_file(full_path.string());
            }

            // Check to see if we now have the fact
            it = _facts.find(fact_name);
            if (it != _facts.end()) {
                return it->second;
            }
        }

        // Otherwise, check to see if it's already in the collection
        auto value = facts()[fact_name];
        if (value) {
            return create_fact(name);
        }

        // Couldn't load the fact by file name, load all facts to try to find it
        load_facts();

        // Check to see if we now have the fact
        it = _facts.find(fact_name);
        if (it != _facts.end()) {
            return it->second;
        }

        // Couldn't find the fact
        LOG_DEBUG("custom fact \"%1%\" was not found.", fact_name);
        return ruby.nil_value();
    }

    void module::load_file(std::string const& path)
    {
        // Only load the file if we haven't done so before
        if (!_loaded_files.insert(path).second) {
            return;
        }

        auto const& ruby = *api::instance();

        LOG_INFO("loading custom facts from %1%.", path);
        ruby.rescue([&]() {
            // Do not construct C++ objects in a rescue callback
            // C++ stack unwinding will not take place if a Ruby exception is thrown!
            ruby.rb_load(ruby.utf8_value(path), 0);
            return 0;
        }, [&](VALUE ex) {
            LOG_ERROR("error while resolving custom facts in %1%: %2%", path, ruby.exception_to_string(ex));
            return 0;
        });
    }

    VALUE module::create_fact(VALUE name)
    {
        auto const& ruby = *api::instance();

        if (!ruby.is_string(name) && !ruby.is_symbol(name)) {
            ruby.rb_raise(*ruby.rb_eTypeError, "expected a String or Symbol for fact name");
        }

        name = normalize(name);
        string fact_name = ruby.to_string(name);

         // First check to see if we have that fact already
        auto it = _facts.find(fact_name);
        if (it == _facts.end()) {
            // Before adding the first fact, call facts to ensure the collection is populated
            facts();
            it = _facts.insert(make_pair(fact_name, fact::create(name))).first;
            ruby.rb_gc_register_address(&it->second);
        }
        return it->second;
    }

    VALUE module::level_to_symbol(log_level level)
    {
        auto const& ruby = *api::instance();

        char const* name = nullptr;

        if (level == log_level::trace) {
            name = "trace";
        } else if (level == log_level::debug) {
            name = "debug";
        } else if (level == log_level::info) {
            name = "info";
        } else if (level == log_level::warning) {
            name = "warn";
        } else if (level == log_level::error) {
            name = "error";
        } else if (level == log_level::fatal) {
            name = "fatal";
        }
        if (!name) {
            ruby.rb_raise(*ruby.rb_eArgError, "invalid log level specified.", 0);
        }
        return ruby.to_symbol(name);
    }

}}  // namespace facter::ruby
