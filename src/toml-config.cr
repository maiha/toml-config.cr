require "toml"

class TOML::Config
  alias Type = Hash(String, TOML::Type)

  class NotFound < Exception
  end
  
  def self.parse(string)
    new(TOML.parse(string))
  end

  def self.parse_file(file)
    new(TOML.parse_file(file))
  end

  def initialize(toml : Type)
    @paths = Hash(String, TOML::Type).new
    build_path(toml, "")
  end

  ######################################################################
  ### Primary API
  
  def [](key)
    key = key.to_s
    @paths.fetch(key) { not_found(key) }
  end

  def []?(key)
    key = key.to_s
    @paths.fetch(key) { nil }
  end

  def []=(key, val)
    @paths[key] = val
  end

  ######################################################################
  ### Syntax sugars to fix type
  
  def str(key) : String
    self[key].as(String)
  end

  def str?(key) : String?
    self[key]?.as(String?)
  end

  def strs(key) : Array(String)
    self[key].as(Array).map(&.to_s).as(Array(String))
  end

  def int64(key) : Int64
    self[key].as(Int64)
  end

  def int64?(key) : Int64?
    self[key]?.try(&.as(Int64))
  end

  def int(key) : Int32
    int64(key).to_i32.as(Int32)
  end

  def int?(key) : Int32?
    int64?(key).try(&.to_i32.as(Int32))
  end

  def ints(key) : Array(Int32)
    self[key].as(Array).map(&.as(Int64).to_i32).as(Array(Int32))
  end

  def bool(key) : Bool
    if self[key]?
      self[key].as(Bool)
    else
      false
    end
  end

  ######################################################################
  ### Internal Functions
  
  protected def not_found(key)
    raise NotFound.new("toml[%s] is not found" % key)
  end

  private def build_path(toml, path)
    case toml
    when Hash
      toml.each do |(key, val)|
        build_path(val, path.empty? ? key : "#{path}/#{key}")
      end
    else
      @paths[path] = toml
    end
  end

  # TODO
  private def update_hash(key, val : TOML::Type)
    hash = @paths
    keys = key.split("/")
    keys.each_with_index do |k, i|
      if i == keys.size - 1
        hash[k] = val
      else
        if ! hash.is_a?(Hash)
          raise "Not hash: TOML::Config[#{key}] = value"
        end
        hash = (hash[k] ||= Type.new).as(Hash)
      end
    end
    val
  end

end
