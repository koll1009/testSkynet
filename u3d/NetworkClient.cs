﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.Net;
using System.Net.Sockets;
using System;
using System.Text;

namespace Rinin
{
    class NetworkException : ApplicationException

    {
        public NetworkException() { }

        public NetworkException(string message) : base(message) { }

        public NetworkException(string message, Exception inner) : base(message, inner) { }

    }
    public class NetWorkArgs : EventArgs {
        public NetworkState State { get; set; }
        public NetWorkArgs(NetworkState c) {
            this.State = c;
        }
 
    }
    public class NetworkIOArgs : NetWorkArgs
    {
        public byte[] Data { get; set; }
        public int Count { get; set; }
        public bool isAlloc { get; set; }
        public NetworkIOArgs(NetworkState c, byte[] d,int s):base(c)
        {
            this.Data = d;
            this.Count = s;
        }
    }
    public delegate void  NetworkCallback(NetWorkArgs args);
    public enum NetworkState
    {
        Connecting=0,
        Connected,
        DisConnected,
        Recved,
        Sended,
        Closed
    }
    public class NetworkClient
    {
        private TcpClient sock;
        public event NetworkCallback ConnectCompleted;
        public event NetworkCallback RecvCompleted;
        public event NetworkCallback SendCompleted;
        private NetworkState status;
        private const int TCPPACKBYTES=2;
        private const int BUFFERSIZE = 4096;
        private byte[] buffer;
        private bool recvIdle;
        public NetworkClient()
        {
            this.status = NetworkState.DisConnected;
            this.buffer = new byte[BUFFERSIZE];
            this.recvIdle = true;
        }

        public bool  Connect(string host, int port)
        {
            IPAddress addr;
            if (!IPAddress.TryParse(host, out addr))
                return false;
            sock = new TcpClient();
            sock.NoDelay = true;
            sock.Connect(addr, port);
            this.status = NetworkState.Connected;
            return true;
        }
        public bool  ConnectAsyn(string host,int port)
        {
            IPAddress addr;
            if (!IPAddress.TryParse(host, out addr))
                return false;

            sock = new TcpClient();
            sock.NoDelay = true;
            sock.BeginConnect(addr, port, (ar) =>
            {
                TcpClient client = (TcpClient)ar.AsyncState;
                client.EndConnect(ar);
                if (client.Connected)
                    this.status = NetworkState.Connected;
                else
                    this.status = NetworkState.DisConnected;

                NetworkCallback temp = ConnectCompleted;
                if (temp != null)
                    temp(new NetWorkArgs(client.Connected?NetworkState.Connected:NetworkState.DisConnected));

            }, sock);
            this.status = NetworkState.Connecting;
            return true;
        }     
        private class recvObject {
            public byte[] buff;
            public int offet;
            public int size;
            public NetworkStream stream;
            public recvObject(byte[] b, int o, int size, NetworkStream s)
            {
                this.buff = b;
                this.offet = o;
                this.size = size;
                this.stream = s;
            }
        }
        private void recvCallback(IAsyncResult ar)
        {
            try
            {
                NetworkStream s;
                recvObject obj = ar.AsyncState as recvObject;
                s = obj.stream;
                int n = s.EndRead(ar);
                int count = obj.size - obj.offet;

                if (n == 0)
                {
                    this.Close();
                    NetworkCallback temp = RecvCompleted;
                    if (temp != null)
                        temp(new NetworkIOArgs(NetworkState.Closed,null,0));
                }
                else if (n < count)
                {
                    int offet = obj.offet + n;
                    int size = obj.size - offet;
                    s.BeginRead(obj.buff, offet, size, recvCallback, new recvObject(obj.buff, offet, obj.size, s));
                }
                else
                {
                    this.recvIdle = true;
                    NetworkCallback temp = RecvCompleted;
                    if (temp != null)
                        temp(new NetworkIOArgs(NetworkState.Recved, obj.buff, obj.size));
                }
            }
            catch
            {
                this.Close();
            }

        }
        private  void Recv(byte[] buf, int offset,int size)
        {
            if (this.status != NetworkState.Connected)
                throw new NetworkException("NetworkClient:client did not connect server yet");
            NetworkStream sockstream = sock.GetStream();
            sockstream.BeginRead( buf, offset, size, recvCallback, new recvObject(buf, offset, size,sockstream));
        }
        public void RecvPackage()
        {
            if (!this.recvIdle)
                return;
            this.recvIdle = false;

            Array.Clear(this.buffer, 0, BUFFERSIZE);
            NetworkStream stream = this.sock.GetStream();
            stream.BeginRead(this.buffer, 0, TCPPACKBYTES, (ar) => {
                try
                {
                    int n = stream.EndRead(ar);
                    int count;
                    if (n == 0)
                    {
                        this.Close();
                        NetworkCallback temp = RecvCompleted;
                        if (temp != null)
                            temp(new NetworkIOArgs(NetworkState.Closed, null, 0));
                    }
                    else if (n == TCPPACKBYTES)
                    {
                        count = buffer[0] << 8 | buffer[1];
                        Array.Clear(buffer, 0, TCPPACKBYTES);
                        if (count <= BUFFERSIZE)
                            this.Recv(this.buffer, 0, count);
                        else
                        {

                        }
                    }
                    else 
                        throw new NetworkException("NetworkClient:wrong packet size");

                }
                catch
                {
                    this.Close();
                }

            }, null);
        }

        public void Recv(byte[] buf)
        {
            if (!this.recvIdle)
                return;
            this.recvIdle = false;
            this.Recv(buf, 0, buf.Length);
        }

        public void Send(byte[] buf,int offset,int size)
        {
            if(this.status!=NetworkState.Connected)
                throw new NetworkException("NetworkClient:client did not connect server yet");
            NetworkStream sockstream = sock.GetStream();
            sockstream.BeginWrite(buf, offset, size, (ar)=> {
                NetworkStream s = ar.AsyncState as NetworkStream;
                s.EndWrite(ar);
                NetworkCallback temp = SendCompleted;
                if (temp != null)
                    temp(new NetworkIOArgs(NetworkState.Sended,null,size));
            }, sockstream);
        }

        public void Send(byte[] buf)
        {
            this.Send(buf, 0, buf.Length);
        }

        public void Send(string str)
        {
            byte[] data = Encoding.UTF8.GetBytes(str);
            this.Send(data);
        }

        public void SendPackage(byte[] buf)
        {
            if (buf.Length > 65536)
                throw new NetworkException("NetworkClient:buf sended is too big");
            byte[] pack = new byte[buf.Length + TCPPACKBYTES];
            Array.Copy(buf, 0, pack, TCPPACKBYTES, buf.Length);
            pack[0] = (byte)((buf.Length >> 8)&0xff);
            pack[1] = (byte)(buf.Length & 0xff);
            this.Send(pack);
        }

        public void SendPackage(string str)
        {
            byte[] data = Encoding.UTF8.GetBytes(str);
            this.SendPackage(data);
        }

        public void Close()
        {
            sock.Close();
            sock = null;
            this.status = NetworkState.DisConnected;
        }
    }

}
 
