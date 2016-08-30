require "./spec_helper"

describe TOML::Config do
  config = TOML::Config.parse <<-EOF
    verbose = false
    
    [redis]
    host = "127.0.0.1"
    port = 6379
    cmds = ["GET", "SET"]
    save = [900, 1]
    EOF

  describe "#[]" do
    it "verbose" do
      config["verbose"].should eq(false)
    end

    it "redis/host" do
      config["redis/host"].should eq("127.0.0.1")
    end

    it "redis/port" do
      config["redis/port"].should eq(6379)
    end

    it "redis/cmds" do
      config["redis/cmds"].should eq(["GET", "SET"])
    end

    it "non existing key" do
      expect_raises TOML::Config::NotFound do
        config["xxx"]
      end

      expect_raises TOML::Config::NotFound do
        config["yyy/zzz"]
      end
    end
  end

  describe "(typed readers)" do
    it "bool" do
      config.bool("verbose").should eq(false)
    end

    it "str" do
      config.str("redis/host").should eq("127.0.0.1")
    end

    it "str?" do
      config.str?("redis/host").should eq("127.0.0.1")
      config.str?("redis/XXXX").should eq(nil)
    end

    it "strs" do
      config.strs("redis/cmds").should eq(["GET", "SET"])

      expect_raises TOML::Config::NotFound do
        config.strs("redis/XXXX")
      end
    end

    it "int" do
      config["redis/port"].should be_a(Int64)
      config.int("redis/port").should be_a(Int32)
    end

    it "int?" do
      config.int?("redis/port").should eq(6379)
      config.int?("redis/port").should be_a(Int32)
      config.int?("redis/XXXX").should eq(nil)
    end

    it "ints" do
      config.ints("redis/save").should eq([900, 1])
      config.ints("redis/save").should be_a(Array(Int32))

      expect_raises TOML::Config::NotFound do
        config.ints("redis/XXXX")
      end
    end

    it "int64" do
      config["redis/port"].class.should eq(Int64)
      config.int64("redis/port").should eq(6379)
      config.int64("redis/port").should be_a(Int64)
    end

    it "int64?" do
      config.int64?("redis/port").should eq(6379)
      config.int64?("redis/port").should be_a(Int64)
      config.int64?("redis/XXXX").should eq(nil)
    end
  end

  describe "[]?" do
    it "for existing entry" do
      config["verbose"]?.should eq(false)
      config["redis/port"]?.should eq(6379)
    end

    it "for non-existing entry" do
      config["xxx"]?.should eq(nil)
      config["xxx/yyy"]?.should eq(nil)
    end
  end

  describe "[]=" do
    it "for existing entry" do
      config["verbose"] = true
      config["verbose"].should eq(true)

      config["redis/host"] = "localhost"
      config["redis/host"].should eq("localhost")
    end

    it "for non-existing entry" do
      config["xxx"] = true
      config["xxx"].should eq(true)
      config["redis/xxx"] = "foo"
      config["redis/xxx"].should eq("foo")
    end
  end
end
