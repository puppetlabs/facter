# facter

[![Gem Version](https://badge.fury.io/rb/facter.svg)](https://badge.fury.io/rb/facter)
[<img src="https://img.shields.io/badge/slack-puppet--dev-brightgreen?logo=slack">](https://puppetcommunity.slack.com/messages/C0W1X7ZAL)

[![Modules Status](https://github.com/puppetlabs/facter/workflows/Acceptance%20tests/badge.svg?branch=main)](https://github.com/puppetlabs/facter/actions)
[![Modules Status](https://github.com/puppetlabs/facter/workflows/Unit%20tests/badge.svg?branch=main)](https://github.com/puppetlabs/facter/actions)
[![Modules Status](https://github.com/puppetlabs/facter/workflows/Checks/badge.svg?branch=main)](https://github.com/puppetlabs/facter/actions)
[![Test Coverage](https://api.codeclimate.com/v1/badges/3bd4be86f4b0b49bc0ca/test_coverage)](https://codeclimate.com/github/puppetlabs/facter/test_coverage)
[![Maintainability](https://api.codeclimate.com/v1/badges/3bd4be86f4b0b49bc0ca/maintainability)](https://codeclimate.com/github/puppetlabs/facter/maintainability)


Facter is a command-line tool that gathers basic facts about nodes (systems) such as hardware details, network settings, OS type and version, and more. These facts are made available as variables in your Puppet manifests and can be used to inform conditional expressions in Puppet.

## Supported platforms
* Linux
* macOS
* Windows
* Solaris
* AIX

## Requirements
* Ruby 2.3+

## Basic concepts
The project has three main parts, the framework, facts and resolvers.
In the framework we implement functionality that is agnostic of specific facts like parsing user input, formatting output, etc.

Facts are the nuggets of information that will be provided by facter e.g. `os.name`, `networking.interfaces`, etc.

Resolvers have the role of gathering data from the system.
For example a resolver can execute a command on the system, can read a file or any operation that retries some data from a single source on the system.

![Facter user interaction](docs/diagrams/facter_user_interaction.png?raw=true)

## Getting started
After cloning the project, run `bundle install` to install all dependencies.

You can run facter by executing `./bin/facter`.
The command will output all the facts that facter detected for the current os.

The implementation can be validated locally by running the `./check.sh` script.

## Goals - fast, easy, compatible
* Gain performance similar to the C++ version of Facter. We plan to achieve this goal by gathering multiple facts with only one call and by using the faster Win32 API rather than WMI for the Windows implementation.
* Facilitate community contribution. At the moment, C++ presents a possible impediment for community contributions.
* Enable native integration with other Ruby-based projects such as Bolt and puppet.
* Enable native integration for custom facts.
* Provide 100% compatibility with C++ Facter (drop-in replacement).
