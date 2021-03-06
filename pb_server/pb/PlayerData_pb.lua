-- Generated By protoc-gen-lua Do not Edit
local protobuf = require('protobuf/protobuf')


local PLAYERDATA = protobuf.Descriptor();
local PLAYERDATA_PLAYERID_FIELD = protobuf.FieldDescriptor();
local PLAYERDATA_SEX_FIELD = protobuf.FieldDescriptor();
local PLAYERDATA_HAIDCOLOR_FIELD = protobuf.FieldDescriptor();
local PLAYERDATA_EYESCOLOR_FIELD = protobuf.FieldDescriptor();
local PLAYERDATA_BODYCOLOR_FIELD = protobuf.FieldDescriptor();

PLAYERDATA_PLAYERID_FIELD.name = "playerId"
PLAYERDATA_PLAYERID_FIELD.full_name = ".Nas.WorldProto.PlayerData.playerId"
PLAYERDATA_PLAYERID_FIELD.number = 1
PLAYERDATA_PLAYERID_FIELD.index = 0
PLAYERDATA_PLAYERID_FIELD.label = 1
PLAYERDATA_PLAYERID_FIELD.has_default_value = false
PLAYERDATA_PLAYERID_FIELD.default_value = ""
PLAYERDATA_PLAYERID_FIELD.type = 9
PLAYERDATA_PLAYERID_FIELD.cpp_type = 9

PLAYERDATA_SEX_FIELD.name = "sex"
PLAYERDATA_SEX_FIELD.full_name = ".Nas.WorldProto.PlayerData.sex"
PLAYERDATA_SEX_FIELD.number = 2
PLAYERDATA_SEX_FIELD.index = 1
PLAYERDATA_SEX_FIELD.label = 1
PLAYERDATA_SEX_FIELD.has_default_value = false
PLAYERDATA_SEX_FIELD.default_value = 0
PLAYERDATA_SEX_FIELD.type = 5
PLAYERDATA_SEX_FIELD.cpp_type = 1

PLAYERDATA_HAIDCOLOR_FIELD.name = "haidColor"
PLAYERDATA_HAIDCOLOR_FIELD.full_name = ".Nas.WorldProto.PlayerData.haidColor"
PLAYERDATA_HAIDCOLOR_FIELD.number = 3
PLAYERDATA_HAIDCOLOR_FIELD.index = 2
PLAYERDATA_HAIDCOLOR_FIELD.label = 1
PLAYERDATA_HAIDCOLOR_FIELD.has_default_value = false
PLAYERDATA_HAIDCOLOR_FIELD.default_value = ""
PLAYERDATA_HAIDCOLOR_FIELD.type = 9
PLAYERDATA_HAIDCOLOR_FIELD.cpp_type = 9

PLAYERDATA_EYESCOLOR_FIELD.name = "eyesColor"
PLAYERDATA_EYESCOLOR_FIELD.full_name = ".Nas.WorldProto.PlayerData.eyesColor"
PLAYERDATA_EYESCOLOR_FIELD.number = 4
PLAYERDATA_EYESCOLOR_FIELD.index = 3
PLAYERDATA_EYESCOLOR_FIELD.label = 1
PLAYERDATA_EYESCOLOR_FIELD.has_default_value = false
PLAYERDATA_EYESCOLOR_FIELD.default_value = ""
PLAYERDATA_EYESCOLOR_FIELD.type = 9
PLAYERDATA_EYESCOLOR_FIELD.cpp_type = 9

PLAYERDATA_BODYCOLOR_FIELD.name = "bodyColor"
PLAYERDATA_BODYCOLOR_FIELD.full_name = ".Nas.WorldProto.PlayerData.bodyColor"
PLAYERDATA_BODYCOLOR_FIELD.number = 5
PLAYERDATA_BODYCOLOR_FIELD.index = 4
PLAYERDATA_BODYCOLOR_FIELD.label = 1
PLAYERDATA_BODYCOLOR_FIELD.has_default_value = false
PLAYERDATA_BODYCOLOR_FIELD.default_value = ""
PLAYERDATA_BODYCOLOR_FIELD.type = 9
PLAYERDATA_BODYCOLOR_FIELD.cpp_type = 9

PLAYERDATA.name = "PlayerData"
PLAYERDATA.full_name = ".Nas.WorldProto.PlayerData"
PLAYERDATA.nested_types = {}
PLAYERDATA.enum_types = {}
PLAYERDATA.fields = {PLAYERDATA_PLAYERID_FIELD, PLAYERDATA_SEX_FIELD, PLAYERDATA_HAIDCOLOR_FIELD, PLAYERDATA_EYESCOLOR_FIELD, PLAYERDATA_BODYCOLOR_FIELD}
PLAYERDATA.is_extendable = false
PLAYERDATA.extensions = {}

local PlayerData = protobuf.Message(PLAYERDATA)

return PlayerData