#include <internal/ruby/module.hpp>
#include <internal/ruby/aggregate_resolution.hpp>
#include <internal/ruby/confine.hpp>
#include <internal/ruby/simple_resolution.hpp>
#include <facter/facts/collection.hpp>
#include <facter/logging/logging.hpp>
#include <facter/util/config.hpp>
#include <facter/version.h>
#include <facter/export.h>
#include <leatherman/util/environment.hpp>
#include <leatherman/execution/execution.hpp>
#include <leatherman/file_util/directory.hpp>
#include <leatherman/logging/logging.hpp>
#include <leatherman/locale/locale.hpp>
#include <boost/filesystem.hpp>
#include <boost/algorithm/string.hpp>
#include <boost/nowide/iostream.hpp>
#include <boost/nowide/convert.hpp>
#include <stdexcept>
#include <functional>
#include <facter/facts/scalar_value.hpp>
#include <facter/facts/array_value.hpp>
#include <facter/facts/map_value.hpp>
#include <internal/ruby/ruby_value.hpp>

// Mark string for translation (alias for leatherman::locale::format)
using leatherman::locale::_;

using namespace std;
using namespace facter::facts;
using namespace facter::util::config;
using namespace leatherman::execution;
using namespace leatherman::file_util;
using namespace leatherman::util;
using namespace boost::filesystem;
using namespace leatherman::logging;
using namespace leatherman::ruby;

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
            boost::program_options::variables_map vm;
            auto hocon_conf = load_default_config_file();
            load_fact_settings(hocon_conf, vm);
            set<string> blocklist;
            if (vm.count("blocklist")) {
                auto facts_to_block = vm["blocklist"].as<vector<string>>();
                blocklist.insert(facts_to_block.begin(), facts_to_block.end());
            }
            auto ttls = load_ttls(hocon_conf);
            _facts.reset(new collection(blocklist, ttls));
            _module.reset(new module(*_facts));

            // Ruby doesn't have a proper way of notifying extensions that the VM is shutting down
            // The easiest way to get notified is to have a global data object that never gets collected
            // until the VM shuts down
            auto const& ruby = api::instance();
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
            auto const& ruby = api::instance();
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
        bool logging_init_failed = false;
        string logging_init_error_msg;
        try {
            facter::logging::setup_logging(boost::nowide::cerr);
            set_level(log_level::warning);
        } catch(facter::logging::locale_error const& e) {
            logging_init_failed = true;
            logging_init_error_msg = e.what();
        }

        // Initialize ruby
        api* ruby = nullptr;
        try {
            ruby = &api::instance();
        } catch (runtime_error& ex) {
            if (!logging_init_failed) {
                LOG_WARNING("{1}: facts requiring Ruby will not be resolved.", ex.what());
            } else {
                // This could only happen if some non-ruby library
                // consumer called this function for some reason and
                // we didn't have a libruby loaded. AND the locales
                // are messed up so badly that even resetting locale
                // environment variables fails. This seems so
                // astronomically unlikely that I don't really think
                // it's worth figuring out what we should do in this
                // case - I'm honestly not even sure there's a correct
                // behavior at this point.
                // -- Branan
            }
            return;
        }

        ruby->initialize();

        // If logging init failed, we'll raise a load error
        // here. Otherwise we Create the context
        if (logging_init_failed) {
            ruby->rb_raise(*ruby->rb_eLoadError, _("could not initialize facter due to a locale error: {1}", logging_init_error_msg).c_str());
        } else {
            facter::ruby::require_context::create();
        }
    }
}

namespace facter { namespace ruby {

    static string canonicalize(string p)
    {
        // Get the canonical/absolute directory name
        // If it can be resolved, use canonical to avoid duplicate search paths.
        // Fall back to absolute because canonical on Windows won't recognize paths as valid if
        // they resolve to symlinks to non-NTFS volumes.
        boost::system::error_code ec;
        auto directory = canonical(p, ec);
        if (ec) {
            return absolute(p).string();
        }
        return directory.string();
    }

