

#Persistent  ; 让脚本持续运行, 直到用户退出.
#SingleInstance  ; 只能运行一个程序实例
; OnExit, closeProxy()   ; 退出的时候执行OnExit钩子函数
; 托盘菜单
Menu, tray, NoStandard   ; 关闭默认菜单
Menu, tray, Add, 关闭代理, closeProxyHandler
Menu, tray, Add, pac模式, pacProxyHandler
Menu, tray, Add, 全局模式, allProxyHandler
Menu, tray, Add   ; 添加分割线
Menu, tray, Add, 配置, configHandler
Menu, tray, Add, 编辑pac, editPacHandler
Menu, tray, Add   ; 添加分割线
Menu, tray, Add, 关于, aboutHandler
Menu, tray, Add   ; 添加分割线
Menu, tray, Add, 退出, exitHandler

; pac的http服务监听端口
IniRead, pac_port, gpclient.conf, main, pacport
; MsgBox, The value is %pac_port%.
global pacPort := pac_port
IniRead, proxy_port, gpclient.conf, main, proxyport
; MsgBox, The value is %proxy_port%.
global proxyPort := proxy_port

; 当前选择的模式
global currentMode := 1

; pacserver的pid
global pacserverId := -999

; 默认开启pac
choiceMode(1)
pacSysProxy()
; 运行start.vbs
Run start.vbs
return 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; 运行cmd命令
; RunCMD(command) {
;     Run, % ComSpec " /C" command, , Hide
; }


; 关闭代理
clearSysProxy(){
    if(pacserverId != -999){
        Process, Close, %pacserverId%
    }
    ; RunCMD("taskkill /f /im pacserver.exe")
    RegWrite, REG_DWORD, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Internet Settings, ProxyEnable, 0
    ; RunCMD("reg add ""HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings"" /v ProxyEnable /t REG_DWORD /d 0 /f" )
    RegWrite, REG_SZ, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Internet Settings, ProxyServer, ""
    ; RunCMD("reg add ""HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings"" /v ProxyServer /d """" /f" )
    ; RunCMD("reg delete ""HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings"" /v ProxyOverride /f" )
    RegDelete, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Internet Settings, ProxyOverride
    ; RunCMD("reg delete ""HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings"" /v AutoConfigURL /f" )
    RegDelete, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Internet Settings, AutoConfigURL
    ; Run proxy_setting_for_win/cancel.bat
}

; pac模式
pacSysProxy(){
    clearSysProxy()
    ; sleep, 1000
    Random, rand, 100000, 999999
    ; RunCMD("reg add ""HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings"" /v AutoConfigURL /d ""http://127.0.0.1:" . pacPort . "/pacfile?r=" . rand . """ /f" )
    RegWrite, REG_SZ, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Internet Settings, AutoConfigURL, http://127.0.0.1:%pacPort%/pacfile?r=%rand%
    ; RunCMD("pacserver.exe " . pacPort . " " . proxyPort)
    Run, pacserver.exe %pacPort% %proxyPort%, , Hide, pacserverId
}

; 全局模式
allSysProxy(){
    clearSysProxy()
    ; RunCMD("reg add ""HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings"" /v ProxyEnable /t REG_DWORD /d 1 /f " )
    RegWrite, REG_DWORD, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Internet Settings, ProxyEnable, 1
    ; RunCMD("reg add ""HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings"" /v ProxyServer /d ""http=127.0.0.1:" . proxyPort . ";https=127.0.0.1:" . proxyPort . """ /f" )
    RegWrite, REG_SZ, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Internet Settings, ProxyServer, http://127.0.0.1:%proxyPort%;https=127.0.0.1:%proxyPort%
    ; 此处是参考ss客户端的设置
    proxy_skip_hosts := "localhost;127.*;10.*;172.16.*;172.17.*;172.18.*;172.19.*;172.20.*;172.21.*;172.22.*;172.23.*;172.24.*;172.25.*;172.26.*;172.27.*;172.28.*;172.29.*;172.30.*;172.31.*;192.168.*"
    ; RunCMD("reg add ""HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings"" /v ProxyOverride /t REG_SZ /d """ . proxy_skip_hosts . """ /f " )
    RegWrite, REG_SZ, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Internet Settings, ProxyOverride, %proxy_skip_hosts%
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
        menu, tray, Check, 关闭代理   ; 打勾
        menu, tray, Disable, 关闭代理  ; 禁用
    } else if ( mode==1 ) {
        ; 是否已经选择该选项
        menu, tray, Check, pac模式   ; 打勾
        menu, tray, Disable, pac模式  ; 禁用
    } else if ( mode==2 ) {
        ; 是否已经选择该选项
        menu, tray, Check, 全局模式   ; 打勾
        menu, tray, Disable, 全局模式  ; 禁用
    }
}

; 设置代理模式
setProxyMode(mode){
    if ( mode==0 ){
        clearSysProxy()
    } else if ( mode==1 ){
        pacSysProxy()
    } else if ( mode==2 ){
        allSysProxy()
    }
    currentMode := mode
}

; 关闭代理
closeProxyHandler:
    choiceMode(0)
    setProxyMode(0)
return

; pac模式
pacProxyHandler:
    choiceMode(1)
    setProxyMode(1)
return

; 全局模式
allProxyHandler:
    choiceMode(2)
    setProxyMode(2)
return

; 配置GUI
configHandler:
    Gui, 1: Add, Text, , proxy的端口：
    Gui, 1: Add, Edit, Number Limit5 vProxyPort, %proxyPort%
    Gui, 1: Add, Text, , pac服务的端口：
    Gui, 1: Add, Edit, Number Limit5 vPacPort, %pacPort%
    Gui, 1: Add, Button, Default w80, 保存   
    Gui, 1: Show
return

; 把配置的端口写入
Button保存:
    ; MsgBox, %currentMode%
    ; 从GUI中获取Edit中vProxyPort的值
    GuiControlGet, ProxyPort
    if(ProxyPort==""){
        MsgBox, ProxyPort不能为空！
        return
    }
    port := ProxyPort
    if (port < 1 or port > 65535) {
        MsgBox, ProxyPort填写异常！只能是1~65535！
        return
    }
    ; 从GUI中获取Edit中vPacPort的值
    GuiControlGet, PacPort
    if(PacPort==""){
        MsgBox, PacPort不能为空！
        return
    }
    port := PacPort
    if (port < 1 or port > 65535) {
        MsgBox, PacPort填写异常！只能是1~65535！
        return
    }
    ; 把修改的值写入配置
    IniWrite, %ProxyPort%, gpclient.conf, main, proxyport
    ; 把修改的值写入配置
    IniWrite, %PacPort%, gpclient.conf, main, pacport
    ; 重新配置
    setProxyMode(currentMode)
    MsgBox, 保存成功
    Gui, 1: Destroy
return

; 配置窗口关闭的时候destroy
GuiClose:
    Gui, 1: Destroy
return

; 编辑pac文件
editPacHandler:
    Run, pac.txt
return

; 关于，打开主页
aboutHandler:
    Run, https://github.com/fuhuo/goproxy-client-gui
return

; 退出
exitHandler:
    clearSysProxy()
    ; RunCMD("taskkill /f /im proxy.exe")
    Process, Close, proxy.exe
    Sleep, 500
ExitApp    ; 退出程序
