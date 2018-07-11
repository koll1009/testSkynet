using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using Rinin;
using Google.Protobuf;
using System.Net;
using System.Net.Sockets;
using Newtonsoft.Json.Linq;
using Newtonsoft.Json;

namespace client
{
    class param
    {
        public ManualResetEvent e;
        public string u;
        public string p;
        public NetworkCenter c;
    }
    class Program
    {
        static void read(NetWorkArgs arg)
        {
            
            
        }
         static void threadFun(object ob)
        {
            param o = ob as param;
            NetworkCenter c = o.c;
            c.recvCompleted += (arg) =>
            {
                NetworkIOArgs args = arg as NetworkIOArgs;
                if (args.State != NetworkState.Closed)
                {
                    Console.WriteLine(Encoding.UTF8.GetString(args.Data, 0, args.Count));
                    c.Recv();
                }
                else
                {
                    System.Diagnostics.Process.GetCurrentProcess().Kill();
                }
            };
            c.Recv();
        }
 

        static void Main(string[] args)
        {
            long time = DateTime.Now.ToFileTimeUtc();
            int seed = (int)(time ^ (time >> 32));
            Random ran = new Random(seed);
            NetworkCenter login = new NetworkCenter();
            login.Connect("192.168.224.129", 8081);
            login.loginCompleted += (ar) =>
            {
                NetworkIOArgs arg = ar as NetworkIOArgs;
                JObject obj = (JObject)JsonConvert.DeserializeObject(Encoding.UTF8.GetString(arg.Data));

                if (obj["code"].ToString() == "200")
                {
                    JToken servers = obj["servers"];
                    JToken server = servers.First;
                    int port = Convert.ToInt32(server.First["port"].ToString());
                    //string ip = server.First[""].ToString();
                    string uid = obj["uid"].ToString();
                    string sid = obj["sid"].ToString();

                    login.ReConnect("192.168.224.129", 8082);
                    login.connGameServerCompleted += (a) =>
                    {
                        int x = ran.Next(100);
                        int y = ran.Next(100);
                       // int z = ran.Next(100);
                        Thread t = new Thread(threadFun);
                        t.Start(new param() { c=login });
                        //int x = 50;
                        //int y = 50;
                        int z = 0;
                        while (true)
                        {
                            string str = string.Format("{0}:{1}:{2}:45", x, y, z);
                            login.Send(2, Encoding.UTF8.GetBytes(str));
                            Thread.Sleep(1000);
                            if (ran.Next(1024) > (1024 >> 1))
                            {
                               if(x<100) x++;
                            }
                            else
                            {
                                if (x > 0) x--;
                            }
                            if (ran.Next(1024) > (1024 >> 1))
                            {
                                if(y<100)y++;
                            }
                            else
                            {
                                if (y > 0) y--;
                            }
                            //if (ran.Next(1024) > (1024 >> 1))
                            //{
                            //   if(z<100) z++;
                            //}
                            //else
                            //{
                            //    if (z > 0) z--;
                            //}
                        }
                        


                    };
                    login.ConnectGameServer(uid, sid, "123");

                }
            };
            login.Login("koll:123");
            ManualResetEvent e = new ManualResetEvent(false);
            e.WaitOne();
        }     
    }
}
