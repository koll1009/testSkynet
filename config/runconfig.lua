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
				host="192.168.50.191",
				port=8081,
				nodename="loginserver",
				servicename="login",
				multilogin=false,
				instance=8,
				hbinterval=500
			},
			gameserver={ 
				address="192.168.50.191",
				port=8082,
				nodename="gameserver1",
				servicename="gamegate1"
			},	
		}
    } 
}
