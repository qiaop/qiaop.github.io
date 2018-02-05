---
title: SS服务安装与操作指南
date: 2017-03-13 20:12:45
tags:
- base
categories:
- base

---
我觉得还是搬过来放着安全一点。

<!-- more -->

apt-get install python-pip  
apt-get update
pip install shadowsocks 

vi /etc/shadowsocks.json

```
{
    "server":"0.0.0.0",             //服务端监听的地址，服务端可填写 0.0.0.0
    "server_port":8388,             //服务端的端口
    "local_address": "127.0.0.1",   //本地端监听的地址
    "local_port":1080,              //本地端的端口
    "password":"xxxxxx",            //用于加密的密码
    "timeout":300,                  //超时时间，单位秒
    "method":"aes-256-cfb",         //默认 "aes-256-cfb"
    "fast_open": false,             //是否使用 TCP_FASTOPEN, true / false
    "workers": 1                    //worker 数量，Unix/Linux 可用，如果不理解含义请不要改
}
```

```
{
"server":"填写你的服务器IP",
"local_address": "127.0.0.1",
"local_port":1080,
"port_password":{
"端口1":"密码",
"端口2":"密码",
"端口3":"密码",
"端口4":"密码",
"端口5":"密码"
},
"timeout":300,
"method":"aes-256-cfb",
"fast_open": false
}
```

ssserver -c /etc/shadowsocks.json -d start 即可启动 ShadowSocks 服务
ssserver -c /etc/shadowsocks.json -d stop 即可关闭 Shadowsocks 服务