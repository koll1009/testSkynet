-- DO NOT EDIT
-- Generated by Exporter
-- Version: 2.8.11
MapConfig = {}

local _datas = 
{
	{ ID = 1, Type = 1, Name = "检测更新", Path = "aa/bb", BuilderName = "CheckUpdateSceneBuilder", Loading = { "1", "", "检测更新" } 	},
	{ ID = 2, Type = 1, Name = "登录", Path = "aa/bb", BuilderName = "LoginSceneBuidler", Loading = { "1", "", "登录" } 	},
	{ ID = 3, Type = 1, Name = "创建角色", Path = "aa/bb", BuilderName = "CreateRoleSceneBuilder", Loading = { "1", "", "创建角色" } 	},
	{ ID = 4, Type = 1, Name = "主城", Path = "aa/bb", BuilderName = "MainCitySceneBuilder", Loading = { "1", "", "主城" } 	},
	{ ID = 5, Type = 1, Name = "辽阔草原", Path = "aa/bb", BuilderName = "WildGrassSceneBuilder", Loading = { "1", "", "辽阔草原" } 	}
}


-- ID
MapConfig.datas = {}
for _, rec in pairs(_datas) do
	MapConfig.datas[rec.ID] = rec
end

function MapConfig.getByID(ID)
	return MapConfig.datas[ID]
end
