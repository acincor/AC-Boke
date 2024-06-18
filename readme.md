MHC-Boke 2.5版本 支持中英文
---------------

![GitHub code size in bytes](https://img.shields.io/github/languages/code-size/Mhc-Inc/MHC-Boke)

![GitHub License](https://img.shields.io/github/license/Mhc-Inc/MHC-Boke)

![GitHub release (latest by date including pre-releases)](https://img.shields.io/github/v/release/Mhc-Inc/MHC-Boke?include_prereleases)

![GitHub tag (latest by date)](https://img.shields.io/github/v/tag/Mhc-Inc/MHC-Boke.svg)

Installation
---------------

You can download the zip or clone this repository.

**改进了直播的方面，将@后更改为用户的MID，以便我们实现升起视图控制器来查看用户信息，将富文本FFLabelDelegate在评论区无法正常点击的bug fixed，同时在一段时间后会添加查看话题的api（敬请期待）将nginx、php配置放在了Resource内，将ip统一为localhost，可以通过以下配置，删除了addComment、deleteComment，将内容统一分别添加到upload、deleteBlog，CommentViewController删除，统一改为ComposeViewController，删除Comment，统一改为Status，删除CommentViewModel，改为StatusViewModel，删除关于CommentCommentCell、CommentCommentCellBottomView、StatusCommentCell，统一改为StatusNormalCell，评论可以发送图片、创建话题、将中心button删除，改为右上角的笔，不容易出现约束问题，注意！记得将所有的内容都测试，否则可能注销会因为数据库没有统一创建导致出现用户没有成功注销的问题，本人在考虑要不要统一建数据库在一个文件**

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

Stories
---------------

# What is MHC-Boke?

**一个轻量的博客，我们可以在世界各地向手机分享不同的瞬间！例如可以分享出去游玩的照片、快乐的瞬间，点赞高的还有可能在退出app时被被精选哦**

![avatar](https://www.z4a.net/image/ja8IwK)
![avatar](https://www.z4a.net/image/ja8Mc0)
![avatar](https://www.z4a.net/image/ja8Prj)
![avatar](https://www.z4a.net/image/ja8hOa)
![avatar](https://www.z4a.net/image/jaCSCO)
![avatar](https://www.z4a.net/image/jaCfNK)
![avatar](https://www.z4a.net/image/jaCvu0)
![avatar](https://www.z4a.net/image/jaC3Jj)

**一个轻量的博客，我们可以在世界各地向手机分享不同的瞬间！**

Copyright © Mhc.
Tips
-------

-  If you have it, you can run the source code and see its principle.

-  If it really helps you, please tap the star of this repository to support us.
    最后支持的点个Star，交流群vx加17758917010，记住备注（看得懂就行）