    map<VALUE, module*> module::_instances;

    module::module(collection& facts, vector<string> const& paths, bool logging_hooks) :
        _collection(facts),
        _loaded_all(false)
    {
        auto const& ruby = api::instance();
        if (!ruby.initialized()) {
            throw runtime_error(_("Ruby API is not initialized.").c_str());
        }

        // Load global settigs from config file
        load_global_settings(load_default_config_file(), _config_file_settings);

        initialize_search_paths(paths);

        // Register the block for logging callback with the GC
        _on_message_block = ruby.nil_value();
        ruby.rb_gc_register_address(&_on_message_block);

        // Install a logging message handler
        on_message([this](log_level level, string const& message) {
            auto const& ruby = api::instance();

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
        ruby.rb_define_singleton_method(_self, "debugging?", RUBY_METHOD_FUNC(ruby_get_debugging), 0);
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

        // Only define these if requested to do so
        // This prevents consumers of Facter from altering the logging behavior
        if (logging_hooks) {
            ruby.rb_define_singleton_method(_self, "debugging", RUBY_METHOD_FUNC(ruby_set_debugging), 1);
            ruby.rb_define_singleton_method(_self, "trace", RUBY_METHOD_FUNC(ruby_set_trace), 1);
            ruby.rb_define_singleton_method(_self, "on_message", RUBY_METHOD_FUNC(ruby_on_message), 0);
        }

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

        try {
            api& ruby = api::instance();

            // Unregister the on message block
            ruby.rb_gc_unregister_address(&_on_message_block);
            on_message(nullptr);

            // Undefine the module
            ruby.rb_const_remove(*ruby.rb_cObject, ruby.rb_intern("Facter"));
        } catch (runtime_error& ex) {
            LOG_WARNING("{1}: Ruby cleanup ended prematurely", ex.what());
            return;
        }
    }

    void module::search(vector<string> const& paths)
    {
        for (auto dir : paths) {
            _additional_search_paths.emplace_back(dir);
            _search_paths.emplace_back(canonicalize(_additional_search_paths.back()));
        }
    }

    void module::load_facts()
    {
        if (_loaded_all) {
            return;
        }

        LOG_DEBUG("loading all custom facts.");

        LOG_DEBUG("loading custom fact directories from config file");
        if (_config_file_settings.count("custom-dir")) {
            auto config_paths = _config_file_settings["custom-dir"].as<vector<string>>();
            _search_paths.insert(_search_paths.end(), config_paths.begin(), config_paths.end());
        }

        for (auto const& directory : _search_paths) {
            LOG_DEBUG("searching for custom facts in {1}.", directory);
            each_file(directory, [&](string const& file) {
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

        auto const& ruby = api::instance();

        // Get the value from all facts
        for (auto const& kvp : _facts) {
            ruby.to_native<fact>(kvp.second)->value();
        }
    }

    void module::clear_facts(bool clear_collection)
    {
        auto const& ruby = api::instance();

        // Unregister all the facts
        for (auto& kvp : _facts) {
            ruby.rb_gc_unregister_address(&kvp.second);
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
        auto const& ruby = api::instance();

        VALUE fact_self = load_fact(name);
        if (ruby.is_nil(fact_self)) {
            return ruby.nil_value();
        }

        return ruby.to_native<fact>(fact_self)->value();
    }

    VALUE module::to_ruby(value const* val) const
    {
        auto const& ruby = api::instance();

        if (!val) {
            return ruby.nil_value();
        }
        if (auto ptr = dynamic_cast<facter::ruby::ruby_value const*>(val)) {
            return ptr->value();
        }
        if (auto ptr = dynamic_cast<string_value const*>(val)) {
            return ruby.utf8_value(ptr->value());
        }
        if (auto ptr = dynamic_cast<integer_value const*>(val)) {
            return ruby.rb_ll2inum(static_cast<LONG_LONG>(ptr->value()));
        }
        if (auto ptr = dynamic_cast<boolean_value const*>(val)) {
            return ptr->value() ? ruby.true_value() : ruby.false_value();
        }
        if (auto ptr = dynamic_cast<double_value const*>(val)) {
            return ruby.rb_float_new_in_heap(ptr->value());
        }
        if (auto ptr = dynamic_cast<array_value const*>(val)) {
            volatile VALUE array = ruby.rb_ary_new_capa(static_cast<long>(ptr->size()));
            ptr->each([&](value const* element) {
                ruby.rb_ary_push(array, to_ruby(element));
                return true;
            });
            return array;
        }
        if (auto ptr = dynamic_cast<map_value const*>(val)) {
            volatile VALUE hash = ruby.rb_hash_new();
            ptr->each([&](string const& name, value const* element) {
                ruby.rb_hash_aset(hash, ruby.utf8_value(name), to_ruby(element));
                return true;
            });
            return hash;
        }
        return ruby.nil_value();
    }

    VALUE module::normalize(VALUE name) const
    {
        auto const& ruby = api::instance();

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

            auto const& ruby = api::instance();
            _collection.add_environment_facts([&](string const& name) {
                // Create a fact and explicitly set the value
                // We honor environment variables above custom fact resolutions
                ruby.to_native<fact>(create_fact(ruby.utf8_value(name)))->value(to_ruby(_collection[name]));
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
        auto const& ruby = api::instance();
        return from_self(ruby.lookup({"Facter"}));
    }

    static VALUE safe_eval(char const* scope, function<VALUE()> body)
    {
        try {
            return body();
        } catch (exception const& e) {
            LOG_ERROR("{1} uncaught exception: {2}", scope, e.what());
        }
        return api::instance().nil_value();
    }

    VALUE module::ruby_version(VALUE self)
    {
        return safe_eval("Facter.version", [&]() {
            auto const& ruby = api::instance();
            return ruby.lookup({ "Facter", "FACTERVERSION" });
        });
    }

    VALUE module::ruby_add(int argc, VALUE* argv, VALUE self)
    {
        return safe_eval("Facter.add", [&]() {
            auto const& ruby = api::instance();

            if (argc == 0 || argc > 2) {
                ruby.rb_raise(*ruby.rb_eArgError, _("wrong number of arguments ({1} for 2)", argc).c_str());
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
        });
    }

    VALUE module::ruby_define_fact(int argc, VALUE* argv, VALUE self)
    {
        return safe_eval("Facter.define_fact", [&]() {
            auto const& ruby = api::instance();

            if (argc == 0 || argc > 2) {
                ruby.rb_raise(*ruby.rb_eArgError, _("wrong number of arguments ({1} for 2)", argc).c_str());
            }

            VALUE fact_self = from_self(self)->create_fact(argv[0]);

            // Call the block if one was given
            if (ruby.rb_block_given_p()) {
                ruby.rb_funcall_passing_block(fact_self, ruby.rb_intern("instance_eval"), 0, nullptr);
            }
            return fact_self;
        });
    }

    VALUE module::ruby_value(VALUE self, VALUE name)
    {
        return safe_eval("Facter.value", [&]() {
            return from_self(self)->fact_value(name);
        });
    }

    VALUE module::ruby_fact(VALUE self, VALUE name)
    {
        return safe_eval("Facter.fact", [&]() {
            return from_self(self)->load_fact(name);
        });
    }

    VALUE module::ruby_debug(VALUE self, VALUE message)
    {
        return safe_eval("Facter.debug", [&]() {
            auto const& ruby = api::instance();
            LOG_DEBUG(ruby.to_string(message));
            return ruby.nil_value();
        });
    }

    VALUE module::ruby_debugonce(VALUE self, VALUE message)
    {
        return safe_eval("Facter.debugonce", [&]() {
            auto const& ruby = api::instance();

            string msg = ruby.to_string(message);
            if (from_self(self)->_debug_messages.insert(msg).second) {
                LOG_DEBUG(msg);
            }
            return ruby.nil_value();
        });
    }

    VALUE module::ruby_warn(VALUE self, VALUE message)
    {
        return safe_eval("Facter.warn", [&]() {
            auto const& ruby = api::instance();
            LOG_WARNING(ruby.to_string(message));
            return ruby.nil_value();
        });
    }

    VALUE module::ruby_warnonce(VALUE self, VALUE message)
    {
        return safe_eval("Facter.warnonce", [&]() {
            auto const& ruby = api::instance();

            string msg = ruby.to_string(message);
            if (from_self(self)->_warning_messages.insert(msg).second) {
                LOG_WARNING(msg);
            }
            return ruby.nil_value();
        });
    }

    VALUE module::ruby_set_debugging(VALUE self, VALUE value)
    {
        return safe_eval("Facter.debugging", [&]() {
            auto const& ruby = api::instance();

            if (ruby.is_true(value)) {
                set_level(log_level::debug);
            } else {
                set_level(log_level::warning);
            }
            return ruby_get_debugging(self);
        });
    }

    VALUE module::ruby_get_debugging(VALUE self)
    {
        return safe_eval("Facter.debugging?", [&]() {
            auto const& ruby = api::instance();
            return is_enabled(log_level::debug) ? ruby.true_value() : ruby.false_value();
        });
    }

    VALUE module::ruby_set_trace(VALUE self, VALUE value)
    {
        return safe_eval("Facter.trace", [&]() {
            auto& ruby = api::instance();
            ruby.include_stack_trace(ruby.is_true(value));
            return ruby_get_trace(self);
        });
    }

    VALUE module::ruby_get_trace(VALUE self)
    {
        return safe_eval("Facter.trace?", [&]() {
            auto const& ruby = api::instance();
            return ruby.include_stack_trace() ? ruby.true_value() : ruby.false_value();
        });
    }

    VALUE module::ruby_log_exception(int argc, VALUE* argv, VALUE self)
    {
        return safe_eval("Facter.log_exception", [&]() {
            auto const& ruby = api::instance();

            if (argc == 0 || argc > 2) {
                ruby.rb_raise(*ruby.rb_eArgError, _("wrong number of arguments ({1} for 2)", argc).c_str());
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
        });
    }

    VALUE module::ruby_flush(VALUE self)
    {
        return safe_eval("Facter.flush", [&]() {
            auto const& ruby = api::instance();

            for (auto& kvp : from_self(self)->_facts)
            {
                ruby.to_native<fact>(kvp.second)->flush();
            }
            return ruby.nil_value();
        });
    }

    VALUE module::ruby_list(VALUE self)
    {
        return safe_eval("Facter.list", [&]() {
            auto const& ruby = api::instance();
            module* instance = from_self(self);

            instance->resolve_facts();

            volatile VALUE array = ruby.rb_ary_new_capa(instance->facts().size());

            instance->facts().each([&](string const& name, value const*) {
                ruby.rb_ary_push(array, ruby.utf8_value(name));
                return true;
            });

            return array;
        });
    }

    VALUE module::ruby_to_hash(VALUE self)
    {
        return safe_eval("Facter.to_hash", [&]() {
            auto const& ruby = api::instance();
            module* instance = from_self(self);

            instance->resolve_facts();

            volatile VALUE hash = ruby.rb_hash_new();

            instance->facts().each([&](string const& name, value const* val) {
                ruby.rb_hash_aset(hash, ruby.utf8_value(name), instance->to_ruby(val));
                return true;
            });

            return hash;
        });
    }

    VALUE module::ruby_each(VALUE self)
    {
        return safe_eval("Facter.each", [&]() {
            auto const& ruby = api::instance();
            module* instance = from_self(self);

            instance->resolve_facts();

            instance->facts().each([&](string const& name, value const* val) {
                ruby.rb_yield_values(2, ruby.utf8_value(name), instance->to_ruby(val));
                return true;
            });

            return self;
        });
    }

    VALUE module::ruby_clear(VALUE self)
    {
        return safe_eval("Facter.clear", [&]() {
            auto const& ruby = api::instance();

            ruby_flush(self);
            ruby_reset(self);

            return ruby.nil_value();
        });
    }

    VALUE module::ruby_reset(VALUE self)
    {
        return safe_eval("Facter.reset", [&]() {
            auto const& ruby = api::instance();
            module* instance = from_self(self);

            instance->clear_facts();
            instance->initialize_search_paths({});
            instance->_external_search_paths.clear();
            instance->_loaded_all = false;
            instance->_loaded_files.clear();

            return ruby.nil_value();
        });
    }

    VALUE module::ruby_loadfacts(VALUE self)
    {
        return safe_eval("Facter.loadfacts", [&]() {
            auto const& ruby = api::instance();

            from_self(self)->load_facts();
            return ruby.nil_value();
        });
    }

    VALUE module::ruby_search(int argc, VALUE* argv, VALUE self)
    {
        return safe_eval("Facter.search", [&]() {
            auto const& ruby = api::instance();
            module* instance = from_self(self);

            for (int i = 0; i < argc; ++i) {
                if (!ruby.is_string(argv[i])) {
                    continue;
                }

                instance->_additional_search_paths.emplace_back(ruby.to_string(argv[i]));
                instance->_search_paths.emplace_back(canonicalize(instance->_additional_search_paths.back()));
            }
            return ruby.nil_value();
        });
    }

    VALUE module::ruby_search_path(VALUE self)
    {
        return safe_eval("Facter.search_path", [&]() {
            auto const& ruby = api::instance();
            module* instance = from_self(self);

            volatile VALUE array = ruby.rb_ary_new_capa(instance->_additional_search_paths.size());

            for (auto const& path : instance->_additional_search_paths) {
                ruby.rb_ary_push(array, ruby.utf8_value(path));
            }
            return array;
        });
    }

    VALUE module::ruby_search_external(VALUE self, VALUE paths)
    {
        return safe_eval("Facter.search_external", [&]() {
            auto const& ruby = api::instance();
            module* instance = from_self(self);

            ruby.array_for_each(paths, [&](VALUE element) {
                if (!ruby.is_string(element)) {
                    return true;
                }
                instance->_external_search_paths.emplace_back(ruby.to_string(element));
                return true;
            });

            // Add external path from config file
            LOG_DEBUG(_("loading external fact directories from config file"));
            if (instance->_config_file_settings.count("external-dir")) {
                auto config_paths = instance->_config_file_settings["external-dir"].as<vector<string>>();
                instance->_external_search_paths.insert(instance->_external_search_paths.end(), config_paths.begin(), config_paths.end());
            }
            return ruby.nil_value();
        });
    }

    VALUE module::ruby_search_external_path(VALUE self)
    {
        return safe_eval("Facter.search_external_path", [&]() {
            auto const& ruby = api::instance();
            module* instance = from_self(self);

            volatile VALUE array = ruby.rb_ary_new_capa(instance->_external_search_paths.size());

            for (auto const& path : instance->_external_search_paths) {
                ruby.rb_ary_push(array, ruby.utf8_value(path));
            }
            return array;
        });
    }

    VALUE module::ruby_which(VALUE self, VALUE binary)
    {
        return safe_eval("Facter::Core::Execution::which", [&]() {
            // Note: self is Facter::Core::Execution
            auto const& ruby = api::instance();

            string path = which(ruby.to_string(binary));
            if (path.empty()) {
                return ruby.nil_value();
            }

            return ruby.utf8_value(path);
        });
    }

    VALUE module::ruby_exec(VALUE self, VALUE command)
    {
        return safe_eval("Facter::Core::Execution::exec", [&]() {
            // Note: self is Facter::Core::Execution
            auto const& ruby = api::instance();
            return execute_command(ruby.to_string(command), ruby.nil_value(), false);
        });
    }

    VALUE module::ruby_execute(int argc, VALUE* argv, VALUE self)
    {
        return safe_eval("Facter::Core::Execution::execute", [&]() {
            // Note: self is Facter::Core::Execution
            auto const& ruby = api::instance();

            if (argc == 0 || argc > 2) {
                ruby.rb_raise(*ruby.rb_eArgError, _("wrong number of arguments ({1} for 2)", argc).c_str());
            }

            if (argc == 1) {
                return execute_command(ruby.to_string(argv[0]), ruby.nil_value(), true);
            }

            // Unfortunately we have to call to_sym rather than using ID2SYM, which is Ruby version dependent
            uint32_t timeout = 0;
            volatile VALUE timeout_option = ruby.rb_hash_lookup(argv[1], ruby.to_symbol("timeout"));
            if (ruby.is_integer(timeout_option)) {
                timeout = ruby.num2size_t(timeout_option);
            }

            // Get the on_fail option (defaults to :raise)
            bool raise = false;
            volatile VALUE raise_value = ruby.to_symbol("raise");
            volatile VALUE fail_option = ruby.rb_hash_lookup2(argv[1], ruby.to_symbol("on_fail"), raise_value);
            if (ruby.equals(fail_option, raise_value)) {
                raise = true;
                fail_option = ruby.nil_value();
            }

            bool expand = true;
            volatile VALUE expand_option = ruby.rb_hash_lookup2(argv[1], ruby.to_symbol("expand"), ruby.true_value());
            if (ruby.is_false(expand_option)) {
                expand = false;
            }

            return execute_command(ruby.to_string(argv[0]), fail_option, raise, timeout, expand);
        });
    }

    VALUE module::ruby_on_message(VALUE self)
    {
        return safe_eval("Facter.on_message", [&]() {
            auto const& ruby = api::instance();

            from_self(self)->_on_message_block = ruby.rb_block_given_p() ? ruby.rb_block_proc() : ruby.nil_value();
            return ruby.nil_value();
        });
    }

    module* module::from_self(VALUE self)
    {
        auto it = _instances.find(self);
        if (it == _instances.end()) {
            auto const& ruby = api::instance();
            ruby.rb_raise(*ruby.rb_eArgError, _("unexpected self value {1}", self).c_str());
            return nullptr;
        }
        return it->second;
    }

    VALUE module::execute_command(std::string const& command, VALUE failure_default, bool raise, uint32_t timeout, bool expand)
    {
        auto const& ruby = api::instance();

        // Expand the command only if expand is true,
        std::string expanded;
        try{
            expanded = expand_command(command, leatherman::util::environment::search_paths(), expand);
        } catch (const std::invalid_argument &ex) {
            ruby.rb_raise(*ruby.rb_eArgError, _("Cause: {1}",  ex.what()).c_str());
        }
        if (!expanded.empty()) {
            try {
                auto exec = execute(
                    command_shell,
                    {
                        command_args,
                        expanded
                    },
                    timeout,
                    {
                        execution_options::trim_output,
                        execution_options::merge_environment,
                        execution_options::redirect_stderr_to_null,
                        execution_options::preserve_arguments
                    });
                // Ruby can encode some additional information in the
                // lower 8 bits. None of those set means "process exited normally"
                ruby.rb_last_status_set(exec.exit_code << 8, static_cast<rb_pid_t>(exec.pid));
                return ruby.utf8_value(exec.output);
            } catch (timeout_exception const& ex) {
                // Always raise for timeouts
                ruby.rb_raise(ruby.lookup({ "Facter", "Core", "Execution", "ExecutionFailure"}), ex.what());
            }
        }
        // Command was not found
        if (raise) {
            if (expanded.empty()) {
                ruby.rb_raise(ruby.lookup({ "Facter", "Core", "Execution", "ExecutionFailure"}), _("execution of command \"{1}\" failed: command not found.", command).c_str());
            }
            ruby.rb_raise(ruby.lookup({ "Facter", "Core", "Execution", "ExecutionFailure"}), _("execution of command \"{1}\" failed.", command).c_str());
        }
        return failure_default;
    }

    void module::initialize_search_paths(vector<string> const& paths)
    {
        auto const& ruby = api::instance();

        _search_paths.clear();
        _additional_search_paths.clear();

        // Look for "facter" subdirectories on the load path
        for (auto const& directory : ruby.get_load_path()) {
            boost::system::error_code ec;
            // Use forward-slash to keep this consistent with Ruby conventions.
            auto dir = canonicalize(directory) + "/facter";

            // Ignore facter itself if it's on the load path
            if (is_regular_file(dir, ec)) {
                continue;
            }

            if (!is_directory(dir, ec)) {
                continue;
            }
            _search_paths.push_back(dir);
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

        // Do a canonical/absolute transform
        transform(_search_paths.begin(), _search_paths.end(), _search_paths.begin(), [](string const& directory) -> string {
            return canonicalize(directory);
        });

        // Remove anything that is empty using the erase-remove idiom.
        _search_paths.erase(
            remove_if(begin(_search_paths), end(_search_paths), [](string const& path) { return path.empty(); }),
            end(_search_paths));
    }

    VALUE module::load_fact(VALUE name)
    {
        auto const& ruby = api::instance();

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
            LOG_DEBUG("searching for custom fact \"{1}\".", fact_name);

            for (auto const& directory : _search_paths) {
                LOG_DEBUG("searching for {1} in {2}.", filename, directory);

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
        LOG_DEBUG("custom fact \"{1}\" was not found.", fact_name);
        return ruby.nil_value();
    }

    void module::load_file(std::string const& path)
    {
        // Only load the file if we haven't done so before
        if (!_loaded_files.insert(path).second) {
            return;
        }

        auto const& ruby = api::instance();

        LOG_INFO("loading custom facts from {1}.", path);
        ruby.rescue([&]() {
            // Do not construct C++ objects in a rescue callback
            // C++ stack unwinding will not take place if a Ruby exception is thrown!
            ruby.rb_load(ruby.utf8_value(path), 0);
            return 0;
        }, [&](VALUE ex) {
            LOG_ERROR("error while resolving custom facts in {1}: {2}", path, ruby.exception_to_string(ex));
            return 0;
        });
    }

    VALUE module::create_fact(VALUE name)
    {
        auto const& ruby = api::instance();

        if (!ruby.is_string(name) && !ruby.is_symbol(name)) {
            ruby.rb_raise(*ruby.rb_eTypeError, _("expected a String or Symbol for fact name").c_str());
        }

        name = normalize(name);
        string fact_name = ruby.to_string(name);

         // First check to see if we have that fact already
        auto it = _facts.find(fact_name);
        if (it == _facts.end()) {
            // Before adding the first fact, call facts to ensure the collection is populated
            facts();
            // facts() may add entries to _facts, so check again to ensure entry has not already been added (avoid duplicate Ruby GC registration)
            it = _facts.find(fact_name);
            if (it == _facts.end()) {
                it = _facts.insert(make_pair(fact_name, fact::create(name))).first;
                ruby.rb_gc_register_address(&it->second);
            }
        }
        return it->second;
    }

    VALUE module::level_to_symbol(log_level level)
    {
        auto const& ruby = api::instance();

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
            ruby.rb_raise(*ruby.rb_eArgError, _("invalid log level specified.").c_str(), 0);
        }
        return ruby.to_symbol(name);
    }

}}  // namespace facter::ruby
