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
**聊天系统升级！添加点赞、撤回功能，并且界面与博客卡一样**
**create database ac_inc**
**暗色模式下，漏洞已修复，如登录、注册界面无法看到控制器标题（这个原因是因为网页视图（webView）没有完全贴合登录、注册授权视图控制器（OAuthViewController）留有空白，苹果称之为（Safe Area），导航栏是透明的，所以透出了底下的空白，导致下滑才会出现导航栏标题和深色，对此我们深表歉意），启动页面图标背景为白色**
**去除了对老库AFNetworking的支持，更换Alamofire**
**支持中英文**
**表情包键盘取消工具栏机制，约束问题解决**

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

![avatar](https://is1-ssl.mzstatic.com/image/thumb/PurpleSource221/v4/98/81/5c/98815cfa-bc38-29ce-1341-556e94873206/884ae8e7-5a75-4ff5-bf03-1c61ed33064f_Simulator_Screenshot_-_iPhone_14_Plus_-_2024-03-31_at_11.03.23.png/400x800bb.png)
![avatar](https://is1-ssl.mzstatic.com/image/thumb/PurpleSource221/v4/3b/eb/22/3beb2214-23be-61cf-6bf1-a3bd5c794604/2cb5f101-fa30-47ca-a434-0f03bf51af87_Simulator_Screenshot_-_iPhone_14_Plus_-_2024-07-21_at_23.32.38.png/400x800bb.png)
![avatar](https://is1-ssl.mzstatic.com/image/thumb/PurpleSource221/v4/46/85/df/4685df96-837e-56b7-c13d-a626686db7cf/3211467e-5a3c-4758-ae07-bfed1b444713_Simulator_Screenshot_-_iPhone_14_Plus_-_2024-07-21_at_23.33.36.png/400x800bb.png)
![avatar](https://is1-ssl.mzstatic.com/image/thumb/PurpleSource221/v4/3d/d7/47/3dd74745-9238-3081-aa15-785b05c356a7/c11e5786-563b-4745-addf-b017f1c07c40_Simulator_Screenshot_-_iPhone_14_Plus_-_2024-07-21_at_23.44.18.png/400x800bb.png)
![avatar](https://is1-ssl.mzstatic.com/image/thumb/PurpleSource221/v4/7b/6f/03/7b6f03ed-3bd0-5c61-81e6-336b68c823fd/dec3fb5e-cba1-4e67-80d2-6f26ca1ec103_Simulator_Screenshot_-_iPhone_14_Plus_-_2024-07-21_at_23.44.33.png/400x800bb.png)
![avatar](https://is1-ssl.mzstatic.com/image/thumb/PurpleSource211/v4/bd/99/58/bd9958c0-053b-cc77-e400-8366f5bedb8b/9315682d-2d29-4096-8563-632bfea45d9c_Simulator_Screenshot_-_iPhone_14_Plus_-_2024-07-21_at_23.44.42.png/400x800bb.png)
![avatar](https://is1-ssl.mzstatic.com/image/thumb/PurpleSource221/v4/e7/17/cd/e717cdc0-9552-1620-8fb2-faaf6590face/05138305-30d4-444a-b485-45cbf891ef0c_Simulator_Screenshot_-_iPhone_14_Plus_-_2024-07-21_at_23.44.52.png/400x800bb.png)
![avatar](https://is1-ssl.mzstatic.com/image/thumb/PurpleSource211/v4/22/d6/91/22d69102-082e-4532-cb55-4a54e533129f/134bd7ca-f204-40de-9c03-5871147bf270_Simulator_Screenshot_-_iPhone_14_Plus_-_2024-07-21_at_23.45.05.png/400x800bb.png)
![avatar](https://is1-ssl.mzstatic.com/image/thumb/PurpleSource211/v4/a2/11/ff/a211ffdf-4b60-6882-4159-431de468a6ba/8facbfd8-2fa2-4cb3-96c2-382f8bc87b83_Simulator_Screenshot_-_iPhone_13_Pro_Max_-_2024-07-21_at_23.47.45.png/400x800bb.png)
![avatar](https://is1-ssl.mzstatic.com/image/thumb/PurpleSource221/v4/53/fd/55/53fd5597-0141-0b3e-f3f8-e42c66de417a/44b7a24a-aa81-41ff-a598-a31e2f8a1e09_Simulator_Screenshot_-_iPhone_13_Pro_Max_-_2024-07-21_at_23.53.25.png/400x800bb.png)
**一个轻量的博客，我们可以在世界各地向手机分享不同的瞬间！**

Copyright © AC.
End
-------

-  If it really helps you, please tap the star of this repository to support us.
    最后支持的点个Star，交流群vx加17758917010，记住备注（看得懂就行）
