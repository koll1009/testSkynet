return {
    version = "1.0.0.0",
	service = {
		agentpool = {maxnum = 10, recyremove = 1, brokecachelen = 1,}, 
		gateway = {maxclient = 1024, nodelay = true},
		mysql={
			maxnum=10,
			servicename="mysqlService",
			connection={ host="127.0.0.1",port=3306,database="test",user="root",password="password" }
		},
		redis={
			maxnum=10,
			servicename="redisService",
			connection= { host="127.0.0.1",port=6379 }
		},
		server={
			loginserver={
				host="127.0.0.1",
				port=8081,
				name="loginserver",
				multilogin=false,
				instance=8
			},
			gameserver={ 
				[1]={
					address="127.0.0.1",
					port=8082,
					name="gameserver1"
				},
				[2]={
					address="127.0.0.1",
					port=8083,
					name="gameserver2"
				}
			}	
		}
    } 
}
