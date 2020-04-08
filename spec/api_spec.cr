require "./spec_helper"

describe TOML::Config do
  config = TOML::Config.parse <<-EOF
    verbose = false
    
    [redis]
    host = "127.0.0.1"
    port = 6379
    cmds = ["GET", "SET"]
    save = [900, 1]

    [log]
    interval = 0.1
    backoffs = [0.1, 0.3, 1.5]
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

  describe "(Typed API)" do
    it "bool" do
      # found
      config.bool("verbose").should eq(false)

      # not found
      config.bool?("xxx")   .should eq(nil)
      config.bools?("xxx")  .should eq(nil)
      expect_raises TOML::Config::NotFound do
        config.bool("xxx")
      end
      expect_raises TOML::Config::NotFound do
        config.bools("xxx")
      end
    end

    it "str" do
      # found
      config.str("redis/host").should eq("127.0.0.1")

      # not found
      config.str?("xxx")   .should eq(nil)
      config.strs?("xxx")  .should eq(nil)
      expect_raises TOML::Config::NotFound do
        config.str("xxx")
      end
      expect_raises TOML::Config::NotFound do
        config.strs("xxx")
      end
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

    it "i32, i64" do
      config["redis/port"].should be_a(Int64)
      config.i32("redis/port").should be_a(Int32)
      config.i64("redis/port").should be_a(Int64)
    end

    it "i32?, i64?" do
      config.i32?("redis/port").should eq(6379)
      config.i64?("redis/port").should be_a(Int64)
      config.i32?("redis/port").should be_a(Int32)
      config.i32?("redis/XXXX").should eq(nil)
    end

    it "i32s, i64s" do
      config.i32s("redis/save").should eq([900, 1])
      config.i64s("redis/save").should eq([900, 1])

      expect_raises TOML::Config::NotFound do
        config.i32s("redis/XXXX")
      end
    end

    it "f32, f64" do
      config["log/interval"].class.should eq(Float64)
      config.f32("log/interval").should eq(0.1_f32)
      config.f64("log/interval").should eq(0.1_f64)
      config.f32("log/interval").should be_a(Float32)
      config.f64("log/interval").should be_a(Float64)
    end

    it "f32?, f64?" do
      config["log/interval"].class.should eq(Float64)
      config.f32?("log/interval").should eq(0.1_f32)
      config.f64?("log/interval").should eq(0.1_f64)
      config.f32?("log/interval").should be_a(Float32)
      config.f64?("log/interval").should be_a(Float64)
      config.f32?("log/XXXX").should eq(nil)
      config.f64?("log/XXXX").should eq(nil)
    end

    it "hash" do
      config.as_hash("redis").should eq({"host" => "127.0.0.1", "port" => 6379, "cmds" => ["GET", "SET"], "save" => [900, 1]})
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
