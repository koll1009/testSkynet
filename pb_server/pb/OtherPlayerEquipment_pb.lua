-- Generated By protoc-gen-lua Do not Edit
local protobuf = require('protobuf/protobuf')


local OTHERPLAYEREQUIPMENT = protobuf.Descriptor();
local OTHERPLAYEREQUIPMENT_PLAYERID_FIELD = protobuf.FieldDescriptor();
local OTHERPLAYEREQUIPMENT_EQUIPID_FIELD = protobuf.FieldDescriptor();
local OTHERPLAYEREQUIPMENT_EQUIPPART_FIELD = protobuf.FieldDescriptor();

OTHERPLAYEREQUIPMENT_PLAYERID_FIELD.name = "playerId"
OTHERPLAYEREQUIPMENT_PLAYERID_FIELD.full_name = ".Nas.WorldProto.OtherPlayerEquipment.playerId"
OTHERPLAYEREQUIPMENT_PLAYERID_FIELD.number = 1
OTHERPLAYEREQUIPMENT_PLAYERID_FIELD.index = 0
OTHERPLAYEREQUIPMENT_PLAYERID_FIELD.label = 1
OTHERPLAYEREQUIPMENT_PLAYERID_FIELD.has_default_value = false
OTHERPLAYEREQUIPMENT_PLAYERID_FIELD.default_value = ""
OTHERPLAYEREQUIPMENT_PLAYERID_FIELD.type = 9
OTHERPLAYEREQUIPMENT_PLAYERID_FIELD.cpp_type = 9

OTHERPLAYEREQUIPMENT_EQUIPID_FIELD.name = "equipId"
OTHERPLAYEREQUIPMENT_EQUIPID_FIELD.full_name = ".Nas.WorldProto.OtherPlayerEquipment.equipId"
OTHERPLAYEREQUIPMENT_EQUIPID_FIELD.number = 2
OTHERPLAYEREQUIPMENT_EQUIPID_FIELD.index = 1
OTHERPLAYEREQUIPMENT_EQUIPID_FIELD.label = 1
OTHERPLAYEREQUIPMENT_EQUIPID_FIELD.has_default_value = false
OTHERPLAYEREQUIPMENT_EQUIPID_FIELD.default_value = ""
OTHERPLAYEREQUIPMENT_EQUIPID_FIELD.type = 9
OTHERPLAYEREQUIPMENT_EQUIPID_FIELD.cpp_type = 9

OTHERPLAYEREQUIPMENT_EQUIPPART_FIELD.name = "equipPart"
OTHERPLAYEREQUIPMENT_EQUIPPART_FIELD.full_name = ".Nas.WorldProto.OtherPlayerEquipment.equipPart"
OTHERPLAYEREQUIPMENT_EQUIPPART_FIELD.number = 3
OTHERPLAYEREQUIPMENT_EQUIPPART_FIELD.index = 2
OTHERPLAYEREQUIPMENT_EQUIPPART_FIELD.label = 1
OTHERPLAYEREQUIPMENT_EQUIPPART_FIELD.has_default_value = false
OTHERPLAYEREQUIPMENT_EQUIPPART_FIELD.default_value = 0
OTHERPLAYEREQUIPMENT_EQUIPPART_FIELD.type = 5
OTHERPLAYEREQUIPMENT_EQUIPPART_FIELD.cpp_type = 1

OTHERPLAYEREQUIPMENT.name = "OtherPlayerEquipment"
OTHERPLAYEREQUIPMENT.full_name = ".Nas.WorldProto.OtherPlayerEquipment"
OTHERPLAYEREQUIPMENT.nested_types = {}
OTHERPLAYEREQUIPMENT.enum_types = {}
OTHERPLAYEREQUIPMENT.fields = {OTHERPLAYEREQUIPMENT_PLAYERID_FIELD, OTHERPLAYEREQUIPMENT_EQUIPID_FIELD, OTHERPLAYEREQUIPMENT_EQUIPPART_FIELD}
OTHERPLAYEREQUIPMENT.is_extendable = false
OTHERPLAYEREQUIPMENT.extensions = {}

local OtherPlayerEquipment = protobuf.Message(OTHERPLAYEREQUIPMENT)

return OtherPlayerEquipment