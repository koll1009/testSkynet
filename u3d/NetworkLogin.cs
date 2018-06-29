using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Rinin;
using System;
using System.Text;
using System.Reflection;

namespace Rinin
{
    public class NetworkLogin
    {
        private enum Erecv
        {
            RECVCHANLLENGECOUNT = 0,
            RECVCHALLENGE,
            RECVSERVERDHCOUNT,
            RECVSERVERDH,

            RECVSERVERSCOUNT,


            RECVNUM
        }
        private enum Esend
        {
            SENDCLIENTDH = 0,
            SENDCHALLENGE,
            SENDTOKEN,

            SENDNUM
        }
        private string[] recvMethodName = { "recvChallengeCount", "recvChallenge", "recvServerDHCount", "recvServerDH" };
        private string[] sendMethodName = { "sendClientDH", "sendChallenge","sendToken" };
        private NetworkClient client;
        private Erecv recvState;
        private Esend sendstate;
        private byte[] buffer;
        private const int TCPPACKSIZE = 2;
        private const int BUFFERSIZE = 1024;
        private byte[] challenge;
        private ulong clientkey;
        private ulong serverDH;
        private ulong secret;
        private string token;
        public event NetworkCallback requestServerCompleted;
        public NetworkLogin()
        {
            client = new NetworkClient();
            this.recvState = Erecv.RECVCHANLLENGECOUNT;
            this.sendstate = Esend.SENDCLIENTDH;
            buffer = new byte[BUFFERSIZE];
        }
        public bool Connect(string host, int port)
        {
            return client.Connect(host, port);
        }
        public void RequestServers(string token)
        {
            this.token = token;
            try
            {
                client.RecvCompleted += Client_RecvCompleted;
                client.SendCompleted += Client_SendCompleted;
                client.Recv(buffer, 0, TCPPACKSIZE);
            }
            catch
            {

            }
        }

        private void sendClientDH(NetworkIOArgs args)
        {
            this.client.Recv(this.buffer, 0, 2);
            this.sendstate = Esend.SENDCHALLENGE;
        }
        private void sendChallenge(NetworkIOArgs args)
        {
            this.client.SendPackage(Convert.ToBase64String(kcrypt.DesEncrypt(Encoding.UTF8.GetBytes(this.token))));
            this.sendstate = Esend.SENDTOKEN;
        }
        private void sendtoken(NetworkIOArgs args)
        {
            NetworkCallback temp = this.requestServerCompleted;
            if (temp != null)
            {
                temp(null);
            }
             
        }

        private void Client_SendCompleted(NetWorkArgs args)
        {
            try
            {
                if (args.State == NetworkState.Sended)
                {
                    NetworkIOArgs arg = args as NetworkIOArgs;
                    Type t = this.GetType();
                    System.Reflection.MethodInfo callback = t.GetMethod(sendMethodName[(int)this.sendstate].Trim(), BindingFlags.NonPublic | BindingFlags.Instance);
                    object[] param = new object[] { arg };
                    callback.Invoke(this, param);
                }
            }
            catch
            {

            }

        }
        private int getBigEndianCount(byte[] data)
        {
            if (data == null || data.Length < 2)
                throw new ArgumentException();
            return data[0] << 8 | data[1];
        }

        private void recvServerDHCount(NetworkIOArgs args)
        {
            int count = this.getBigEndianCount(args.Data);
            if (count < BUFFERSIZE)
            {
                Array.Clear(args.Data, 0, args.Count);
                client.Recv(args.Data, 0, count);
                this.recvState = Erecv.RECVSERVERDH;
            }
        }

        private void recvServerDH(NetworkIOArgs args)
        {
            Debug.Log(string.Format("serverDH is {0}", Encoding.UTF8.GetString(args.Data, 0, args.Count)));
            this.serverDH = BitConverter.ToUInt64(Convert.FromBase64String(Encoding.UTF8.GetString(args.Data, 0, args.Count)),0);
            Array.Clear(args.Data, 0, args.Count);

            this.recvState = Erecv.RECVSERVERSCOUNT;
            this.secret = kcrypt.dhsecret(this.serverDH, this.clientkey);
            Debug.Log(string.Format("serverDH is {0}", Convert.ToBase64String(BitConverter.GetBytes(this.secret))));
            kcrypt.SetDesKey(secret);
            ulong sChall = kcrypt.hmac64(BitConverter.ToUInt64(this.challenge, 0), this.secret);        
            client.SendPackage(Convert.ToBase64String(BitConverter.GetBytes(sChall)));
        }

        private void recvChallengeCount(NetworkIOArgs args)
        {
            int count = this.getBigEndianCount(args.Data);
            if (count < BUFFERSIZE)
            {
                Array.Clear(args.Data, 0, args.Count);
                client.Recv(args.Data, 0, count);
                this.recvState = Erecv.RECVCHALLENGE;
            }
        }

        private void recvChallenge(NetworkIOArgs args)
        {
            this.challenge=Convert.FromBase64String(Encoding.UTF8.GetString(args.Data, 0, args.Count));

            Array.Clear(args.Data, 0, args.Count);
            this.recvState = Erecv.RECVSERVERDHCOUNT;
            byte[] clientkey = kcrypt.randomkey();
            this.clientkey = BitConverter.ToUInt64(clientkey, 0);
            client.SendPackage(kcrypt.encode64str(kcrypt.dhexchange(this.clientkey)));
        }

        private void Client_RecvCompleted(NetWorkArgs args)
        {
            try
            {
                if (args.State == NetworkState.Recved)
                {
                    NetworkIOArgs arg = args as NetworkIOArgs;
                    Type t = this.GetType();
                    MethodInfo callback = t.GetMethod(recvMethodName[(int)this.recvState].Trim(), BindingFlags.NonPublic | BindingFlags.Instance);
                    object[] param = new object[] { arg };
                    callback.Invoke(this, param);
                }
            }
            catch
            {

            }
             
        }
    }

}