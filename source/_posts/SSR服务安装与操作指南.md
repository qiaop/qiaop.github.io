---
title: SSR服务安装与操作指南
date: 2017-03-13 20:12:45
tags:
- base
categories:
- base

---
我觉得还是搬过来放着安全一点。

<!-- more -->

---一键脚本-自动加入开机自启动。

wget http://vpn.ximcx.cn/SSR/SSR bash SSR


卸载方法：
使用 root 用户登录，运行以下命令：

wget http://vpn.ximcx.cn/SSR/SSR bash SSR uninstall



使用命令：
启动：/etc/init.d/shadowsocks start
停止：/etc/init.d/shadowsocks stop
重启：/etc/init.d/shadowsocks restart
状态：/etc/init.d/shadowsocks status

配置文件路径：/etc/shadowsocks.json
日志文件路径：/var/log/shadowsocks.log
安装路径：/usr/local/shadowsocks/shadowsoks


完整的多用户配置(/etc/shadowsocks.json)如下：

	{
	“server“:“0.0.0.0“,
	“server_ipv6“: “[::]“,
	“local_address“:“127.0.0.1“,
	“local_port“:108,
	“port_password“:{
	“80“:“password1“,
	“443“:“password2“
	},
	“timeout“:300,
	“method“:“chacha20“,
	“protocol“: “auth_sha1_compatible“,
	“protocol_param“: ““,
	“obfs“: “http_simple_compatible“,
	“obfs_param“: ““,
	“redirect“: ““,
	“dns_ipv6“: false,
	“fast_open“: false,
	“workers“: 1
	}