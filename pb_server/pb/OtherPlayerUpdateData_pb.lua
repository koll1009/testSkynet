-- Generated By protoc-gen-lua Do not Edit
local protobuf = require('protobuf/protobuf')
local Position_pb = require('pb/Position_pb')


local OTHERPLAYERUPDATEDATA = protobuf.Descriptor();
local OTHERPLAYERUPDATEDATA_PLAYERID_FIELD = protobuf.FieldDescriptor();
local OTHERPLAYERUPDATEDATA_POSITION_FIELD = protobuf.FieldDescriptor();

OTHERPLAYERUPDATEDATA_PLAYERID_FIELD.name = "playerId"
OTHERPLAYERUPDATEDATA_PLAYERID_FIELD.full_name = ".Nas.WorldProto.OtherPlayerUpdateData.playerId"
OTHERPLAYERUPDATEDATA_PLAYERID_FIELD.number = 1
OTHERPLAYERUPDATEDATA_PLAYERID_FIELD.index = 0
OTHERPLAYERUPDATEDATA_PLAYERID_FIELD.label = 1
OTHERPLAYERUPDATEDATA_PLAYERID_FIELD.has_default_value = false
OTHERPLAYERUPDATEDATA_PLAYERID_FIELD.default_value = ""
OTHERPLAYERUPDATEDATA_PLAYERID_FIELD.type = 9
OTHERPLAYERUPDATEDATA_PLAYERID_FIELD.cpp_type = 9

OTHERPLAYERUPDATEDATA_POSITION_FIELD.name = "position"
OTHERPLAYERUPDATEDATA_POSITION_FIELD.full_name = ".Nas.WorldProto.OtherPlayerUpdateData.position"
OTHERPLAYERUPDATEDATA_POSITION_FIELD.number = 2
OTHERPLAYERUPDATEDATA_POSITION_FIELD.index = 1
OTHERPLAYERUPDATEDATA_POSITION_FIELD.label = 1
OTHERPLAYERUPDATEDATA_POSITION_FIELD.has_default_value = false
OTHERPLAYERUPDATEDATA_POSITION_FIELD.default_value = nil
OTHERPLAYERUPDATEDATA_POSITION_FIELD.message_type = Position_pb.POSITION
OTHERPLAYERUPDATEDATA_POSITION_FIELD.type = 11
OTHERPLAYERUPDATEDATA_POSITION_FIELD.cpp_type = 10

OTHERPLAYERUPDATEDATA.name = "OtherPlayerUpdateData"
OTHERPLAYERUPDATEDATA.full_name = ".Nas.WorldProto.OtherPlayerUpdateData"
OTHERPLAYERUPDATEDATA.nested_types = {}
OTHERPLAYERUPDATEDATA.enum_types = {}
OTHERPLAYERUPDATEDATA.fields = {OTHERPLAYERUPDATEDATA_PLAYERID_FIELD, OTHERPLAYERUPDATEDATA_POSITION_FIELD}
OTHERPLAYERUPDATEDATA.is_extendable = false
OTHERPLAYERUPDATEDATA.extensions = {}

local OtherPlayerUpdateData = protobuf.Message(OTHERPLAYERUPDATEDATA)

return OtherPlayerUpdateData