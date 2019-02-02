require "./spec_helper"

module NestedFeature
  DATA = <<-EOF
    [foo]
    ver = 1

    [foo.bar]
    a = "1"
    b = "2"
    EOF

  class Config < TOML::Config
    def_equals_and_hash toml    # ensures not to break `hasher`

    int "foo/ver"
    as_hash "foo/bar"
  end
    
  describe TOML::Config, "(nested feature)" do
    config = Config.parse(DATA)

    it "#[], #[]? works" do
      # not hash
      config["foo/ver"] .should eq(1)
      config["foo/ver"]?.should eq(1)

      # hash
      config["foo/bar"] .should eq({"a" => "1", "b" => "2"})
      config["foo/bar"]?.should eq({"a" => "1", "b" => "2"})
    end

    it "#foo, #foo?" do
      # not hash
      config.foo_ver .should eq(1)
      config.foo_ver?.should eq(1)

      # hash
      config.foo_bar .should eq({"a" => "1", "b" => "2"})
      config.foo_bar?.should eq({"a" => "1", "b" => "2"})
    end

    it "#as_hash" do
      config.as_hash("foo/bar").should eq({"a" => "1", "b" => "2"})
    end
  end
end
