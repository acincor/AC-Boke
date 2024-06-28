MHC-Boke 2.6版本
---------------

![GitHub code size in bytes](https://img.shields.io/github/languages/code-size/Mhc-Inc/MHC-Boke)

![GitHub License](https://img.shields.io/github/license/Mhc-Inc/MHC-Boke)

![GitHub release (latest by date including pre-releases)](https://img.shields.io/github/v/release/Mhc-Inc/MHC-Boke?include_prereleases)

![GitHub tag (latest by date)](https://img.shields.io/github/v/tag/Mhc-Inc/MHC-Boke.svg)

Installation
---------------

**改进了直播的方面**
**将@后更改为用户的MID**
**同时在一段时间后会添加查看话题的api（敬请期待）**
**将comment除controller统一删除与status合并**
**评论可以发送图片、创建话题、将中心button删除，改为右上角的笔**
**注意！记得将所有的内容都测试，否则可能注销会因为数据库没有统一创建导致出现用户没有成功注销的问题，本人在考虑要不要统一建数据库在一个文件**
**支持中英文**

#*OLD VERSION*

**将nginx、php配置放在了Resource内，将ip统一为localhost，可以通过以下配置**

```brew install nginx-full```

```brew install php```

```brew install mysql```

```brew services start php```

```brew services start mysql```

**resource内的nginx.conf替换到/opt/homebrew/etc/nginx.conf，old_version为macOS 15.0以下**

```nginx -s /opt/homebrew/etc/nginx.conf```

**resource内的php.ini替换到/opt/homebrew/etc/php/（版本号，我的是8.3）/php.ini**

```brew services start php.ini```

**project内的localhost内的所有文件添加到/opt/homebrew/var/www**

**project内的wss项目（springboot）运行，用于连接websocket**

**如何启动**

```nginx```

**如何重载**

```nginx -s reload```

#*NEW VERSION*

**已经上传云端，域名mhcincapi.top**

Stories
---------------

# What is MHC-Boke?

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

Copyright © Mhc.
End
-------

-  If it really helps you, please tap the star of this repository to support us.
    最后支持的点个Star，交流群vx加17758917010，记住备注（看得懂就行）
