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
* For [SemVer](http://semver.org) purposes, a change in fact value is only considered breaking if a) the fact is documented in the schema, and b) the fact is applicable on a platform we test againt in [Puppet CI](http://jenkins.puppetlabs.com).

Legacy Custom Facts Compatibility
---------------------------------

The Ruby Facter project supports "custom facts" which are fact implementations written using the internal Facter API. For compatibility purposes, Native Facter will support the most commonly used subset of that API specifically:
```
Facter.value
Facter.add
confine
setcode
has_weight (maybe?)
```

It is TBD whether Native Facter will support custom facts which rely on other custom facts. (See New Features for External Facts below for possible mitigation.)

In terms of implementation, there are two avenues we may pursue:
* A standalone ruby shim which executes existing custom facts. This might be able to run as just another external fact.
* A custom fact resolver which calls the Ruby C API to execute custom facts.
We will decide between these two approaches after some spiking to see which will be most robust and maintainable.

Long-term, the new features for external facts should encourage users to port their legacy custom facts to external facts, so at some point (e.g. a couple major versions down the line) this shim logic should be retired.

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
