# toml-config [![Build Status](https://travis-ci.org/maiha/toml-config.cr.svg?branch=master)](https://travis-ci.org/maiha/toml-config.cr)

handy use of `crystal-toml`

- https://github.com/manastech/crystal-toml
- crystal: 0.36.1

## Usage

#### config (ex. `config.toml` )

```toml
verbose = true

[redis]
host = "127.0.0.1"
port = 6379
cmds = ["GET", "SET"]
```

#### code

```crystal
config = TOML::Config.parse_file("config.toml")
```

## Basic API

Basic API provides hash like access and returns a value as Union Types like `Int64 | String | ...`.

```crystal
config["verbose"]          # => true
config["xxx"]?             # => nil
config["xxx"]              # TOML::Config::NotFound
config["redis/host"]       # => "127.0.0.1"
config["redis/host"].size  # undefined method 'size'
```

## Typed API

If you know the type, the **Typed API** is useful as it will automatically convert the type.
* supported types: `bool`, `f64`, `f32`, `i32`, `i64`, `str`
* provided api for the type: `xxx`, `xxx?`, `xxxs`, `xxxs?`

```crystal
config.bool("verbose")         # => true
config.bool?("verbose")        # => nil
config.str("redis/host")       # => "127.0.0.1"
config.str("redis/host").size  # => 9
config.i32("redis/port")       # => 6379
config.i32("redis/port").class # => Int32
config.["redis/port"].class    # => Int64 (TOML default)
config.strs("redis/cmds")      # => ["GET, "SET"]
config.str("xxx")              # => TOML::Config::NotFound
config.str("xxx")?             # => nil
config.as_hash("redis").keys   # => ["host", "port", "cmds"]
```

## Macro API

In subclass of `TOML::Config`, type names are provided as class level macro.
We can use type as DSL to define instance methods.

```crystal
class RedisConfig < TOML::Config
  bool verbose
  str  "redis/host", host
  i32  "redis/port"
  i32  "redis/db", db
  strs "redis/cmds", cmds

  as_hash "redis"
end

config = RedisConfig.parse_file("config.toml")
config.verbose?   # => false
config.host       # => "127.0.0.1"
config.redis.keys # => ["host", "port", "cmds"]
config.cmds       # => ["GET", "SET"]
```

## Examples

- https://github.com/maiha/dstat-redis.cr/blob/master/src/bin/main.cr

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  toml-config:
    github: maiha/toml-config.cr
    version: 0.7.0
```

```crystal
require "toml-config"
```

## Breaking Changes

- v0.6.0: Replace `int`, `float` with `i32`, `i64`, `f32`, `f64`.
- v0.6.0: `#bool(key)` now raises when the entry is missing. (use `bool?` if you need compatibility)
- v0.5.0: `#hash` renamed to `#as_hash` to respect `Object#hash`

#### for old crystal
- v0.1.0 for crystal-0.18.x
- v0.2.0 for crystal-0.19.x, 0.20.4
- v0.3.1 for crystal-0.23.x, 0.24.x
- v0.3.2 for crystal-0.25.x
- v0.6.1 for crystal-0.33.x
- v0.7.0 for crystal-0.36.x, or higher

## Contributing

1. Fork it ( https://github.com/maiha/toml-config/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [maiha](https://github.com/maiha) maiha - creator, maintainer
