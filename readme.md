AC-Boke 2.7版本
---------------

![GitHub code size in bytes](https://img.shields.io/github/languages/code-size/acincor/AC-Boke)

![GitHub License](https://img.shields.io/github/license/acincor/AC-Boke)

![GitHub release (latest by date including pre-releases)](https://img.shields.io/github/v/release/acincor/AC-Boke?include_prereleases)

![GitHub tag (latest by date)](https://img.shields.io/github/v/tag/acincor/AC-Boke.svg)

Installation
---------------

**将@后更改为用户的MID**
**同时在一段时间后会添加查看话题的借口（api）（敬请期待）**
**将评论（comments）除控制器（controller）统一删除与博客（status）合并**
**注意！一定记得新建名为"ac_inc"的数据库，并将所有的内容都测试，否则可能注销会因为数据库没有统一创建导致出现用户没有成功注销的问题，本人在考虑要不要统一建数据库在一个文件**
**如何新建"ac_inc"数据库**
**create database ac_inc**
**暗色模式下，漏洞已修复，如登录、注册界面无法看到控制器标题（这个原因是因为网页视图（webView）没有完全贴合登录、注册授权视图控制器（OAuthViewController）留有空白，苹果称之为（Safe Area），导航栏是透明的，所以透出了底下的空白，导致下滑才会出现导航栏标题和深色，对此我们深表歉意），启动页面图标背景为白色**
**支持中英文**

#*OLD VERSION*

**将nginx、php配置放在了资源文件夹下（Resource），统一为localhost，可以通过以下配置**

```brew install nginx-full```

```brew install php```

```brew install mysql```

```brew services start php```

```brew services start mysql```

**资源文件夹下（resource）内的nginx配置文件（nginx.conf）替换到brew下的配置文件（/opt/homebrew/etc/nginx.conf），旧版本（old_version）为苹果电脑操作系统15.0（macOS 15.0）以下**

```nginx -s /opt/homebrew/etc/nginx.conf```

**资源文件夹下（resource）内的php配置文件（php.ini）替换到brew下的php 配置文件（/opt/homebrew/etc/php/（版本号，我的是8.3）/php.ini）**

```brew services start php.ini```

**项目文件夹下（project）内的后端项目文件夹（localhost）内的所有文件添加到brew下的后端文件夹根目录（/opt/homebrew/var/www）**

**项目文件夹下（project）内的网页聊天后端maven项目（wss项目），请用可以运行springboot项目的java编译器进行运行，用于客户端连接网页聊天后端（websocket）**

**如何启动**

```nginx```

**如何重载**

```nginx -s reload```

#*NEW VERSION*

**已经上传云端，域名为“mhcincapi.top”**

Stories
---------------

# What is AC-Boke?

**一个轻量的博客，我们可以在世界各地向手机分享不同的瞬间！例如可以分享出去游玩的照片、快乐的瞬间，点赞高的还有可能在退出app时被被精选哦**

![avatar](https://www.z4a.net/images/2024/06/18/Simulator-Screenshot---iPhone-15-Pro-Max---2024-06-18-at-18.56.18.png)
![avatar](https://www.z4a.net/images/2024/06/18/Simulator-Screenshot---iPhone-15-Pro-Max---2024-06-18-at-18.57.47.png)
![avatar](https://www.z4a.net/images/2024/06/18/Simulator-Screenshot---iPhone-15-Pro---2024-06-18-at-19.00.36.png)
![avatar](https://www.z4a.net/images/2024/06/18/Simulator-Screenshot---iPhone-15-Pro---2024-06-18-at-19.09.06.png)
![avatar](https://www.z4a.net/images/2024/06/18/Simulator-Screenshot---iPhone-15-Pro---2024-06-18-at-21.14.55.png)
![avatar](https://www.z4a.net/images/2024/06/18/Simulator-Screenshot---iPhone-15-Pro---2024-06-18-at-21.19.08.png)
![avatar](https://www.z4a.net/images/2024/06/18/Simulator-Screenshot---iPhone-15-Pro---2024-06-18-at-21.19.39.png)
![avatar](https://www.z4a.net/images/2024/06/18/Simulator-Screenshot---iPhone-15-Pro-Max---2024-06-18-at-21.19.55.png)

**一个轻量的博客，我们可以在世界各地向手机分享不同的瞬间！**

Copyright © AC.
End
-------

-  If it really helps you, please tap the star of this repository to support us.
    最后支持的点个Star，交流群vx加17758917010，记住备注（看得懂就行）
