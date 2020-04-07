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

  getter toml

  def initialize(@toml : Type)
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

  def float64(key) : Float64
    self[key].as(Float64)
  end

  def float64?(key) : Float64?
    self[key]?.try(&.as(Float64))
  end

  def float64s(key) : Array(Float64)
    self[key].as(Array).map(&.as(Float64))
  end

  def float(key)
    float64(key)
  end

  def float?(key)
    float64?(key)
  end

  def floats(key)
    float64s(key)
  end

  def bool(key) : Bool
    if self[key]?
      self[key].as(Bool)
    else
      false
    end
  end

  def as_hash(key : String) : Hash
    self[key].as(Hash)
  end

  def as_hash?(key : String)
    self[key]?.try(&.as(Hash))
  end

  ######################################################################
  ### DSL macros

  macro bool(key, m = nil)
    def {{(m || key.id).stringify.gsub(/\//, "_").id}}?
      self.bool({{key.id.stringify}})
    end

    def {{(m || key.id).stringify.gsub(/\//, "_").id}}=(v : Bool)
      @paths[{{key.id.stringify}}] = v
    end

    def {{(m || key.id).stringify.gsub(/\//, "_").id}}=(v : Nil)
    end
  end

  macro str(key, m = nil)
    def {{(m || key.id).stringify.gsub(/\//, "_").id}}?
      self.str?({{key.id.stringify}})
    end

    def {{(m || key.id).stringify.gsub(/\//, "_").id}}
      self.str({{key.id.stringify}})
    end

    def {{(m || key.id).stringify.gsub(/\//, "_").id}}=(v : String)
      @paths[{{key.id.stringify}}] = v
    end

    def {{(m || key.id).stringify.gsub(/\//, "_").id}}=(v : Nil)
    end
  end

  macro int(key, m = nil)
    def {{(m || key.id).stringify.gsub(/\//, "_").id}}?
      self.int?({{key.id.stringify}})
    end

    def {{(m || key.id).stringify.gsub(/\//, "_").id}}
      self.int({{key.id.stringify}})
    end

    def {{(m || key.id).stringify.gsub(/\//, "_").id}}=(v : Int64)
      @paths[{{key.id.stringify}}] = v
    end

    def {{(m || key.id).stringify.gsub(/\//, "_").id}}=(v : Nil)
    end
  end

  macro float(key, m = nil)
    def {{(m || key.id).stringify.gsub(/\//, "_").id}}?
      self.float?({{key.id.stringify}})
    end

    def {{(m || key.id).stringify.gsub(/\//, "_").id}}
      self.float({{key.id.stringify}})
    end

    def {{(m || key.id).stringify.gsub(/\//, "_").id}}=(v : Float64)
      @paths[{{key.id.stringify}}] = v
    end

    def {{(m || key.id).stringify.gsub(/\//, "_").id}}=(v : Nil)
    end
  end

  macro as_hash(key, m = nil)
    {% method = (m || key.id).stringify.gsub(/\//, "_").id %}
    def {{method}}?
      self.as_hash?({{key.id.stringify}})
    end

    def {{method}}
      self.as_hash({{key.id.stringify}})
    end
  end
  
  ######################################################################
  ### Internal Functions
  
  protected def not_found(key)
    raise NotFound.new("toml[%s] is not found" % key)
  end

  private def build_path(toml, path)
    if toml.is_a?(Hash)
      toml.each do |(key, val)|
        build_path(val, path.empty? ? key : "#{path}/#{key}")
      end
    end
    @paths[path] = toml
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
