-- Generated By protoc-gen-lua Do not Edit
local protobuf = require('protobuf/protobuf')


local POSITION = protobuf.Descriptor();
local POSITION_X_FIELD = protobuf.FieldDescriptor();
local POSITION_Y_FIELD = protobuf.FieldDescriptor();
local POSITION_Z_FIELD = protobuf.FieldDescriptor();
local POSITION_O_FIELD = protobuf.FieldDescriptor();

POSITION_X_FIELD.name = "x"
POSITION_X_FIELD.full_name = ".Nas.WorldProto.Position.x"
POSITION_X_FIELD.number = 1
POSITION_X_FIELD.index = 0
POSITION_X_FIELD.label = 1
POSITION_X_FIELD.has_default_value = false
POSITION_X_FIELD.default_value = 0.0
POSITION_X_FIELD.type = 2
POSITION_X_FIELD.cpp_type = 6

POSITION_Y_FIELD.name = "y"
POSITION_Y_FIELD.full_name = ".Nas.WorldProto.Position.y"
POSITION_Y_FIELD.number = 2
POSITION_Y_FIELD.index = 1
POSITION_Y_FIELD.label = 1
POSITION_Y_FIELD.has_default_value = false
POSITION_Y_FIELD.default_value = 0.0
POSITION_Y_FIELD.type = 2
POSITION_Y_FIELD.cpp_type = 6

POSITION_Z_FIELD.name = "z"
POSITION_Z_FIELD.full_name = ".Nas.WorldProto.Position.z"
POSITION_Z_FIELD.number = 3
POSITION_Z_FIELD.index = 2
POSITION_Z_FIELD.label = 1
POSITION_Z_FIELD.has_default_value = false
POSITION_Z_FIELD.default_value = 0.0
POSITION_Z_FIELD.type = 2
POSITION_Z_FIELD.cpp_type = 6

POSITION_O_FIELD.name = "o"
POSITION_O_FIELD.full_name = ".Nas.WorldProto.Position.o"
POSITION_O_FIELD.number = 4
POSITION_O_FIELD.index = 3
POSITION_O_FIELD.label = 1
POSITION_O_FIELD.has_default_value = false
POSITION_O_FIELD.default_value = 0.0
POSITION_O_FIELD.type = 2
POSITION_O_FIELD.cpp_type = 6

POSITION.name = "Position"
POSITION.full_name = ".Nas.WorldProto.Position"
POSITION.nested_types = {}
POSITION.enum_types = {}
POSITION.fields = {POSITION_X_FIELD, POSITION_Y_FIELD, POSITION_Z_FIELD, POSITION_O_FIELD}
POSITION.is_extendable = false
POSITION.extensions = {}

local Position = protobuf.Message(POSITION)
Position.POSITION=POSITION

return Position