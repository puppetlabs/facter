Extensibility
=============

Facter 4 has the following extensibility goals:

* Compatibility with 100% of existing Facter custom facts
* Compatibility with 100% of existing Facter external facts

The following sections discuss those goals in more depth.

Note that this doc is work-in-progress and should be updated as extensibility features are implemented, refined or ruled out.

Custom Facts Compatibility
--------------------------

Facter 4 will load custom facts from the following locations:

* Any Ruby source file in a `facter` subdirectory on the Ruby load path.
* Any Ruby source file in a directory specified by the `FACTERLIB` environment variable (delimited by the platform PATH separator).
* Any Ruby source file in a directory specified by the `--custom-dir` option to facter.

The following methods from the Facter API are currently supported by Facter 4:

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
* resolve
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

Please see the [Facter Custom Facts Walkthrough](https://puppet.com/docs/puppet/latest/custom_facts.html) for more information on using the Facter API.

External Facts Compatiblity
---------------------------

Facter 4 supports all 4 forms of "external facts" which Facter 3 supports:
* JSON files with the .json extension whose key-value pairs will be mapped to fact-value pairs.
* YAML files with the .yaml extension whose key-value pairs will be mapped to fact-value pairs.
* Text files with the .txt extension containing `fact=some_value` strings
* Executable files returning `fact=some_value` strings

Enable conversion of dotted facts to structured
---------------------------

By default Facter 4 treats the `.` in custom or external fact names as part of the fact name and not a delimiter for structured facts.

If you want to enable the new behaviour, that converts dotted facts to structured you need to set the following config:

```
global : {
    force-dot-resolution : true
}
```
