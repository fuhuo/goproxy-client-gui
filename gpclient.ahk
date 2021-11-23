;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ��Ŀ��ҳhttps://github.com/fuhuo/goproxy-client-gui
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#Persistent  ; �ýű���������, ֱ���û��˳�.
#SingleInstance  ; ֻ������һ������ʵ��
; OnExit, closeProxy()   ; �˳���ʱ��ִ��OnExit���Ӻ���

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ��ʼ��
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ���ù���Ŀ¼Ϊ�ű�Ŀ¼
SetWorkingDir %A_ScriptDir%

; ����Ƿ�ȱ�ٱ�Ҫ�����ļ�
If(not FileExist("gpclient.conf")){
    MsgBox, "ȱ��gpclient.conf�ļ���"
    ExitApp
}else if ( not FileExist("pac.txt")){
    MsgBox, "ȱ��pac.txt�ļ���"
    ExitApp
}

; ȫ�ֵ�ǰѡ���ģʽ
global currentMode := 1
; ��ȡ�ϴιر�ʱ��ѡ���ģʽ
IniRead, current_mode, gpclient.conf, main, proxymode
if ( current_mode >= 0 and current_mode <= 2 ){
    currentMode := current_mode
}else {
    setProxyMode(currentMode)
}


; ��ȡpac��http�������host
IniRead, pac_host, gpclient.conf, main, pachost
if(pac_host=="ERROR" || pac_host==""){
    pac_host := "127.0.0.1"
    ; ���޸ĵ�ֵд������
    IniWrite, %pac_host%, gpclient.conf, main, pachost
}
; ȫ��pac server host
global pacHost := pac_host

; ��ȡpac��http��������˿�
IniRead, pac_port, gpclient.conf, main, pacport
if(pac_port=="ERROR" || pac_port==""){
    pac_port := 1079
    ; ���޸ĵ�ֵд������
    IniWrite, %pac_port%, gpclient.conf, main, pacport
}
; ȫ��pac server�˿�
global pacPort := pac_port

; ��ȡproxy�˿� 
IniRead, proxy_port, gpclient.conf, main, proxyport
if(proxy_port=="ERROR" || proxy_port==""){
    proxy_port := 1080
    ; ���޸ĵ�ֵд������
    IniWrite, %proxy_port%, gpclient.conf, main, proxyport
}
; ȫ��proxy�˿�
global proxyPort := proxy_port

; ��������
IniRead, startup_cmd, gpclient.conf, main, startupcommand
if(startup_cmd=="ERROR"){
    startup_cmd := "start.vbs"
    ; ���޸ĵ�ֵд������
    IniWrite, %startup_cmd%, gpclient.conf, main, startupcommand
}
; ȫ��ʹ����������
global startupCommand := startup_cmd

; �˳�ʱkill�ĳ���
IniRead, kill_onexit, gpclient.conf, main, killonexit
if(kill_onexit=="ERROR"){
    kill_onexit := "proxy.exe"
    ; ���޸ĵ�ֵд������
    IniWrite, %kill_onexit%, gpclient.conf, main, killonexit
}
; ȫ��ʹ����������
global killOnExit := kill_onexit


; pacserver��pid
global pacserverId := -999

; ����������ݷ�ʽ
global startOnBootLnkFile = A_AppData . "\Microsoft\Windows\Start Menu\Programs\Startup\gpclient.lnk"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ���̲˵� 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Menu, tray, NoStandard   ; �ر�Ĭ�ϲ˵�
; չʾproxy�˿ڣ�ֻ��չʾ������disable
Menu, tray, Add, proxy�˿�:%proxyPort%, configHandler
Menu, tray, Disable, proxy�˿�:%proxyPort%,
Menu, tray, Add   ; ��ӷָ���
Menu, tray, Add, �رմ���, closeProxyHandler
Menu, tray, Add, pacģʽ, pacProxyHandler
Menu, tray, Add, ȫ��ģʽ, allProxyHandler
Menu, tray, Add   ; ��ӷָ���
; Menu, tray, Add, ����, configHandler
; ����->�Ӳ˵�
Menu, subtraySetting, Add, �˿�, configHandler
Menu, subtraySetting, Add, pac, editPacHandler
Menu, subtraySetting, Add, ��������, startOnBootHandler
startOnBootMenuCheck()
Menu, tray, Add, ����, :subtraySetting    ; �������ò˵����Ӳ˵�ָ���Ϸ���subtraySetting
Menu, tray, Add   ; ��ӷָ���
Menu, tray, Add, ����, aboutHandler
Menu, tray, Add   ; ��ӷָ���
Menu, tray, Add, �˳�, exitHandler
setTrayTips()

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Main
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Ĭ�ϴ��ϴεĴ���ģʽ
choiceMode(currentMode)
setProxyMode(currentMode)
; ����start.vbs
if(startupcommand != ""){
    Run %startupCommand%
}
return 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ��������
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; ����cmd����
; RunCMD(command) {
;     Run, % ComSpec " /C" command, , Hide
; }


