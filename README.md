# goproxy-client-gui
### 本gui程序基于https://github.com/snail007/goproxy 的客户端程序开发

### 快速使用说明

1、确保已配置好goproxy的client客户端【[下载](https://github.com/snail007/goproxy/releases)】的bootstrap.bat文件（确保proxy可正常使用）

2、【[下载](https://github.com/fuhuo/goproxy-client-gui/releases)】gpclient的最新版zip压缩包

3、把gpclient压缩包解压到goproxy的client同目录

4、找到合适的pac.txt文件，放到goproxy的client目录（可以直接拿ss客户端的）

5、双击打开gpclient.exe小托盘->右键，点击【配置】，proxy端口配置成与你boostrap.bat的-p参数的端口一致，pac服务端口不能与系统其他服务的端口（包括proxy的端口）重复

6、通过gpclient.exe小托盘->右键，选择“关闭”、“pac”和“全局”等模式使用。

### 说明

1、本程序基于ahk和go开发，暂时只支持windows(只在win10的64位系统测试过)

2、本程序通过调用proxy的start.vbs启用，安全退出时会关闭proxy.exe

### 已知问题：

~~1、之前没考虑好端口的问题，目前只能是goproxy中使用1080端口作为代理端口，后续会优化~~

~~2、pac的http server端口也写死了1079，这两个端口如果有冲突，目前需要自己下载ahk脚本并用autohotkey进行重新编译成exe，后续会优化~~

1、有时候会出现系统代理配置不完整的情况，需要手动重新切换一下模式，待解决

2、目前仅支持单个服务配置
