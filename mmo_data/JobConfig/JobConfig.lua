-- DO NOT EDIT
-- Generated by Exporter
-- Version: 2.8.11
JobConfig = {}

local _datas = 
{
	{ ID = "1", Professional = "狂剑士", ProfessionalAction = "", ProfessionalSkills = {  } 	},
	{ ID = "2", Professional = "神射手", ProfessionalAction = "", ProfessionalSkills = {  } 	},
	{ ID = "3", Professional = "守护者", ProfessionalAction = "ctrl_03", ProfessionalSkills = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14 } 	},
	{ ID = "4", Professional = "魔导师", ProfessionalAction = "", ProfessionalSkills = {  } 	},
	{ ID = "5", Professional = "圣职者", ProfessionalAction = "", ProfessionalSkills = {  } 	}
}


-- ID
JobConfig.datas = {}
for _, rec in pairs(_datas) do
	JobConfig.datas[rec.ID] = rec
end

function JobConfig.getByID(ID)
	return JobConfig.datas[ID]
end
