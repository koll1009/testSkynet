using System;
using System.Collections;
using System.Collections.Generic;
using System.Reflection;
using System.Text;
 
using Rinin;
 

namespace Rinin
{

    public class NetworkCenter  
    {
        private NetworkClient client;
        public NetworkCenter()
        {
            client = new NetworkClient();
        }
        public bool Connect(string host, int port)
        {
            return client.Connect(host, port);
        }
        public bool ReConnect(string host, int port)
        {
            this.client.Close();
            return this.client.Connect(host, port);
        }
        public void close()
        {
            this.client.Close();
        }
        public void Send(int proto, byte[] data)
        {
            byte[] pack = new byte[data.Length + sizeof(int)];
            byte[] bproto = BitConverter.GetBytes(proto);
            Buffer.BlockCopy(bproto, 0, pack, 0, sizeof(int));
            Buffer.BlockCopy(data, 0, pack, sizeof(int), data.Length);
            this.client.SendPackage(pack);
        }
        public void  Recv(NetworkCallback callback)
        {
            this.client.RecvPackage(callback);
        }
        public event NetworkCallback loginCompleted;
        public event NetworkCallback connGameServerCompleted;
        public void Login(string token)
        {
            this.token = token;
            try
            {
                client.RecvCompleted += Client_RecvCompleted;
                client.SendCompleted += Client_SendCompleted;
                this.recvState = Erecv.RECVCHALLENGE;
                this.sendstate = Esend.SENDCLIENTDH;
                client.RecvPackage();
            }
            catch
            {

            }
        }

        #region login

        private enum Erecv
        {
            RECVCHALLENGE=0,   
            RECVSERVERDH,
            RECVSERVERS,


            RECVNUM
        }
        private enum Esend
        {
            SENDCLIENTDH = 0,
            SENDCHALLENGE,
            SENDTOKEN,

            SENDNUM
        }
        private string[] recvMethodName = { "recvChallenge", "recvServerDH", "recvServers" };
        private string[] sendMethodName = { "sendClientDH", "sendChallenge", "sendToken" };
        private Erecv recvState;
        private Esend sendstate;
        private byte[] buffer;
        private const int TCPPACKSIZE = 2;
        private byte[] challenge;
        private ulong clientkey;
        private ulong serverDH;
        private ulong secret;
        private string token;

        private void sendClientDH(NetworkIOArgs args)
        {
            this.sendstate = Esend.SENDCHALLENGE;
            this.client.RecvPackage();
        }
        private void sendChallenge(NetworkIOArgs args)
        {
            this.client.SendPackage(Convert.ToBase64String(kcrypt.DesEncrypt(Encoding.UTF8.GetBytes(this.token))));
            this.sendstate = Esend.SENDTOKEN;
        }
        private void sendToken(NetworkIOArgs args)
        {
            this.client.RecvPackage();
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

        private void recvServers(NetworkIOArgs args)
        {
            client.RecvCompleted -= Client_RecvCompleted;
            client.SendCompleted -= Client_SendCompleted;
            this.token = null;
            NetworkCallback temp = loginCompleted;
            if (temp != null)
                temp(args);
        }

        private void recvServerDH(NetworkIOArgs args)
        {
           // Debug.Log(string.Format("serverDH is {0}", Encoding.UTF8.GetString(args.Data, 0, args.Count)));
            this.serverDH = BitConverter.ToUInt64(Convert.FromBase64String(Encoding.UTF8.GetString(args.Data, 0, args.Count)), 0);
            Array.Clear(args.Data, 0, args.Count);

            this.recvState = Erecv.RECVSERVERS;
            this.secret = kcrypt.dhsecret(this.serverDH, this.clientkey);
           // Debug.Log(string.Format("serverDH is {0}", Convert.ToBase64String(BitConverter.GetBytes(this.secret))));
            kcrypt.SetDesKey(secret);
            ulong sChall = kcrypt.hmac64(BitConverter.ToUInt64(this.challenge, 0), this.secret);
            client.SendPackage(Convert.ToBase64String(BitConverter.GetBytes(sChall)));
        }

        private void recvChallenge(NetworkIOArgs args)
        {
            this.challenge = Convert.FromBase64String(Encoding.UTF8.GetString(args.Data, 0, args.Count));

            Array.Clear(args.Data, 0, args.Count);
            this.recvState = Erecv.RECVSERVERDH;
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
        #endregion

        #region connect game server
  
        public void ConnectGameServer(string uid,string sid,string sdkid) {
            string handshake = string.Format("{0}@{1}#{2}", kcrypt.Encode64Str(uid), kcrypt.Encode64Str(sid), kcrypt.Encode64Str(sdkid));
            byte[] bhs=kcrypt.Hash(Encoding.UTF8.GetBytes(handshake));
            string hmac=kcrypt.encode64str(kcrypt.hmac64(BitConverter.ToUInt64(bhs,0), this.secret));
            byte[] data = System.Text.Encoding.UTF8.GetBytes(handshake);
            byte[] bhmac = System.Text.Encoding.UTF8.GetBytes(hmac);
            byte[] pack = new byte[bhmac.Length + data.Length+1];
            Buffer.BlockCopy(data, 0, pack,0, data.Length);
            pack[data.Length]=(byte)':';
            Buffer.BlockCopy(bhmac, 0, pack,data.Length+1,  bhmac.Length);
            this.client.SendPackage(pack, (args) =>
            {
                this.client.RecvPackage(connGameServerCompleted);
            });

        }

        #endregion

    }

}