MHC-Boke 2.2版本
---------------

![GitHub code size in bytes](https://img.shields.io/github/languages/code-size/Mhc-Inc/MHC-Boke)

![GitHub License](https://img.shields.io/github/license/Mhc-Inc/MHC-Boke)

![GitHub release (latest by date including pre-releases)](https://img.shields.io/github/v/release/Mhc-Inc/MHC-Boke?include_prereleases)

![GitHub tag (latest by date)](https://img.shields.io/github/v/tag/Mhc-Inc/MHC-Boke.svg)

Installation
---------------

You can download the zip or clone this repository.

**改进了直播的方面，将nginx、php配置放在了Resource内，将端口统一为80（所以可以省略），可以通过以下配置**

```brew install nginx-full```

```brew install php```

```brew services start nginx-full```

**resource内的nginx.conf替换到/opt/homebrew/etc/nginx.conf**

```nginx -s /opt/homebrew/etc/nginx.conf```

**resource内的php.ini替换到/opt/homebrew/etc/php/（版本号，我的是8.3）/php.ini**

```brew services start php.ini```

**project内的localhost内的所有文件添加到/opt/homebrew/var/www**

**project内的wss项目（springboot）运行，用于连接websocket**

**如何更改配置**

```nginx -s reload```

Stories
---------------

# What is MHC-Boke?

**一个轻量的博客，我们可以在世界各地向手机分享不同的瞬间！例如可以分享出去游玩的照片、快乐的瞬间，点赞高的还有可能在退出app时被被精选哦**

![avatar](https://is1-ssl.mzstatic.com/image/thumb/PurpleSource221/v4/37/cc/e5/37cce569-cfab-d509-f3c8-9725018b207b/e6bfac15-617d-45f1-a966-49b265d80dc8_Simulator_Screenshot_-_iPhone_14_Plus_-_2024-03-31_at_10.58.50.png/400x800bb.png)
![avatar](https://is1-ssl.mzstatic.com/image/thumb/PurpleSource221/v4/f4/aa/3e/f4aa3e8a-2c7b-50dc-09f3-5cdd1442cb0f/34a6c79b-3d6d-4d8b-bdcc-7d442bd9d4b2_Simulator_Screenshot_-_iPhone_14_Plus_-_2024-03-31_at_10.59.32.png/400x800bb.png)
![avatar](https://is1-ssl.mzstatic.com/image/thumb/PurpleSource211/v4/d2/90/9e/d2909ed3-3cf6-4f23-f3ed-6d32f15a0a16/1d3e92fa-5a69-4bee-9917-7a026dba488b_Simulator_Screenshot_-_iPhone_14_Plus_-_2024-03-31_at_10.59.44.png/400x800bb.png)
![avatar](https://is1-ssl.mzstatic.com/image/thumb/PurpleSource221/v4/86/df/b0/86dfb0e2-c114-195e-7bc2-ed6a36c2c7f6/418b53f9-6a1e-4504-97c0-cb952b2e21c3_Simulator_Screenshot_-_iPhone_14_Plus_-_2024-03-31_at_10.59.48.png/400x800bb.png)
![avatar](https://is1-ssl.mzstatic.com/image/thumb/PurpleSource221/v4/72/3d/59/723d5909-33d2-5d82-3913-b10d0c7adca2/53e9cccf-d3c4-4bee-b06f-537658b7cf6a_Simulator_Screenshot_-_iPhone_14_Plus_-_2024-03-31_at_10.59.53.png/400x800bb.png)
![avatar](https://is1-ssl.mzstatic.com/image/thumb/PurpleSource221/v4/6f/e0/0b/6fe00b15-4729-2b02-7369-e6cc6b003f7d/fac6e250-14a9-43fb-ab42-8d2fe54c11b5_Simulator_Screenshot_-_iPhone_14_Plus_-_2024-03-31_at_11.02.51.png/400x800bb.png)
![avatar](https://is1-ssl.mzstatic.com/image/thumb/PurpleSource221/v4/98/81/5c/98815cfa-bc38-29ce-1341-556e94873206/884ae8e7-5a75-4ff5-bf03-1c61ed33064f_Simulator_Screenshot_-_iPhone_14_Plus_-_2024-03-31_at_11.03.23.png/400x800bb.png)
![avatar](https://is1-ssl.mzstatic.com/image/thumb/PurpleSource211/v4/6c/5e/f5/6c5ef5a7-7cf8-7725-4033-3bd870364f6d/7991c427-d0e9-4831-94ea-a83a30d3045d_Simulator_Screenshot_-_iPhone_14_Plus_-_2024-03-31_at_11.34.33.png/400x800bb.png)
![avatar](https://is1-ssl.mzstatic.com/image/thumb/PurpleSource211/v4/df/eb/b1/dfebb17d-fc1a-3128-ab7f-ecd5ebf192bf/96726472-6638-4ad8-93a8-c610d182ceaf_Simulator_Screenshot_-_iPhone_14_Plus_-_2024-03-31_at_11.35.16.png/400x800bb.png)
![avatar](https://is1-ssl.mzstatic.com/image/thumb/PurpleSource221/v4/69/95/09/699509a1-9561-97dd-b50c-043c6f3ef0c4/ba8372c9-fdfb-41ca-bb8a-05c0eed01b86_Simulator_Screenshot_-_iPhone_14_Plus_-_2024-03-31_at_11.35.58.png/400x800bb.png)
**一个轻量的博客，我们可以在世界各地向手机分享不同的瞬间！**

Copyright © Mhc.
Tips
-------

-  If you have it, you can run the source code and see its principle.

-  If it really helps you, please tap the star of this repository to support us.
    最后支持的点个Star，交流群vx加17758917010，记住备注（看得懂就行）
