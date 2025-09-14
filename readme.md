AC-Boke
---------------

![GitHub code size in bytes](https://img.shields.io/github/languages/code-size/acincor/AC-Boke)

![GitHub License](https://img.shields.io/github/license/acincor/AC-Boke)

![GitHub release (latest by date including pre-releases)](https://img.shields.io/github/v/release/acincor/AC-Boke?include_prereleases)

![GitHub tag (latest by date)](https://img.shields.io/github/v/tag/acincor/AC-Boke.svg)

开发者们：
---------------
- 预警：云端服务器将在2025年9月28日过期，且后续不再续费以供支持，访客们将无法访问`mhcincapi.top`。

- 依赖库:`{
                "SPM": ["Kingfisher", "FMDB", "HaishinKit", "SVProgressHUD", "SnapKit"], 
                "已改成内部文件": ["FFLabel"]
        }`

- 支持中英文、Swift 6
<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [Classes](#classes)
  - [Actor](#actor)
    - [NotificationRegister.swift](#notificationregisterswift)
  - [Model](#model)
    - [Account.swift](#accountswift)
    - [Status.swift](#statusswift)
    - [UserAccount.swift](#useraccountswift)
  - [Tools](#tools)
    - [Emoticon](#emoticon)
    - [Extension](#extension)
    - [PhotoBrowser](#photobrowser)
    - [PicturePicker](#picturepicker)
    - [Common.swift](#commonswift)
    - [NetworkTools.swift](#networktoolsswift)
    - [SQLiteManager.swift](#sqlitemanagerswift)
    - [OAuth](#oauth)
      - [OAuthViewController.swift](#oauthviewcontrollerswift)
  - [View](#view)
    - [Compose](#compose)
      - [ComposeViewController.swift](#composeviewcontrollerswift)
    - [Discover](#discover)
      - [DiscoverTableViewController.swift](#discovertableviewcontrollerswift)
    - [Message](#message)
      - [WebSocket](#websocket)
      - [MessageMainTableViewController.swift](#messagemaintableviewcontrollerswift)
    - [UserAgreement](#useragreement)
      - [UserAgreementViewController.swift](#useragreementviewcontrollerswift)
    - [Blogs](#blogs)
      - [LiveList](#livelist)
      - [CommentTableViewController.swift](#commenttableviewcontrollerswift)
      - [BlogTableViewController.swift](#blogtableviewcontrollerswift)
      - [QuoteTableViewController.swift](#quotetableviewcontrollerswift)
      - [HomeTableViewController.swift](#hometableviewcontrollerswift)
      - [TypeStatusTableViewController.swift](#typestatustableviewcontrollerswift)
      - [ACWebViewController.swift](#acwebviewcontrollerswift)
      - [StatusCell](#statuscell)
      - [TrendCell](#trendcell)
      - [RefreshView](#refreshview)
    - [Profile](#profile)
      - [BKLiveController.swift](#bklivecontrollerswift)
      - [ProfileTableViewController.swift](#profiletableviewcontrollerswift)
      - [UserProfileBrowserViewController.swift](#userprofilebrowserviewcontrollerswift)
    - [User][#user]
      - [UserCollectionCell][#usercollectioncell]
      - [UserTableViewController.swift][#usertableviewcontroller.swift]
      - [FansTableViewController.swift][#fanstableviewcontroller.swift]
  - [ViewModel](#viewmodel)
    - [ElseListViewModel.swift](#elselistviewmodelswift)
    - [StatusDAL.swift](#statusdalswift)
    - [StatusViewModel.swift](#statusviewmodelswift)
    - [StatusListViewModel.swift](#statuslistviewmodelswift)
    - [UserAccountViewModel.swift](#useraccountviewmodelswift)
    - [UserViewModel.swift](#userviewmodelswift)
- [Localized](#localized)
- [api配置](#api配置)
    - [安装nginx](#安装nginx)
    - [安装mysql](#安装mysql)
    - [安装php](#安装php)
    - [配置mysql](#配置mysql)
        - [下次登录](#下次登录)
    - [那些需要修改的](#那些需要修改的)
    - [运行websocket项目](#运行websocket项目)
<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Classes
是全项目文件
### Actor
`actor`集中地
#### NotificationRegister.swift
处理允许通知的actor文件
### Model
#### Account.swift
用于加载资料卡、直播、好友的信息
#### Status.swift
用于加载博客、评论以及评论的回复
#### UserAccount.swift
用于加载本机用户的信息

### Tools
#### Emoticon
提供了加载表情包附带输入显示处理的工具
#### Extension
拓展了部分类、封装了部分方法，便于关于类对象的一些重复代码处理，特殊地拓展了指针对象，便于在触发事件需要外部信息时存储并引用
#### PhotoBrowser
处理选中图片时展示图片
#### PicturePicker
在发送有图片博客以及发送图片消息时的图片选择器
#### Common.swift
记录一些通知名常量、`listViewModel`首页加载博客全局变量、以及加载图片位于的缓存器`imageCache`
#### NetworkTools.swift
网络类，请求API
#### SQLiteManager.swift
在这里创建`db.sql`内含有的数据库`createTable()`方法以及`execRecordSet()`封装方法用于获取数据库内的信息
#### OAuth
2.0版本的登录、注册
##### OAuthViewController.swift
链接登录、注册用户网页的界面

### View
记录了UI视图控制器
#### Compose
发送一切
##### ComposeViewController.swift
发送博客、消息、评论、评论回复
#### Discover
发现界面，与首页差不多，多了搜索功能，少了写博客的功能
##### DiscoverTableViewController.swift
发现界面，可以通过模糊搜索名字以及博客内容获取博客
#### Message
好友界面
##### WebSocket
链接WebSocket发送消息
##### MessageMainTableViewController.swift
加载好友列表
#### UserAgreement
有显示用户协议的视图控制器
##### UserAgreementViewController.swift
用户协议界面

#### Blogs
处理博客UI的任务
##### LiveList
加载正在直播的信息列表
##### CommentTableViewController.swift
加载评论
##### BlogTableViewController.swift
集成了加载博客信息的视图控制器，后续其余加载需要缓存的类继承这个类
##### QuoteTableViewController.swift
加载评论回复
##### HomeTableViewController.swift
加载博客、直播列表、右上角写博客
##### TypeStatusTableViewController.swift
加载赞过的(评论过的)博客
##### ACWebViewController.swift
跳转网页
##### StatusCell
加载博客的单个单元格的单个单元格
##### TrendCell
加载话题的单个单元格
##### RefreshView
处理刷新动画

#### Profile
处理关于资料卡的任务
##### BKLiveController.swift
关于开关直播、录像直播操作在这里进行
##### ProfileTableViewController.swift
用于显示自己以及别人的资料卡
##### UserProfileBrowserViewController.swift
查看用户头像，如果是我的头像则有更换头像的选项

#### User
处理加载用户信息的任务
##### UserCollectionCell
加载用户信息（用于直播、好友、资料卡界面）的单个单元格
##### UserTableViewController.swift
加载用户关注（父类默认加载关注）的控制器试图
##### FansTableViewController.swift
加载用户粉丝（继承于父类加载粉丝）的控制器试图

### ViewModel
加载博客内需要的信息
#### ElseListViewModel.swift
加载直播、好友信息
#### StatusDAL.swift
缓存、查询、删除博客或消息缓存
#### StatusViewModel.swift
内含将博客或者消息的模型部分信息转换成对象以及博客或消息本身的模型对象
#### StatusListViewModel.swift
加载博客信息，若是点赞的、评论的不做缓存，其余缓存
#### UserAccountViewModel.swift
根据`access_token`加载用户信息并保存到本地沙盒文件`account.plist`
#### UserViewModel.swift
内含将好友、直播或者资料卡模型的模型部分信息转换成对象以及好友、直播或者资料卡本身的模型对象

## Localized

本博客部分提示文本的翻译

## api配置

服务器于2025年9月28日过期，请各位开发者于本地进行简单配置

**前往Resource文件夹**

1. 下载homebrew
2. 按如下语句进行配置即可

### 安装nginx
为了直播推流而安装的nginx。
```
brew tap denji/nginx
brew install nginx-full --with-rtmp-module
```

### 安装mysql
为了在本地创建mysql数据库`ac_inc`而安装。
```
brew install mysql
brew services start mysql
```

### 安装php
为了给phpStorm可执行的php编译器，于是安装brew的php。
```
brew install php
brew services start php
```

### 配置mysql
```
mysql -u root
mysql> create database ac_inc;
mysql> SET PASSWORD FOR 'root'@'localhost' = PASSWORD('YOUR_PASSWORD');
```

#### 下次登录
```
mysql -u root -p
YOUR_PASSWORD
```

### 那些需要修改的

默认`YOUR_PASSWORD=123456`，需修改`localhost/api`文件夹下将所有链接数据库语句中密码实参值替换成您的密码

nginx.conf需要进行修改。

nginx.conf:83: 将`alias video`中的`video`替换成您存储直播切片的文件夹。

nginx.conf:84: 如果您的`rtmp-nginx-module`文件夹安装位置与我不同（或版本不同）请将根文件夹一并修改。

建议使用phpStorm启动项目，比较容易维护。

### 运行websocket项目

target存储了能够链接websocket的聊天后端，可以安装java编译器之后用`jar`命令运行

```java -jar -Xmx1024M -Xms256M xxx/AC-Boke/Acblog/Resource/target/wss-0.0.1-SNAPSHOT.jar --server.port=8081```

使用者们：
---------------

**功能：**

- **注意：登录、注册后才可以使用一切功能。**

- 可以发布博客，博客中可以带有表情包、图片、@信息、#话题、链接。

- 对于别人的博客，您可以点赞、评论，并且在“我”界面中找到自己点赞（或评论）的博客。或者您可以点击头像查看别人的资料卡，获取他人相应的信息以及打开他的主页添加好友。

- 添加好友之后，可以与好友畅聊并分享许多相册里的新鲜事与回忆！

- 如果有突然找不到的博客，可以使用记下的信息在发现界面查找🤩

- 如果点赞破1000，在他人退出应用一瞬间将有可能被推送！

- 我界面中，除上述，还可以开启直播、注销和退登。首页里也可以查看他人的直播！



故事
---------------

**一个轻量的博客，我们可以在世界各地向手机分享不同的瞬间！**

![avatar](https://is1-ssl.mzstatic.com/image/thumb/PurpleSource221/v4/7b/6f/03/7b6f03ed-3bd0-5c61-81e6-336b68c823fd/dec3fb5e-cba1-4e67-80d2-6f26ca1ec103_Simulator_Screenshot_-_iPhone_14_Plus_-_2024-07-21_at_23.44.33.png/500x1086bb.png)
![avatar](https://img.z4a.net/images/2025/08/13/Simulator-Screenshot---iPhone-16-Pro-Max---2025-08-13-at-21.15.34.md.png)

Copyright © AC.
-------

-  If it really helps you, please tap the star of this repository to support us. 交流群vx加17758917010，记住备注（看得懂就行）
