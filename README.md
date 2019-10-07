# facter-ng

[![Build Status](https://travis-ci.org/puppetlabs/facter-ng.svg?branch=master)](https://travis-ci.org/puppetlabs/facter-ng?branch=master)
[![Coverage Status](https://coveralls.io/repos/github/puppetlabs/facter-ng/badge.svg?branch=master)](https://coveralls.io/github/puppetlabs/facter-ng?branch=master)
[![Maintainability](https://api.codeclimate.com/v1/badges/bf43445f767f2d64170a/maintainability)](https://codeclimate.com/github/puppetlabs/facter-ng/maintainability)

Facter is a command-line tool that gathers basic facts about nodes (systems) such as hardware details, network settings, OS type and version, and more. These facts are made available as variables in your Puppet manifests and can be used to inform conditional expressions in Puppet.

## supported platforms
* Linux
* macOS
* Windows
* Solaris
* AIX

## requirements
* Ruby 2.3+

## basic concepts
The project has three main parts, the framework, facts and resolvers. 
In the framework we implement functionality that is agnostic of specific facts like parsing user input, formatting output, etc.

Facts are the nuggets of information that will be provided by facter e.g. `os.name`, `networking.interfaces`, etc.

Resolvers have the role of gathering data from the system. 
For example a resolver can execute a command on the system, can read a file or any operation that retries some data from a single source on the system. 

## getting started
After cloning the project, you can run facter by executing `./bin/facter`. 
The command will output all the facts that facter detected for the current os.

In order to generate a fact, we can use the rake task `rake 'create_fact[<os>,<fact_name>]'` e.g. `rake 'create_fact[ubuntu,facterversion]'`
When generating a fact, the unit test for that fact is also generated. Facts should call on or more resolvers in order to obtain the data they need.

The implementation can be validated locally by running the `./check.sh` script. 