; �رմ���
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

; pacģʽ
pacSysProxy(){
    clearSysProxy()
    ; sleep, 1000
    Random, rand, 100000, 999999
    ; RunCMD("reg add ""HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings"" /v AutoConfigURL /d ""http://127.0.0.1:" . pacPort . "/pacfile?r=" . rand . """ /f" )
    RegWrite, REG_SZ, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Internet Settings, AutoConfigURL, http://127.0.0.1:%pacPort%/pacfile?r=%rand%
    ; RunCMD("pacserver.exe " . pacPort . " " . proxyPort)
    Run, pacserver.exe %pacHost% %pacPort% %proxyPort%, , Hide, pacserverId
}

; ȫ��ģʽ
allSysProxy(){
    clearSysProxy()
    ; RunCMD("reg add ""HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings"" /v ProxyEnable /t REG_DWORD /d 1 /f " )
    RegWrite, REG_DWORD, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Internet Settings, ProxyEnable, 1
    ; RunCMD("reg add ""HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings"" /v ProxyServer /d ""http=127.0.0.1:" . proxyPort . ";https=127.0.0.1:" . proxyPort . """ /f" )
    RegWrite, REG_SZ, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Internet Settings, ProxyServer, http://127.0.0.1:%proxyPort%;https=127.0.0.1:%proxyPort%
    ; �˴��ǲο�ss�ͻ��˵�����
    proxy_skip_hosts := "localhost;127.*;10.*;172.16.*;172.17.*;172.18.*;172.19.*;172.20.*;172.21.*;172.22.*;172.23.*;172.24.*;172.25.*;172.26.*;172.27.*;172.28.*;172.29.*;172.30.*;172.31.*;192.168.*"
    ; RunCMD("reg add ""HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings"" /v ProxyOverride /t REG_SZ /d """ . proxy_skip_hosts . """ /f " )
    RegWrite, REG_SZ, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Internet Settings, ProxyOverride, %proxy_skip_hosts%
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; UI����
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; �޸�proxy�˿ڲ˵�����
renameProxyPortMenuItem(oldport, newport){
    menu, tray, Rename, proxy�˿�:%oldport%, proxy�˿�:%newport%
}

; ȡ�����й�ѡ��
unCheckAllItems(){
    menu, tray, UnCheck, �رմ���
    menu, tray, Enable, �رմ���
    menu, tray, UnCheck, pacģʽ
    menu, tray, Enable, pacģʽ
    menu, tray, UnCheck, ȫ��ģʽ
    menu, tray, Enable, ȫ��ģʽ
}

; ��ѡ����ѡ��
choiceMode(mode){
    unCheckAllItems()
    if ( mode==0 ) {
        ; �Ƿ��Ѿ�ѡ���ѡ��
        menu, tray, Check, �رմ���   ; ��
        menu, tray, Disable, �رմ���  ; ����
    } else if ( mode==1 ) {
        ; �Ƿ��Ѿ�ѡ���ѡ��
        menu, tray, Check, pacģʽ   ; ��
        menu, tray, Disable, pacģʽ  ; ����
    } else if ( mode==2 ) {
        ; �Ƿ��Ѿ�ѡ���ѡ��
        menu, tray, Check, ȫ��ģʽ   ; ��
        menu, tray, Disable, ȫ��ģʽ  ; ����
    }
}

; ����������ť�Ƿ�ѡ
startOnBootMenuCheck(){
    if(FileExist(startOnBootLnkFile)){
        menu, subtraySetting, Check, ��������
    }else{
        menu, subtraySetting, UnCheck, ��������
    }
}

; ���������ͣ������ͼ���ϵ���ʾ����Ϣ��������ǰ����ģʽ��proxy�˿ڡ�pac�˿�
setTrayTips(){
    tipstxt := ""
    if(currentMode==0){
        tipstxt = %tipstxt%��ǰģʽ���رմ���
    }else if (currentMode==1){
        tipstxt = %tipstxt%��ǰģʽ��pacģʽ
    }else if (currentMode==2){
        tipstxt = %tipstxt%��ǰģʽ��ȫ��ģʽ
    }
    tipstxt = %tipstxt%`npacIP:%pacHost%`nproxy�˿�:%proxyPort%`npac�˿�:%pacPort%
    Menu, tray, Tip, %tipstxt%
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; �߼�����
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ���ô���ģʽ
setProxyMode(mode){
    if ( mode==0 ){
        clearSysProxy()
    } else if ( mode==1 ){
        pacSysProxy()
    } else if ( mode==2 ){
        allSysProxy()
    }
    currentMode := mode
    ; д������
    IniWrite, %currentMode%, gpclient.conf, main, proxymode
}

; �رմ���
closeProxyHandler:
    choiceMode(0)
    setProxyMode(0)
    setTrayTips()
return

; pacģʽ
pacProxyHandler:
    choiceMode(1)
    setProxyMode(1)
    setTrayTips()
return

; ȫ��ģʽ
allProxyHandler:
    choiceMode(2)
    setProxyMode(2)
    setTrayTips()
return

; ����GUI
configHandler:
    Gui, 1: Add, Text, , proxy�Ķ˿ڣ�
    Gui, 1: Add, Edit, Number Limit5 vProxyPort, %proxyPort%
    Gui, 1: Add, Text, , pac����Ķ˿ڣ�
    Gui, 1: Add, Edit, Number Limit5 vPacPort, %pacPort%
    Gui, 1: Add, Button, Default w80, ����   
    Gui, 1: Show
return

; �����õĶ˿�д��
Button����:
    ; MsgBox, %currentMode%
    ; ��GUI�л�ȡEdit��vProxyPort��ֵ
    oldProxyPort := proxyPort
    GuiControlGet, ProxyPort
    if(ProxyPort==""){
        MsgBox, ProxyPort����Ϊ�գ�
        return
    }
    port := ProxyPort
    if (port < 1 or port > 65535) {
        MsgBox, ProxyPort��д�쳣��ֻ����1~65535��
        return
    }
    newProxyPort := proxyPort
    ; ��GUI�л�ȡEdit��vPacPort��ֵ
    GuiControlGet, PacPort
    if(PacPort==""){
        MsgBox, PacPort����Ϊ�գ�
        return
    }
    port := PacPort
    if (port < 1 or port > 65535) {
        MsgBox, PacPort��д�쳣��ֻ����1~65535��
        return
    }
    ; ���޸ĵ�ֵд������
    IniWrite, %ProxyPort%, gpclient.conf, main, proxyport
    ; ���޸ĵ�ֵд������
    IniWrite, %PacPort%, gpclient.conf, main, pacport
    ; ��������
    setProxyMode(currentMode)
    MsgBox, ����ɹ�
    Gui, 1: Destroy
    ; �޸Ķ˿�չʾ�Ĳ˵�
    renameProxyPortMenuItem(oldProxyPort, newProxyPort)
    setTrayTips()
return

; ���ô��ڹرյ�ʱ��destroy
GuiClose:
    Gui, 1: Destroy
return

; �༭pac�ļ�
editPacHandler:
    Run, pac.txt
return

; ��������
startOnBootHandler:
; msgbox, %A_AppData%\Microsoft\Windows\Start Menu\Programs\Startup\gpclient.lnk
    if(FileExist(startOnBootLnkFile)){
        FileDelete, %startOnBootLnkFile%
    }else{
        FileCreateShortcut, %A_WorkingDir%\%A_ScriptName%, %startOnBootLnkFile%
    }
    startOnBootMenuCheck()
return

; ���ڣ�����ҳ
aboutHandler:
    Run, https://github.com/fuhuo/goproxy-client-gui
return

; �˳�
exitHandler:
    clearSysProxy()
    ; RunCMD("taskkill /f /im proxy.exe")
    if(killOnExit != ""){
        Process, Close, %killOnExit%
    }
    Sleep, 500
ExitApp    ; �˳�����
