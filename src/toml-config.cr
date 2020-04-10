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
  ### Basic API
  
  def [](key)
    key = key.to_s
    @paths.fetch(key) { not_found(key) }
  end

  def []?(key)
    key = key.to_s
    @paths.fetch(key) { nil }
  end

  def []=(key, val)
    key = key.to_s
    @paths[key] = val
  end

  ######################################################################
  ### Typed API
  
  def as_hash(key : String) : Hash
    self[key].as(Hash)
  end

  def as_hash?(key : String)
    self[key]?.try(&.as(Hash))
  end

  ######################################################################
  ### DSL macros

  TYPE_MAPS = [
    # api_name  class      typed
    {"bool", "Bool"   , true},
    {"str" , "String" , true},
    {"i32" , "Int32"  , true},
    {"i64" , "Int64"  , true},
    {"f32" , "Float32", true},
    {"f64" , "Float64", true},
  ]

  {% for tuple in TYPE_MAPS %}
    {%
      type_s           = tuple[0]
      klass_s          = tuple[1]
      define_typed_api = tuple[2]

      type      = type_s.id
      klass     = klass_s.id
      is32      = type_s =~ /32$/
      klass64   = klass_s.gsub(/32/, "64").id
      to_32     = ("to_" + type_s[0..0] + "32").id
      to_64     = ("to_" + type_s[0..0] + "64").id
      down_cast = (is32 ? ".as(#{klass64}).#{to_32}" : ".as(#{klass})").id
      up_cast   = (is32 ? ".#{to_64}" : "").id
    %}

    {% if define_typed_api %}
      ######################################################################
      ### Typed API
  
      # def str(key) : String
      #   self[key].as(String)
      # end
      def {{type}}(key) : {{klass}}
        self[key]{{down_cast}}
      end

      # def str?(key) : String?
      #   self.str(key)
      # rescue NotFound
      #   nil
      # end
      def {{type}}?(key) : {{klass}}?
        self.{{type}}(key)
      rescue NotFound
        nil
      end

      # def strs(key) : Array(String)
      #   self[key].as(Array).map(&.to_s).as(Array(String))
      # end
      def {{type}}s(key) : Array({{klass}})
        self[key].as(Array).map(&{{down_cast}}).as(Array({{klass}}))
      end

      # def strs?(key) : Array(String)?
      #   self.strs(key)
      # rescue NotFound
      #   nil
      # end
      def {{type}}s?(key) : Array({{klass}})?
        self.{{type}}s(key)
      rescue NotFound
        nil
      end
    {% end %}

    ######################################################################
    ### DSL API

    # ```crystal
    # bool "verbose"
    # str  "redis/host"
    # int  "redis/db", db
    # ```
    macro {{type}}(key, m = nil)
      \{%
        method_s = (m || key.id).stringify.gsub(/\//, "_")
        method   = method_s.id
        key_s    = key.id.stringify
      %}

      \{% if method_s != {{type_s}} %}
      def \{{method}}?
        self.{{type}}?(\{{key_s}})
      end
                                 
      def \{{method}}
        self.{{type}}(\{{key_s}})
      end
      \{% end %}

      def \{{method}}=(v : {{klass}})
        @paths[\{{key_s}}] = v{{up_cast}}
      end

      def \{{method}}=(v : Nil)
      end
    end

    # ```crystal
    # strs "layouts"
    # ```
    macro {{type}}s(key, m = nil)
      \{%
        method_s = (m || key.id).stringify.gsub(/\//, "_")
        method   = method_s.id
        key_s    = key.id.stringify
      %}

      def \{{method}}?
        self.{{type}}s?(\{{key_s}})
      end
                                 
      def \{{method}}
        self.{{type}}s(\{{key_s}})
      end

      def \{{method}}=(v : {{klass}})
        @paths[\{{key}}] = v
      end

      def \{{method}}=(v : Nil)
      end
    end
  {% end %}

  macro as_hash(key, m = nil)
    {%
      method = (m || key.id).stringify.gsub(/\//, "_").id
      key_s = key.id.stringify
    %}
    
    def {{method}}?
      self.as_hash?({{key_s}})
    end

    def {{method}}
      self.as_hash({{key_s}})
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
