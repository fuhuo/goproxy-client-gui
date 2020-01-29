

#Persistent  ; 让脚本持续运行, 直到用户退出.
#SingleInstance  ; 只能运行一个程序实例
; OnExit, closeProxy()   ; 退出的时候执行OnExit钩子函数
; 托盘菜单
Menu, tray, NoStandard   ; 关闭默认菜单
Menu, tray, Add   ; 添加分割线
Menu, tray, Add, 关闭代理, closeProxyHandler
Menu, tray, Add, pac模式, pacProxyHandler
Menu, tray, Add, 全局模式, allProxyHandler
Menu, tray, Add, 退出, exitHandler
Menu, tray, Add   ; 添加分割线

; pac的http服务监听端口
global pacPort := 1079
global proxyPort := 1080

; 默认开启pac
choiceMode(1)
pacSysProxy()
Run start.vbs
return 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; 运行cmd命令
RunCMD(command) {
    Run, % ComSpec " /C" command, , Hide
}


; 关闭代理
clearSysProxy(){
    RunCMD("taskkill /f /im pacserver.exe")
    RunCMD("reg add ""HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings"" /v ProxyEnable /t REG_DWORD /d 0 /f" )
    RunCMD("reg add ""HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings"" /v ProxyServer /d """" /f" )
    RunCMD("reg delete ""HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings"" /v ProxyOverride /f" )
    RunCMD("reg delete ""HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings"" /v AutoConfigURL /f" )
    ; Run proxy_setting_for_win/cancel.bat
}

; pac模式
pacSysProxy(){
    clearSysProxy()
    sleep, 1000
    Random, rand, 100000, 999999
    RunCMD("reg add ""HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings"" /v AutoConfigURL /d ""http://127.0.0.1:" . pacPort . "/pacfile?r=" . rand . """ /f" )
    RunCMD("pacserver.exe " . pacPort . " " . proxyPort)
}

; 全局模式
allSysProxy(){
    clearSysProxy()
    RunCMD("reg add ""HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings"" /v ProxyEnable /t REG_DWORD /d 1 /f " )
    RunCMD("reg add ""HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings"" /v ProxyServer /d ""http=127.0.0.1:" . proxyPort . ";https=127.0.0.1:" . proxyPort . """ /f" )
    ; 此处是参考ss客户端的设置
    proxy_skip_hosts := "localhost;127.*;10.*;172.16.*;172.17.*;172.18.*;172.19.*;172.20.*;172.21.*;172.22.*;172.23.*;172.24.*;172.25.*;172.26.*;172.27.*;172.28.*;172.29.*;172.30.*;172.31.*;192.168.*"
    RunCMD("reg add ""HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings"" /v ProxyOverride /t REG_SZ /d """ . proxy_skip_hosts . """ /f " )
}


; 取消所有勾选项
unCheckAllItems(){
    menu, tray, UnCheck, 关闭代理
    menu, tray, Enable, 关闭代理
    menu, tray, UnCheck, pac模式
    menu, tray, Enable, pac模式
    menu, tray, UnCheck, 全局模式
    menu, tray, Enable, 全局模式
}

; 勾选选项
choiceMode(mode){
    unCheckAllItems()
    if ( mode==0 ) {
        ; 是否已经选择该选项
        menu, tray, ToggleCheck, 关闭代理   ; 打勾
        menu, tray, ToggleEnable, 关闭代理  ; 禁用
    } else if ( mode==1 ) {
        ; 是否已经选择该选项
        menu, tray, ToggleCheck, pac模式   ; 打勾
        menu, tray, ToggleEnable, pac模式  ; 禁用
    } else if ( mode==2 ) {
        ; 是否已经选择该选项
        menu, tray, ToggleCheck, 全局模式   ; 打勾
        menu, tray, ToggleEnable, 全局模式  ; 禁用
    }
}

; 关闭代理
closeProxyHandler:
    choiceMode(0)
    clearSysProxy()
return

; pac模式
pacProxyHandler:
    choiceMode(1)
    pacSysProxy()
return

; 全局模式
allProxyHandler:
    choiceMode(2)
    allSysProxy()
return


; 退出
exitHandler:
    clearSysProxy()
    RunCMD("taskkill /f /im proxy.exe")
ExitApp    ; 退出程序
