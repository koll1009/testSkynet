-- DO NOT EDIT
-- Generated by Exporter
-- Version: 2.8.11
InitialInformationConfig = {}

InitialInformationConfig.datas = 
{
	{ ID = "1", Name = "女", Model = "mod_00_001f", Sex = 1, Level = 1, Exp = 0, Gold = 0, Diamond = 0, GoldBond = 0, BagContent = 18, DepotContent = 24, BaseStr = 10, BaseDex = 10, BaseCon = 10, BaseInt = 10, BaseSpi = 10, BaseHp = 0, BaseSp = 0, BaseAtk = 0, BaseMgk = 0, BaseDef = 0, BaseRgs = 0, BaseCri = 0, BaseGr = 0, BaseCsd = 0, BaseHit = 0, BaseRtd = 0, BaseBel = 0, BaseCur = 0, BaseTou = 0, BaseHprq = 0, BaseSprq = 0, BaseWsp = 0, BaseCs = 0, BaseMov = 0, BaseGatk = 0, BaseWatk = 0, BaseFatk = 0, BaseWdatk = 0, BaseGrst = 0, BaseWrst = 0, BaseFrst = 0, BaseWdrst = 0 	},
	{ ID = "2", Name = "男", Model = "mod_00_001m", Sex = 2, Level = 1, Exp = 0, Gold = 0, Diamond = 0, GoldBond = 0, BagContent = 18, DepotContent = 24, BaseStr = 10, BaseDex = 10, BaseCon = 10, BaseInt = 10, BaseSpi = 10, BaseHp = 0, BaseSp = 0, BaseAtk = 0, BaseMgk = 0, BaseDef = 0, BaseRgs = 0, BaseCri = 0, BaseGr = 0, BaseCsd = 0, BaseHit = 0, BaseRtd = 0, BaseBel = 0, BaseCur = 0, BaseTou = 0, BaseHprq = 0, BaseSprq = 0, BaseWsp = 0, BaseCs = 0, BaseMov = 0, BaseGatk = 0, BaseWatk = 0, BaseFatk = 0, BaseWdatk = 0, BaseGrst = 0, BaseWrst = 0, BaseFrst = 0, BaseWdrst = 0 	}
}


-- ID
InitialInformationConfig._datas = {}
for _, rec in pairs(InitialInformationConfig.datas) do
	InitialInformationConfig._datas[rec.ID] = rec
end

function InitialInformationConfig.getByID(ID)
	return InitialInformationConfig._datas[ID]
end
