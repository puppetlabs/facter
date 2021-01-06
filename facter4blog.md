# Facter 4: back to the roots

Facter 4 is the default facter staring with Puppet 7. Facter 4 aims for 100% API compatible with Facter 3, but there may be some small inconsistencies. It is written in Ruby, and retains many of the same performance improvements that Facter 3 has over Facter 2. In addition to this Facter 4 also introduces granular blocking and caching for all types of facts, user defined fact groups that can be used for blocking and caching, custom and external fact hierarchies via the dot notation and profiling via `--timing` option


## Blocking and caching of any fact

Facter 4 allows blocking and caching of any type of facts at a granular level. For example, you can block `memory` fact and you would get no memory facts, but you can also block only  `memory.swap`  fact and you will still get `memory.system` facts. The best part about the new blocking and caching mechanism is that you can go as deep as you want in fact the hierarchy, you can even block only `memory.swap.available`

memory fact example
```json
{
  ...
  "memory": {
    "swap": {
      "available": "1.36 GiB",
      "available_bytes": 1465647104,
      "capacity": "72.70%",
      "encrypted": true,
      "total": "5.00 GiB",
      "total_bytes": 5368709120,
      "used": "3.64 GiB",
      "used_bytes": 3903062016
    },
    "system": {
      "available": "91.19 MiB",
      "available_bytes": 95621120,
      "capacity": "99.72%",
      "total": "32.00 GiB",
      "total_bytes": 34359738368,
      "used": "31.91 GiB",
      "used_bytes": 34264117248
    }
  },
  ...
}
```

memory.swap blocked example
``` json
{
  ...
  "memory": {
    "system": {
      "available": "91.19 MiB",
      "available_bytes": 95621120,
      "capacity": "99.72%",
      "total": "32.00 GiB",
      "total_bytes": 34359738368,
      "used": "31.91 GiB",
      "used_bytes": 34264117248
    }
  },
  ...
}
```

As we have seen in the examples, you are now able to cache and block individual facts in addition to groups of facts. In order to block and cache facts and groups of facts, you can still use the `blocklist` and `ttls` attributes from `facter.conf`. 

In the example `memory.swap` is a fact and `EC2` is a group consisting of two facts `ec2_metadata` and `ec2_userdata`. The same mechanism works for cached facts.

``` hocon
facts : {
  blocklist : [ "memory.swap", "EC2" ],
  ttls : [
        { "timezone" : 30 days },
    ]
}
```


## User defined block and cache groups
Multiple facts can be placed in a group and you can block or cache the group. You can define your own groups under the new  `fact-groups` attribute from the familiar `facter.conf` configuration file.

```
facts : {
  blocklist : [ "my-group" ]
}

fact-groups : {
 my-group : ["memory.swap", "memory.system.available", "memory.system.available_bytes"]
}
```


## Custom and external facts hierarchy
You can arrange custom and external facts in hierarchical order using the `.` notation. If you have the following two custom facts named `my_organization.my_custom_fact1` and `my_organization.my_custom_fact2` and an external fact named `my_organization.my_external_fact` the output looks like: 

``` hocon
my_organization => {
  my_custom_fact1 => "fact1_value",
  my_custom_fact2 => "fact2_value",
  my_external_fact => "external_fact_value"
}

```


## Fact profiling

Facter 4 revives the `--time` flag from Facter 2. Using this option, users can obtain benchmark information regarding facts. 

```
fact: memory.swap.available, took: 0.094675 seconds
fact: memory.system.used_bytes, took: 0.100163 seconds
```


## Improve testing

Many modules run their tests with Facter 2 because Facter 3 was never released as a gem. This discrepancy between the way modules were tested and how they were used in production allows bugs to pass the CI and only be discovered in production. Facter 4 is released as a [gem](https://rubygems.org/gems/facter/versions) so you can test your modules with the same Facter that is used in production environments.