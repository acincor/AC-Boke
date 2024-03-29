MHC-Boke 2.0版本
---------------

![GitHub code size in bytes](https://img.shields.io/github/languages/code-size/Mhc-Inc/MHC-Boke)

![GitHub License](https://img.shields.io/github/license/Mhc-Inc/MHC-Boke)

![GitHub release (latest by date including pre-releases)](https://img.shields.io/github/v/release/Mhc-Inc/MHC-Boke?include_prereleases)

![GitHub tag (latest by date)](https://img.shields.io/github/v/tag/Mhc-Inc/MHC-Boke.svg)

Installation
---------------

You can download the zip or clone this repository.

**改进了直播的方面，将nginx配置放在了Resource内，将端口统一为80（所以可以省略），可以通过以下配置**

```brew install nginx-full```

```brew install php```

```brew services start nginx-full```

**resource内的nginx.conf替换到/opt/homebrew/etc/nginx.conf**

```nginx -s /opt/homebrew/etc/nginx.conf```

**resource内的php.ini替换到/opt/homebrew/etc/php/（版本号，我的是8.3）/php.ini**

```brew services start php.ini```

**localhost内的所有文件添加到/opt/homebrew/var/www**

**更改配置**

```nginx -s reload```

Stories
---------------

# What is MHC-Boke?

**一个轻量的博客，我们可以在世界各地向手机分享不同的瞬间！例如可以分享出去游玩的照片、快乐的瞬间，点赞高的还有可能在退出app时被被精选哦**

![avatar](https://is1-ssl.mzstatic.com/image/thumb/PurpleSource126/v4/c1/37/70/c13770f4-d1db-caf5-6c8c-17ed511ee38b/e459b9bd-309e-4fa1-a866-e3dbeff3ff53_Simulator_Screenshot_-_iPhone_14_Plus_-_2023-08-24_at_17.17.03.png/400x800bb.png)
![avatar](https://is1-ssl.mzstatic.com/image/thumb/PurpleSource116/v4/e3/bc/df/e3bcdf77-6eb6-4e3c-6c4f-ca1f5cae11c4/ffb2acb8-36d6-47e8-8702-c3f1cd730fc6_Simulator_Screenshot_-_iPhone_14_Plus_-_2023-08-24_at_17.15.56.png/400x800bb.png)
![avatar](https://is1-ssl.mzstatic.com/image/thumb/PurpleSource116/v4/aa/67/c1/aa67c148-c586-6140-78e9-87c7d521dedf/5dad917b-dcbf-43b9-9ca5-e79a88f942bb_Simulator_Screenshot_-_iPhone_14_Plus_-_2023-08-24_at_17.17.19.png/400x800bb.png)
![avatar](https://is1-ssl.mzstatic.com/image/thumb/PurpleSource116/v4/ef/3c/8d/ef3c8def-bbac-a6cd-06ae-826ba6ad7cc2/8e455a78-c04e-4fa4-ba18-4dab4904f471_Simulator_Screenshot_-_iPhone_14_Plus_-_2023-08-24_at_17.18.55.png/400x800bb.png)
![avatar](https://is1-ssl.mzstatic.com/image/thumb/PurpleSource126/v4/4e/0c/27/4e0c2725-777f-9d8a-59c6-882482df2945/44fd3453-1488-4418-95d4-850e92878991_Simulator_Screenshot_-_iPhone_14_Plus_-_2023-08-24_at_17.52.45.png/400x800bb.png)
![avatar](https://is1-ssl.mzstatic.com/image/thumb/PurpleSource116/v4/eb/9c/4b/eb9c4be6-2388-7d77-a297-2ea7250196e2/4ee97072-be59-4834-8425-47f62a3cc21c_Simulator_Screenshot_-_iPhone_14_Plus_-_2023-08-24_at_17.55.56.png/400x800bb.png)
![avatar](https://is1-ssl.mzstatic.com/image/thumb/PurpleSource126/v4/c0/b2/6b/c0b26be0-02d5-c009-f074-be7f8988e676/67c0a416-b27f-4d6d-864f-969076fb7e01_Simulator_Screenshot_-_iPhone_14_Plus_-_2023-08-24_at_17.56.12.png/400x800bb.png)

**一个轻量的博客，我们可以在世界各地向手机分享不同的瞬间！**

Copyright © Mhc.
Tips
-------

-  If you have it, you can run the source code and see its principle.

-  If it really helps you, please tap the star of this repository to support us.
    最后支持的点个Star，交流群vx加17758917010，记住备注（看得懂就行）
