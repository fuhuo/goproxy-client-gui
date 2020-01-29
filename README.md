# goproxy-client-gui
### 本gui基于https://github.com/snail007/goproxy 的客户端程序

1、本程序暂时只支持windows(只在win10的64位系统测试过)

2、需要把gpclient.exe、pacserver.exe【[下载](https://github.com/fuhuo/goproxy-client-gui/releases)】和pac.txt（自备，可使用ss的）放在goproxy的client目录下

3、使用前先配置好自己的bootstrap.bat   
~~（注意：之前没考虑好端口的问题，目前只能是goproxy中使用1080端口作为代理端口，后续会优化）~~

4、配置成功后，通过双击gpclient.exe运行，运行后程序会自动运行start.vbs，退出会自动退出proxy.exe

5、启动后在托盘会有小图标，通过右键【配置】菜单，配置proxy的端口和pac服务的端口，其中proxy的端口必须与你当前boostrap.bat里面配置的-p参数的值一致；pac的服务端口随意，只要不和其他端口重复导致端口被占用即可

6、在托盘中右键即可选择“关闭”、“pac”和“全局”等模式

已知问题：

~~1、之前没考虑好端口的问题，目前只能是goproxy中使用1080端口作为代理端口，后续会优化~~

~~2、pac的http server端口也写死了1079，这两个端口如果有冲突，目前需要自己下载ahk脚本并用autohotkey进行重新编译成exe，后续会优化~~

1、有时候会出现系统代理配置不完整的情况，需要手动重新切换一下模式，待解决
