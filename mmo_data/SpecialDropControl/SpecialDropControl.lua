-- DO NOT EDIT
-- Generated by Exporter
-- Version: 2.8.11
SpecialDropControl = {}

local _datas = 
{
	{ ID = "SDR_001", SeedType = 2, max = 2, DailyDropLimit = 2, DropLimit = 2, MemoryLimit = 2 	}
}


-- ID
SpecialDropControl.datas = {}
for _, rec in pairs(_datas) do
	SpecialDropControl.datas[rec.ID] = rec
end

function SpecialDropControl.getByID(ID)
	return SpecialDropControl.datas[ID]
end
