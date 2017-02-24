require "./spec_helper"

describe "TOML::Config(with underscore)" do
  config = TOML::Config.parse <<-EOF
    [view]
    header_title = 'KVS'
    header_style = 'background: #FFDE5C;'
    footer_style = 'background: #FFDE5C;'
    EOF

  it "#[]" do
    config["view/header_style"].should eq("background: #FFDE5C;")
  end

  it "#str" do
    config.str("view/header_style").should eq("background: #FFDE5C;")
  end

  it "#str?" do
    config.str?("view/header_style").should eq("background: #FFDE5C;")
  end
end
