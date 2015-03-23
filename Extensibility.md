Extensibility
=============

Native Facter has the following extensibility goals:

* Clear guidelines for what facts are supported in-project
* Compatibility with 90+% of existing Facter custom facts
* Compatibility with 100% of existing Facter external facts
* New features for external facts, including depends/requires logic

The following sections discuss those goals in more depth.

Note that this doc is work-in-progress and should be updated as extensibility features are implemented, refined or ruled out.

Built-in facts
--------------

These are the criteria for Native Facter pull requests:

* Additional resolutions for existing built-in facts (e.g. the operatingsystem facts for new Linux Distros) must conform to the facter.json schema.
* New facts must be accompanied by support in the facter.json schema.
* For [SemVer](http://semver.org) purposes, a change in fact value is only considered breaking if a) the fact is documented in the schema, and b) the fact is applicable on a platform we test against in [Puppet CI](http://jenkins.puppetlabs.com).

Custom Facts Compatibility
--------------------------

Ruby Facter supports "custom facts" that are facts implemented using the public Facter API.

Native Facter implements a Ruby compatibility layer to support simple and aggregate fact resolutions.
Native Facter searches for a MRI Ruby library to load and initializes a Ruby VM as needed
to resolve custom facts.

The environment variable `FACTERRUBY` can be used to explicitly instruct native Facter to use
a particular Ruby library (e.g. `FACTERRUBY=/usr/local/lib/libruby.so.1.9.3`).  If not set, native Facter will search for and load the highest
version Ruby library on the system.

**Ruby 1.8.x is not supported by native Facter.  Please use Ruby 1.9.3 or later.**

Native Facter will load custom facts from the following locations:

* Any Ruby source file in a `facter` subdirectory on the Ruby load path.
* Any Ruby source file in a directory specified by the `FACTERLIB` environment variable (delimited by the platform PATH separator).
* Any Ruby source file in a directory specified by the `--custom-dir` option to facter.

The following methods from the Facter API are currently supported by native Facter:

From the `Facter` module:

* []
* add
* clear
* debug
* debugonce
* define_fact
* each
* fact
* flush
* list
* loadfacts
* log_exception
* reset
* search
* search_path
* search_external
* search_external_path
* to_hash
* value
* version
* warn
* warnonce

From the `Facter::Core::Execution` module:

* which
* exec
* execute
* ExecutionFailure

From the `Facter::Util::Fact` class:

* define_resolution
* flush
* name
* resolution
* value

From the `Facter::Util::Resolution` module:

* confine
* exec
* has_weight
* name
* on_flush
* setcode
* which

From the `Facter::Core::Aggregate` module:

* aggregate
* chunk
* confine
* has_weight
* name
* on_flush

Please note: the timeout option is not currently supported on resolutions.  Setting a timeout will result in a warning
and the timeout will be ignored.

Please see the [Facter Custom Facts Walkthrough](https://docs.puppetlabs.com/facter/2.2/custom_facts.html) for more information on using the Facter API.

External Facts Compatiblity
---------------------------

Native Facter will support all 4 forms of "external facts" which Ruby Facter supports:
* JSON files with the .json extension whose key-value pairs will be mapped to fact-value pairs.
* YAML files with the .yaml extension whose key-value pairs will be mapped to fact-value pairs.
* Text files with the .txt extension containing `fact=some_value` strings
* Executable files returning `fact=some_value` strings

New Features for External Facts
-------------------------------

Caveat: It is TBD which of these features will be implemented in what releases.

* Executable external facts can take a json object on stdin describing all known facts. This will allow logic like the confine/value methods provide in the custom facts API.

* To support the use case of facts which depend on other facts: executable external facts can describe what facts they depend on and what facts they provide, via a json schema. (This schema could either be a parallel file distributed with the external fact following some naming convention (e.g. foo.schema for an external fact called foo.sh or foo.py), or the schema could be provided on stdout when executing the external fact with some parameter (e.g. foo.sh --show-schema).) 

* Native Facter might add a weight indicator for returned facts, to support fact precedence for external facts, along the lines of the `has_weight` functionality.

* Native Facter might add a volatility indicator, such as a ttl field, to the json schema provided by external facts. This would allow facter in a long-running process to avoid unnecessary refreshes of non-volatile facts.

* Native Facter might include some language-specific shims for its external facts support, most likely for Ruby and Python, to ease writing new external facts (including ports of legacy custom facts).
