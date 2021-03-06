// Generated by tabtoy
// Version: 2.8.11
// DO NOT EDIT!!
using System.Collections.Generic;

namespace NasData
{
	
	

	// Defined in table: FixedRuleList
	
	public partial class FixedRuleList : tabtoy._BaseConfig
	{
	
		public tabtoy.Logger TableLogger = new tabtoy.Logger();
	
		
		/// <summary> 
		/// FixedRuleList
		/// </summary>
		public List<FixedRuleListDefine> Datas = new List<FixedRuleListDefine>(); 
	
	
		#region Index code
	 	Dictionary<string, FixedRuleListDefine> _ByID = new Dictionary<string, FixedRuleListDefine>();
        public FixedRuleListDefine GetByID(string ID, FixedRuleListDefine def = default(FixedRuleListDefine))
        {
            FixedRuleListDefine ret;
            if ( _ByID.TryGetValue( ID, out ret ) )
            {
                return ret;
            }
			
			if ( def == default(FixedRuleListDefine) )
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
		
		public static void Deserialize( FixedRuleList ins, System.IO.Stream stream )
        {
            tabtoy.DataReader reader = new tabtoy.DataReader(stream);
            if (!reader.ReadHeader())
            {
                throw new System.Exception(string.Format("Deserialize failed: {0}", ins.GetType()));
            }
            Deserialize(ins, reader);
        }
		static tabtoy.DeserializeHandler<FixedRuleList> _FixedRuleListDeserializeHandler;
		static tabtoy.DeserializeHandler<FixedRuleList> FixedRuleListDeserializeHandler
		{
			get
			{
				if (_FixedRuleListDeserializeHandler == null )
				{
					_FixedRuleListDeserializeHandler = new tabtoy.DeserializeHandler<FixedRuleList>(Deserialize);
				}

				return _FixedRuleListDeserializeHandler;
			}
		}
		public static void Deserialize( FixedRuleList ins, tabtoy.DataReader reader )
		{
			
 			int tag = -1;
            while ( -1 != (tag = reader.ReadTag()))
            {
                switch (tag)
                { 
                	case 0xa0000:
                	{
						ins.Datas.Add( reader.ReadStruct<FixedRuleListDefine>(FixedRuleListDefineDeserializeHandler) );
                	}
                	break; 
                }
             } 

			
			// Build FixedRuleList Index
			for( int i = 0;i< ins.Datas.Count;i++)
			{
				var element = ins.Datas[i];
				
				ins._ByID.Add(element.ID, element);
				
			}
			
		}
		public static void Deserialize( FixedRuleListDefine ins, System.IO.Stream stream )
        {
            tabtoy.DataReader reader = new tabtoy.DataReader(stream);
            if (!reader.ReadHeader())
            {
                throw new System.Exception(string.Format("Deserialize failed: {0}", ins.GetType()));
            }
            Deserialize(ins, reader);
        }
		static tabtoy.DeserializeHandler<FixedRuleListDefine> _FixedRuleListDefineDeserializeHandler;
		static tabtoy.DeserializeHandler<FixedRuleListDefine> FixedRuleListDefineDeserializeHandler
		{
			get
			{
				if (_FixedRuleListDefineDeserializeHandler == null )
				{
					_FixedRuleListDefineDeserializeHandler = new tabtoy.DeserializeHandler<FixedRuleListDefine>(Deserialize);
				}

				return _FixedRuleListDefineDeserializeHandler;
			}
		}
		public static void Deserialize( FixedRuleListDefine ins, tabtoy.DataReader reader )
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
                	case 0x10001:
                	{
						ins.ParamType = reader.ReadInt32();
                	}
                	break; 
                	case 0x50002:
                	{
						ins.Value = reader.ReadFloat();
                	}
                	break; 
                }
             } 

			
		}
		#endregion
	

	} 

	// Defined in table: FixedRuleListDefine
	[System.Serializable]
	public partial class FixedRuleListDefine : tabtoy._BaseConfig
	{
	
		
		/// <summary> 
		/// 唯一ID（索引加MakeIndex:true）
		/// </summary>
		public string ID = ""; 
		
		/// <summary> 
		/// 参数类型
		/// </summary>
		public int ParamType = 0; 
		
		/// <summary> 
		/// 参数值
		/// </summary>
		public float Value = 0f; 
	
	

	} 

}
