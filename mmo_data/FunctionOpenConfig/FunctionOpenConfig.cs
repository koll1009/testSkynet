// Generated by tabtoy
// Version: 2.8.11
// DO NOT EDIT!!
using System.Collections.Generic;

namespace NasData
{
	
	

	// Defined in table: FunctionOpenConfig
	
	public partial class FunctionOpenConfig : tabtoy._BaseConfig
	{
	
		public tabtoy.Logger TableLogger = new tabtoy.Logger();
	
		
		/// <summary> 
		/// FunctionOpenConfig
		/// </summary>
		public List<FunctionOpenConfigDefine> Datas = new List<FunctionOpenConfigDefine>(); 
	
	
		#region Index code
	 	Dictionary<string, FunctionOpenConfigDefine> _ByID = new Dictionary<string, FunctionOpenConfigDefine>();
        public FunctionOpenConfigDefine GetByID(string ID, FunctionOpenConfigDefine def = default(FunctionOpenConfigDefine))
        {
            FunctionOpenConfigDefine ret;
            if ( _ByID.TryGetValue( ID, out ret ) )
            {
                return ret;
            }
			
			if ( def == default(FunctionOpenConfigDefine) )
			{
				TableLogger.ErrorLine("GetByID failed, ID: {0}", ID);
			}

            return def;
        }
		
	
		#endregion
		#region Deserialize code
		public override void Deserialize(System.IO.Stream stream)
        {
            Deserialize(this, stream);
        }
		
		public static void Deserialize( FunctionOpenConfig ins, System.IO.Stream stream )
        {
            tabtoy.DataReader reader = new tabtoy.DataReader(stream);
            if (!reader.ReadHeader())
            {
                throw new System.Exception(string.Format("Deserialize failed: {0}", ins.GetType()));
            }
            Deserialize(ins, reader);
        }
		static tabtoy.DeserializeHandler<FunctionOpenConfig> _FunctionOpenConfigDeserializeHandler;
		static tabtoy.DeserializeHandler<FunctionOpenConfig> FunctionOpenConfigDeserializeHandler
		{
			get
			{
				if (_FunctionOpenConfigDeserializeHandler == null )
				{
					_FunctionOpenConfigDeserializeHandler = new tabtoy.DeserializeHandler<FunctionOpenConfig>(Deserialize);
				}

				return _FunctionOpenConfigDeserializeHandler;
			}
		}
		public static void Deserialize( FunctionOpenConfig ins, tabtoy.DataReader reader )
		{
			
 			int tag = -1;
            while ( -1 != (tag = reader.ReadTag()))
            {
                switch (tag)
                { 
                	case 0xa0000:
                	{
						ins.Datas.Add( reader.ReadStruct<FunctionOpenConfigDefine>(FunctionOpenConfigDefineDeserializeHandler) );
                	}
                	break; 
                }
             } 

			
			// Build FunctionOpenConfig Index
			for( int i = 0;i< ins.Datas.Count;i++)
			{
				var element = ins.Datas[i];
				
				ins._ByID.Add(element.ID, element);
				
			}
			
		}
		public static void Deserialize( FunctionOpenConfigDefine ins, System.IO.Stream stream )
        {
            tabtoy.DataReader reader = new tabtoy.DataReader(stream);
            if (!reader.ReadHeader())
            {
                throw new System.Exception(string.Format("Deserialize failed: {0}", ins.GetType()));
            }
            Deserialize(ins, reader);
        }
		static tabtoy.DeserializeHandler<FunctionOpenConfigDefine> _FunctionOpenConfigDefineDeserializeHandler;
		static tabtoy.DeserializeHandler<FunctionOpenConfigDefine> FunctionOpenConfigDefineDeserializeHandler
		{
			get
			{
				if (_FunctionOpenConfigDefineDeserializeHandler == null )
				{
					_FunctionOpenConfigDefineDeserializeHandler = new tabtoy.DeserializeHandler<FunctionOpenConfigDefine>(Deserialize);
				}

				return _FunctionOpenConfigDefineDeserializeHandler;
			}
		}
		public static void Deserialize( FunctionOpenConfigDefine ins, tabtoy.DataReader reader )
		{
			
 			int tag = -1;
            while ( -1 != (tag = reader.ReadTag()))
            {
                switch (tag)
                { 
                	case 0x60000:
                	{
						ins.ID = reader.ReadString();
                	}
                	break; 
                	case 0x60001:
                	{
						ins.Name = reader.ReadString();
                	}
                	break; 
                	case 0x10002:
                	{
						ins.OpenType = reader.ReadInt32();
                	}
                	break; 
                	case 0x10003:
                	{
						ins.OpenLevel = reader.ReadInt32();
                	}
                	break; 
                	case 0x10004:
                	{
						ins.EventId = reader.ReadInt32();
                	}
                	break; 
                	case 0x60005:
                	{
						ins.Icon.Add( reader.ReadString() );
                	}
                	break; 
                	case 0x10006:
                	{
						ins.OpenBoot = reader.ReadInt32();
                	}
                	break; 
                	case 0x60007:
                	{
						ins.ModuleName = reader.ReadString();
                	}
                	break; 
                }
             } 

			
		}
		#endregion
	

	} 

	// Defined in table: FunctionOpenConfigDefine
	[System.Serializable]
	public partial class FunctionOpenConfigDefine : tabtoy._BaseConfig
	{
	
		
		/// <summary> 
		/// 唯一ID（索引加MakeIndex:true）
		/// </summary>
		public string ID = ""; 
		
		/// <summary> 
		/// 系统名
		/// </summary>
		public string Name = ""; 
		
		/// <summary> 
		/// 开启类型
		///0 系统开启
		///1 功能开启
		/// </summary>
		public int OpenType = 0; 
		
		/// <summary> 
		/// 职业等级限制
		/// </summary>
		public int OpenLevel = 0; 
		
		/// <summary> 
		/// 开启事件
		///0 无
		///1 任务开启
		///2 道具开启
		/// </summary>
		public int EventId = 0; 
		
		/// <summary> 
		/// 图标
		///图片,名字
		/// </summary>
		public List<string> Icon = new List<string>(); 
		
		/// <summary> 
		/// 开启引导
		///填引导表ID
		/// </summary>
		public int OpenBoot = 0; 
		
		/// <summary> 
		/// 模块类名
		/// </summary>
		public string ModuleName = ""; 
	
	

	} 

}
