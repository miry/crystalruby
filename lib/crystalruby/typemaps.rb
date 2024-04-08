module CrystalRuby
  module Typemaps
    CRYSTAL_TYPE_MAP = {
      :char => "Int8",        # In Crystal, :char is typically represented as Int8
      :uchar => "UInt8",      # Unsigned char
      :int8 => "Int8",        # Same as :char
      :uint8 => "UInt8",      # Same as :uchar
      :short => "Int16",      # Short integer
      :ushort => "UInt16",    # Unsigned short integer
      :int16 => "Int16",      # Same as :short
      :uint16 => "UInt16",    # Same as :ushort
      :int => "Int32",        # Integer, Crystal defaults to 32 bits
      :uint => "UInt32",      # Unsigned integer
      :int32 => "Int32",      # 32-bit integer
      :uint32 => "UInt32",    # 32-bit unsigned integer
      :long => "Int32 | Int64", # Long integer, size depends on the platform (32 or 64 bits)
      :ulong => "UInt32 | UInt64", # Unsigned long integer, size depends on the platform
      :int64 => "Int64",      # 64-bit integer
      :uint64 => "UInt64",    # 64-bit unsigned integer
      :long_long => "Int64",  # Same as :int64
      :ulong_long => "UInt64", # Same as :uint64
      :float => "Float32",    # Floating point number (single precision)
      :double => "Float64",   # Double precision floating point number
      :bool => "Bool",        # Boolean type
      :void => "Void",        # Void type
      :string => "String"     # String type
    }

    C_TYPE_MAP = CRYSTAL_TYPE_MAP.merge({
      :string => "UInt8*"
    })

    C_TYPE_CONVERSIONS = {
      :string => {
        from: "String.new(%s)",
        to: "%s.to_unsafe"
      }
    }
  end
end