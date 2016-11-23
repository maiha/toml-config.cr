# toml-config [![Build Status](https://travis-ci.org/maiha/toml-config.cr.svg?branch=master)](https://travis-ci.org/maiha/toml-config.cr)

handy use of `crystal-toml`

- https://github.com/manastech/crystal-toml

#### crystal versions
- v0.1.0 for crystal-0.18.x
- v0.2.0 for crystal-0.19.0 or higher
- WIP: trying crystal-0.20.0

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  toml-config:
    github: maiha/toml-config.cr
```

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
require "toml-config"

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
```

## Examples

- https://github.com/maiha/dstat-redis.cr/blob/master/src/bin/main.cr

## Contributing

1. Fork it ( https://github.com/maiha/toml-config/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [maiha](https://github.com/maiha) maiha - creator, maintainer
