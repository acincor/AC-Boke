AC-Boke
---------------

![GitHub code size in bytes](https://img.shields.io/github/languages/code-size/acincor/AC-Boke)

![GitHub License](https://img.shields.io/github/license/acincor/AC-Boke)

![GitHub release (latest by date including pre-releases)](https://img.shields.io/github/v/release/acincor/AC-Boke?include_prereleases)

![GitHub tag (latest by date)](https://img.shields.io/github/v/tag/acincor/AC-Boke.svg)

下载注意事项
---------------

 开发者们：
 ---------------

- 用户的AID唯一且不能改变，Actor文件夹下有处理允许通知的actor文件

- 预警：（域名为mhcincapi.top）服务器将在2025年9月28日过期，且后续不再续费以供支持。**注意：我将在过段时间将网页上的API在本地尝试配置以达到让开发者与使用者可以运行成功，配置信息若符合系统则可以无视**

- 依赖库(SPM)为：Kingfisher、FMDB、HaishinKit、SVProgressHUD、SnapKit以及（非SPM，已为支持Swift6修改成为项目内部文件）FFLabel

- 支持中英文、Swift 6

使用者们：
---------------

**功能：**

- **注意：登录、注册后才可以使用一切功能。**

- 可以发布博客，博客中可以带有表情包、图片、@信息。

- 对于别人的博客，您可以点赞、评论，并且在“我”界面中找到自己点赞（或评论）的博客。或者您可以点击头像查看别人的资料卡，获取他人相应的信息以及打开他的主页添加好友。

- 添加好友之后，可以与好友畅聊并分享许多相册里的新鲜事与回忆！

- 如果有突然找不到的博客，可以使用记下的信息在发现界面查找🤩

- 如果点赞破1000，在他人退出应用一瞬间将有可能被推送！

本地运行API需配置（推荐）
---------------

由于**服务器并不是很稳定**，有很大概率无法持续维护，所以推荐本地运行API。

**如何新建"ac_inc"数据库**

**create database ac_inc**

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

故事
---------------

**一个轻量的博客，我们可以在世界各地向手机分享不同的瞬间！**

![avatar](https://is1-ssl.mzstatic.com/image/thumb/PurpleSource221/v4/e7/17/cd/e717cdc0-9552-1620-8fb2-faaf6590face/05138305-30d4-444a-b485-45cbf891ef0c_Simulator_Screenshot_-_iPhone_14_Plus_-_2024-07-21_at_23.44.52.png/520x1040bb.png)
![avatar](https://img.z4a.net/images/2025/08/13/Simulator-Screenshot---iPhone-16-Pro-Max---2025-08-13-at-21.15.34.md.png)

**一个轻量的博客，我们可以在世界各地向手机分享不同的瞬间！**

Copyright © AC.
End
-------

-  If it really helps you, please tap the star of this repository to support us.
    最后支持的点个Star，交流群vx加17758917010，记住备注（看得懂就行）
