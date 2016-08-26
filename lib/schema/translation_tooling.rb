require 'yaml'

fact_schema = YAML.load_file(File.join(File.dirname(__FILE__), "facter.yaml"))
facts = []

fact_schema.each do |fact|
  fact_name = fact[0]
  fact_details = fact[1]

  fact_data = {:name => fact_name,
               :description => fact_details['description'],
               :resolution => fact_details['resolution'],
               :caveats => fact_details['caveats']}

  facts << fact_data
end

File.open(File.join(File.dirname(__FILE__), "core_facts.pot"), 'w') do |file|
  file.puts <<-HEADER
# CORE FACTS SCHEMA
# Copyright (C) 2016 Puppet, LLC
# This file is distributed under the same license as the FACTER package.
# FIRST AUTHOR <docs@puppet.com>, 2016.
#
#, fuzzy
msgid ""
msgstr ""
"Project-Id-Version: FACTER \\n"
"Report-Msgid-Bugs-To: docs@puppet.com\\n"
"POT-Creation-Date: \\n"
"PO-Revision-Date: YEAR-MO-DA HO:MI+ZONE\\n"
"Last-Translator: FULL NAME <EMAIL@ADDRESS>\\n"
"Language-Team: LANGUAGE <LL@li.org>\\n"
"Language: \\n"
"MIME-Version: 1.0\\n"
"Content-Type: text/plain; charset=UTF-8\\n"
"Content-Transfer-Encoding: 8bit\\n"
"Plural-Forms: nplurals=INTEGER; plural=EXPRESSION;\\n"
\n
  HEADER

  facts.each do |fact|
    if fact[:description]
      descriptions = fact[:description].split("\n")

      descriptions.each do |string|
        file.puts "#. #{fact[:name]} description\nmsgid \"#{string}\"\nmsgstr \"\"\n\n"
      end
    end

    if fact[:resolution]
      resolutions = fact[:resolution].split("\n")

      resolutions.each do |string|
        file.puts "#. #{fact[:name]} resolution\nmsgid \"#{string}\"\nmsgstr \"\"\n\n"
      end
    end

    if fact[:caveats]
      caveats = fact[:caveats].split("\n")

      caveats.each do |string|
        file.puts "#. #{fact[:name]} caveats\nmsgid \"#{string}\"\nmsgstr \"\"\n\n"
      end
    end
  end
end
