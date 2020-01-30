

#Persistent  ; �ýű���������, ֱ���û��˳�.
#SingleInstance  ; ֻ������һ������ʵ��
; OnExit, closeProxy()   ; �˳���ʱ��ִ��OnExit���Ӻ���
; ���̲˵�
Menu, tray, NoStandard   ; �ر�Ĭ�ϲ˵�
Menu, tray, Add, �رմ���, closeProxyHandler
Menu, tray, Add, pacģʽ, pacProxyHandler
Menu, tray, Add, ȫ��ģʽ, allProxyHandler
Menu, tray, Add   ; ��ӷָ���
Menu, tray, Add, ����, configHandler
Menu, tray, Add, �༭pac, editPacHandler
Menu, tray, Add   ; ��ӷָ���
Menu, tray, Add, ����, aboutHandler
Menu, tray, Add   ; ��ӷָ���
Menu, tray, Add, �˳�, exitHandler

; pac��http��������˿�
IniRead, pac_port, gpclient.conf, main, pacport
; MsgBox, The value is %pac_port%.
global pacPort := pac_port
IniRead, proxy_port, gpclient.conf, main, proxyport
; MsgBox, The value is %proxy_port%.
global proxyPort := proxy_port

; ��ǰѡ���ģʽ
global currentMode := 1

; pacserver��pid
global pacserverId := -999

; Ĭ�Ͽ���pac
choiceMode(1)
pacSysProxy()
; ����start.vbs
Run start.vbs
return 

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
    Run, pacserver.exe %pacPort% %proxyPort%, , Hide, pacserverId
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


; ȡ�����й�ѡ��
unCheckAllItems(){
    menu, tray, UnCheck, �رմ���
    menu, tray, Enable, �رմ���
    menu, tray, UnCheck, pacģʽ
    menu, tray, Enable, pacģʽ
    menu, tray, UnCheck, ȫ��ģʽ
    menu, tray, Enable, ȫ��ģʽ
}

; ��ѡѡ��
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
}

; �رմ���
closeProxyHandler:
    choiceMode(0)
    setProxyMode(0)
return

; pacģʽ
pacProxyHandler:
    choiceMode(1)
    setProxyMode(1)
return

; ȫ��ģʽ
allProxyHandler:
    choiceMode(2)
    setProxyMode(2)
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
return

; ���ô��ڹرյ�ʱ��destroy
GuiClose:
    Gui, 1: Destroy
return

; �༭pac�ļ�
editPacHandler:
    Run, pac.txt
return

; ���ڣ�����ҳ
aboutHandler:
    Run, https://github.com/fuhuo/goproxy-client-gui
return

; �˳�
exitHandler:
    clearSysProxy()
    ; RunCMD("taskkill /f /im proxy.exe")
    Process, Close, proxy.exe
    Sleep, 500
ExitApp    ; �˳�����
