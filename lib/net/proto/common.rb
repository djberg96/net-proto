require 'ffi'

module Net
  class Proto
    extend FFI::Library

    class ProtocolStruct < FFI::Struct
      layout(
        :p_name,    :string,
        :p_aliases, :pointer,
        :p_proto,   :int
      )
    end

    class FFI::Pointer
      def read_array_of_string
        elements = []

        loc = self

        until ((element = loc.read_pointer).null?)
          elements << element.read_string
          loc += FFI::Type::POINTER.size
        end

        elements
      end
    end

    ProtoStruct = Struct.new('ProtoStruct', :name, :aliases, :proto)
  end
end