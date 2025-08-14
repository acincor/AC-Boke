## 目录
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
      - [QuoteTableViewController.swift](#quotetableviewcontrollerswift)
      - [HomeTableViewController.swift](#hometableviewcontrollerswift)
      - [TypeStatusTableViewController.swift](#typestatustableviewcontrollerswift)
      - [ACWebViewController.swift](#acwebviewcontrollerswift)
      - [StatusCell](#statuscell)
      - [RefreshView](#refreshview)
    - [Profile](#profile)
      - [BKLiveController.swift](#bklivecontrollerswift)
      - [ProfileTableViewController.swift](#profiletableviewcontrollerswift)
      - [UserProfileBrowserViewController.swift](#userprofilebrowserviewcontrollerswift)
  - [ViewModel](#viewmodel)
    - [ElseListViewModel.swift](#elselistviewmodelswift)
    - [StatusDAL.swift](#statusdalswift)
    - [StatusViewModel.swift](#statusviewmodelswift)
    - [TypeNeedCacheListViewModel.swift](#typeneedcachelistviewmodelswift)
    - [TypeStatusListViewModel.swift](#typestatuslistviewmodelswift)
    - [UserAccountViewModel.swift](#useraccountviewmodelswift)
    - [UserViewModel.swift](#userviewmodelswift)
- [Localized](#localized)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Classes
是全项目文件
### Actor
actor集中地
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
记录一些通知名常量、listViewModel首页加载博客全局变量、以及加载图片位于的缓存器imageCache
#### NetworkTools.swift
网络类，请求API
#### SQLiteManager.swift
在这里创建db.sql内含有的数据库createTable()方法以及execRecordSet()封装方法用于获取数据库内的信息
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
##### QuoteTableViewController.swift
加载评论回复
##### HomeTableViewController.swift
加载博客、直播列表、右上角写博客
##### TypeStatusTableViewController.swift
加载赞过的(评论过的)博客
##### ACWebViewController.swift
跳转网页
##### StatusCell
加载博客的单个单元格、加载话题的单个单元格、加载用户信息（用于直播、好友、资料卡界面）的单个单元格
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

### ViewModel
加载博客内需要的信息
#### ElseListViewModel.swift
加载直播、好友信息
#### StatusDAL.swift
缓存、查询、删除博客或消息缓存
#### StatusViewModel.swift
内含将博客或者消息的模型部分信息转换成对象以及博客或消息本身的模型对象
#### TypeNeedCacheListViewModel.swift
加载博客、评论、评论回复、特定ID的博客并缓存
#### TypeStatusListViewModel.swift
加载点赞过的（评论过的）博客、特定ID的博客
#### UserAccountViewModel.swift
根据*access_token*加载用户信息并保存到本地沙盒文件account.plist
#### UserViewModel.swift
内含将好友、直播或者资料卡模型的模型部分信息转换成对象以及好友、直播或者资料卡本身的模型对象

## Localized

本博客部分提示文本的翻译
