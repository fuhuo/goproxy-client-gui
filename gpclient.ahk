

#Persistent  ; �ýű���������, ֱ���û��˳�.
#SingleInstance  ; ֻ������һ������ʵ��
; OnExit, closeProxy()   ; �˳���ʱ��ִ��OnExit���Ӻ���
; ���̲˵�
Menu, tray, NoStandard   ; �ر�Ĭ�ϲ˵�
Menu, tray, Add   ; ��ӷָ���
Menu, tray, Add, �رմ���, closeProxyHandler
Menu, tray, Add, pacģʽ, pacProxyHandler
Menu, tray, Add, ȫ��ģʽ, allProxyHandler
Menu, tray, Add, �˳�, exitHandler
Menu, tray, Add   ; ��ӷָ���

; pac��http��������˿�
global pacPort := 1079
global proxyPort := 1080

; Ĭ�Ͽ���pac
choiceMode(1)
pacSysProxy()
Run start.vbs
return 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; ����cmd����
RunCMD(command) {
    Run, % ComSpec " /C" command, , Hide
}


; �رմ���
clearSysProxy(){
    RunCMD("taskkill /f /im pacserver.exe")
    RunCMD("reg add ""HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings"" /v ProxyEnable /t REG_DWORD /d 0 /f" )
    RunCMD("reg add ""HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings"" /v ProxyServer /d """" /f" )
    RunCMD("reg delete ""HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings"" /v ProxyOverride /f" )
    RunCMD("reg delete ""HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings"" /v AutoConfigURL /f" )
    ; Run proxy_setting_for_win/cancel.bat
}

; pacģʽ
pacSysProxy(){
    clearSysProxy()
    sleep, 1000
    Random, rand, 100000, 999999
    RunCMD("reg add ""HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings"" /v AutoConfigURL /d ""http://127.0.0.1:" . pacPort . "/pacfile?r=" . rand . """ /f" )
    RunCMD("pacserver.exe " . pacPort . " " . proxyPort)
}

; ȫ��ģʽ
allSysProxy(){
    clearSysProxy()
    RunCMD("reg add ""HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings"" /v ProxyEnable /t REG_DWORD /d 1 /f " )
    RunCMD("reg add ""HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings"" /v ProxyServer /d ""http=127.0.0.1:" . proxyPort . ";https=127.0.0.1:" . proxyPort . """ /f" )
    ; �˴��ǲο�ss�ͻ��˵�����
    proxy_skip_hosts := "localhost;127.*;10.*;172.16.*;172.17.*;172.18.*;172.19.*;172.20.*;172.21.*;172.22.*;172.23.*;172.24.*;172.25.*;172.26.*;172.27.*;172.28.*;172.29.*;172.30.*;172.31.*;192.168.*"
    RunCMD("reg add ""HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings"" /v ProxyOverride /t REG_SZ /d """ . proxy_skip_hosts . """ /f " )
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
        menu, tray, ToggleCheck, �رմ���   ; ��
        menu, tray, ToggleEnable, �رմ���  ; ����
    } else if ( mode==1 ) {
        ; �Ƿ��Ѿ�ѡ���ѡ��
        menu, tray, ToggleCheck, pacģʽ   ; ��
        menu, tray, ToggleEnable, pacģʽ  ; ����
    } else if ( mode==2 ) {
        ; �Ƿ��Ѿ�ѡ���ѡ��
        menu, tray, ToggleCheck, ȫ��ģʽ   ; ��
        menu, tray, ToggleEnable, ȫ��ģʽ  ; ����
    }
}

; �رմ���
closeProxyHandler:
    choiceMode(0)
    clearSysProxy()
return

; pacģʽ
pacProxyHandler:
    choiceMode(1)
    pacSysProxy()
return

; ȫ��ģʽ
allProxyHandler:
    choiceMode(2)
    allSysProxy()
return


; �˳�
exitHandler:
    clearSysProxy()
    RunCMD("taskkill /f /im proxy.exe")
ExitApp    ; �˳�����
