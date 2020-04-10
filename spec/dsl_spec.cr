require "./spec_helper"

private class Config < TOML::Config
  bool "verbose"
  str  "redis/host"
  i32  "redis/port"
  i32  "redis/db", db
  str  "redis/name"
  strs "redis/cmds", cmds
  str  url
end

describe "TOML::Config(dsl)" do
  config = Config.parse <<-EOF
    verbose = true
    [redis]
    host = "127.0.0.1"
    port = 6379
    cmds = ["GET", "SET"]
    db   = 0
    EOF

  it "bool" do
    config.verbose .should eq(true)
    config.verbose?.should eq(true)
    config.verbose = nil
    config.verbose .should eq(true)
    config.verbose?.should eq(true)
    config.verbose = false
    config.verbose .should eq(false)
    config.verbose?.should eq(false)
    config.verbose = true
    config.verbose .should eq(true)
    config.verbose?.should eq(true)
  end

  it "str" do
    config.redis_host .should eq("127.0.0.1")
    config.redis_host?.should eq("127.0.0.1")
    config.redis_host = nil
    config.redis_host .should eq("127.0.0.1")
    config.redis_host?.should eq("127.0.0.1")
    config.redis_host = "host1"
    config.redis_host .should eq("host1")
    config.redis_host?.should eq("host1")

    config.redis_name?.should eq(nil)
  end

  it "str(with id)" do
    config.url?.should eq(nil)
    config.url = "foo"
    config.url .should eq("foo")
    config.url?.should eq("foo")
  end
  
  it "i32" do
    config.redis_port .should eq(6379)
    config.redis_port?.should eq(6379)
    config.redis_port = nil
    config.redis_port .should eq(6379)
    config.redis_port?.should eq(6379)
    config.redis_port = 7000
    config.redis_port .should eq(7000)
    config.redis_port?.should eq(7000)
  end

  it "i32(with alias)" do
    config.db .should eq(0)
    config.db?.should eq(0)
    config.db = nil
    config.db .should eq(0)
    config.db?.should eq(0)
    config.db = 1
    config.db .should eq(1)
    config.db?.should eq(1)
  end

  it "strs(with alias)" do
    config.cmds.should eq ["GET", "SET"]
  end
end
