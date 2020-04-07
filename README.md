# toml-config [![Build Status](https://travis-ci.org/maiha/toml-config.cr.svg?branch=master)](https://travis-ci.org/maiha/toml-config.cr)

handy use of `crystal-toml`

- https://github.com/manastech/crystal-toml
- **supported versions** : 0.27.2 0.31.1 0.32.1 0.33.0 0.34.0

## Usage

#### config (ex. `config.toml` )

```toml
verbose = false

[redis]
host = "127.0.0.1"
port = 6379
cmds = ["GET", "SET"]
```

#### code

```crystal
config = TOML::Config.parse_file("config.toml")
config["verbose"]          # => false
config["xxx"]?             # => nil
config["xxx"]              # TOML::Config::NotFound
config["redis/host"]       # => "127.0.0.1"
config["redis/host"].size  # undefined method 'size'

# syntax sugars to fix type
config.bool("verbose")         # => false
config.str("redis/host")       # => "127.0.0.1"
config.str("redis/host").size  # => 9
config.int("redis/port")       # => 6379
config.int("redis/port").class # => Int32
config.["redis/port"].class    # => Int64 (TOML default)
config.strs("redis/cmds")      # => ["GET, "SET"]
config.str("xxx")              # => TOML::Config::NotFound
config.str("xxx")?             # => nil
config.as_hash("redis").keys   # => ["host", "port", "cmds"]
```

#### custom class

```crystal
class RedisConfig < TOML::Config
  bool verbose
  str  "redis/host", host

  as_hash "redis"
end

config = RedisConfig.parse_file("config.toml")
config.verbose?   # => false
config.host       # => "127.0.0.1"
config.redis.keys # => ["host", "port", "cmds"]
```

## Examples

- https://github.com/maiha/dstat-redis.cr/blob/master/src/bin/main.cr

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  toml-config:
    github: maiha/toml-config.cr
    version: 0.5.2
```

```crystal
require "toml-config"
```

## Breaking Changes

#### v0.5.0
- `#hash` renamed to `#as_hash` to respect `Object#hash`

#### for old crystal
- v0.1.0 for crystal-0.18.x
- v0.2.0 for crystal-0.19.x, 0.20.4
- v0.3.1 for crystal-0.23.x, 0.24.x
- v0.3.2 for crystal-0.25.x, or higher

## Contributing

1. Fork it ( https://github.com/maiha/toml-config/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [maiha](https://github.com/maiha) maiha - creator, maintainer
