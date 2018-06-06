return {
    version = "1.0.0.0",
	service = {
		agentpool = {maxnum = 10, recyremove = 1, brokecachelen = 1,}, 
		gateway = {maxclient = 1024, nodelay = true},
		mysql={
			maxnum=10,
			servicename="mysqlService",
			connection={host="127.0.0.1",port=3306,database="test",user="root",password="password"}
		}
    } 
}
