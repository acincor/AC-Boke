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

- 用户的AID唯一且不能改变，Classes/Actor文件夹下有处理允许通知的actor文件

- Classes下是全项目文件

- Classes/Model下有Account模型（用于加载资料卡、直播、好友的信息）、Status模型（用于加载博客、评论以及评论的回复）、UserAccount模型（用于加载本机用户的信息）。

- Classes/Tools下有Emoticon（提供了加载表情包附带输入显示处理的工具）、Extension（拓展了部分类、封装了部分方法，便于关于类对象的一些重复代码处理，特殊地拓展了指针对象，便于在触发事件需要外部信息时存储并引用）、PhotoBrowser（处理选中图片时展示图片）、PicturePicker（在发送有图片博客以及发送图片消息时的图片选择器）、Common文件（记录一些通知名常量、listViewModel首页加载博客全局变量、以及加载图片位于的缓存器imageCache）、NetworkTools文件（网络类，请求API）、SQLiteManager文件（在这里创建db.sql内含有的数据库createTable()方法以及execRecordSet()封装方法用于获取数据库内的信息）、OAuth/OAuthViewController文件（链接登录、注册用户网页的界面）

- Classes/View下有Compose/ComposeViewController文件（发送博客、消息、评论、评论回复）、Discover/DiscoverTableViewController文件（发现界面，与首页差不多，多了搜索功能，少了写博客的功能）、Message/WebSocket（链接WebSocket发送消息）、Message/MessageMainTableViewController文件（加载好友列表）、UserAgreement/UserAgreementViewController（用户协议界面）

- Classes/View/Blogs处理加载博客的任务，下有LiveList（处理加载正在直播的信息列表）、CommentTableViewController（加载评论）、QuoteTableViewController（加载评论回复）、HomeTableViewController（加载博客、直播列表、右上角写博客）、TypeStatusTableViewController（加载赞过的(评论过的)博客）、ACWebViewController（跳转网页）、StatusCell（加载博客的单个单元格、加载话题的单个单元格、加载用户信息（用于直播、好友、资料卡界面）的单个单元格）、RefreshView（处理刷新动画）

- Classes/View/Profile加载本机用户资料卡，下有AccountViewController文件（退登或者注销）、BKLiveController文件（关于开关直播、录像直播操作在这里进行）、ProfileTableViewController文件（未登录时“我“界面为ProfileTableViewController、登录时此控制器显示本机用户的AID以及用户名并且可以更改用户名））、UserNavigationLinkView文件（用于显示自己以及别人的资料卡，若登录，“我“界面则会切换成自己的资料卡）、UserProfileBrowserViewController文件（显示他人的AID及用户名）

- Classes/ViewModel下有ElseListViewModel文件（加载直播、好友信息）、StatusDAL（存储、查询、删除博客或消息缓存）、StatusViewModel文件（内含将博客或者消息的模型部分信息转换成对象以及博客或消息本身的模型对象）、TypeNeedCacheListViewModel文件（加载博客、评论、评论回复、特定ID的博客）、TypeStatusListViewModel文件（加载点赞过的（评论过的）博客、特定ID的博客）、UserAccountViewModel文件（根据*access_token*加载用户信息并保存到本地沙盒文件account.plist）、UserViewModel文件（内含将好友、直播或者资料卡模型的模型部分信息转换成对象以及好友、直播或者资料卡本身的模型对象）

- Localized/Localizable文件有本博客部分提示文本的翻译

- 预警：（域名为mhcincapi.top）服务器将在2025年9月28日过期，且后续不再续费以供支持。**注意：我将在过段时间将网页上的API在本地尝试配置以达到让开发者与使用者可以运行成功，配置信息若符合系统则可以无视**

- 依赖库(SPM)为：Kingfisher、FMDB、HaishinKit、SVProgressHUD、SnapKit以及（非SPM，已为支持Swift6修改成为项目内部文件）FFLabel

- 支持中英文、Swift 6

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

**一个轻量的博客，我们可以在世界各地向手机分享不同的瞬间！**

Copyright © AC.
End
-------

-  If it really helps you, please tap the star of this repository to support us.交流群vx加17758917010，记住备注（看得懂就行）
