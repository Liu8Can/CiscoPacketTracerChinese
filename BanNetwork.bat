@ECHO OFF
:: �ű����ƣ�Cisco Packet Tracer ����ǽ����
:: ���ܣ�������ɾ������ǽ���򣬽�ֹ��ָ� Cisco Packet Tracer ����������

:: ������ԱȨ��
(PUSHD "%~DP0")&(REG QUERY "HKU\S-1-5-19">NUL 2>&1)||(
    powershell -Command "Start-Process '%~dpnx0' -Verb RunAs"
    EXIT
)
Setlocal EnableDelayedExpansion
:: ���ñ�����ɫ��ǰ����ɫ������ɫ����������ɫ���֣�
color 3F

:: ���ñ��������
title ��ֹ Cisco Packet Tracer ��������
echo =====================================================================
echo            ��ֹ Cisco Packet Tracer ��������
echo            BY ����ͬѧ ��������
echo            GitHub https://github.com/Liu8Can/CiscoPacketTracerChinese
echo            ������bug��ͨ��ͬ�����ںŻ�GitHub issue���ҷ���
echo =====================================================================
echo ���ű�����������ǽ���򣬽�ֹ Cisco Packet Tracer ���������ӡ�
echo �Դﵽ�����˺���֤��Ŀ�ģ��Ҳ�Ӱ��ʹ�����顣
echo.

:: �Զ�����·��
call :SearchPath

:: ����Զ�����ʧ�ܣ�����ʹ��Ĭ��·�������Ĭ��·������������ʾ�û�����·��
if "%programPath%"=="" (
    set "programPath=%defaultPath%"
    if not exist "%programPath%" (
        echo δ���Զ��ҵ� PacketTracer.exe �İ�װ·����
        set /p programPath=������ Cisco Packet Tracer �Ŀ�ִ���ļ�·����
    )
)

:: ȥ��·�����˵����ţ�����У�
set programPath=%programPath:"=%

:: ���·���Ƿ����
if not exist "%programPath%" (
    echo ����·�� "%programPath%" �����ڣ���������ԡ�
    pause
    exit /b 1
)

:: ��ʾ�û�ѡ�����
echo �ҵ�·��: %programPath%
echo ��ѡ�������
echo 1. ��������ǽ���򣨽�ֹ�������ӣ�
echo 2. ɾ������ǽ���򣨻ָ��������ӣ�
echo 3. �˳�
set /p choice=������ѡ�� (1��2 �� 3):

if "%choice%"=="1" (
    :: ��������ǽ����
    call :EnableFirewall
) else if "%choice%"=="2" (
    :: ɾ������ǽ����
    call :DisableFirewall
) else if "%choice%"=="3" (
    :: �˳�
    echo �����˳�...
    echo 3
    timeout /t 1 /nobreak >nul
    echo 2
    timeout /t 1 /nobreak >nul
    echo 1
    timeout /t 1 /nobreak >nul
    exit /b 0
) else (
    echo ������Чѡ������� 1��2 �� 3��
    pause
    exit /b 1
)

:: �����ű�
exit /b 0

:EnableFirewall
    :: �û�ȷ��
    set /p confirm=ȷ��Ҫ��ֹ "%programPath%" ������������(Y/N):
    if /i "%confirm%" neq "Y" (
        echo ������ȡ����
        pause
        exit /b 0
    )

    :: ɾ�����еķ���ǽ���򣨱����ظ���
    echo ����ɾ�����еķ���ǽ����...
    netsh advfirewall firewall delete rule name="Cisco Packet Tracer ��վ" >nul 2>&1
    netsh advfirewall firewall delete rule name="Cisco Packet Tracer ��վ" >nul 2>&1

    :: ����µķ���ǽ����
    echo ������ӷ���ǽ����...
    netsh advfirewall firewall add rule name="Cisco Packet Tracer ��վ" dir=out action=block profile=any program="%programPath%" enable=yes
    if %errorlevel% neq 0 (
        echo ���󣺴�����վ����ʧ�ܡ�
        pause
        exit /b 1
    )

    netsh advfirewall firewall add rule name="Cisco Packet Tracer ��վ" dir=in action=block profile=any program="%programPath%" enable=yes
    if %errorlevel% neq 0 (
        echo ���󣺴�����վ����ʧ�ܡ�
        pause
        exit /b 1
    )

    echo ����ǽ�����ѳɹ�������"%programPath%" �����������ѱ���ֹ��
    pause
    exit /b 0

:DisableFirewall
    :: �û�ȷ��
    set /p confirm=ȷ��Ҫ�ָ� Cisco Packet Tracer ������������(Y/N):
    if /i "%confirm%" neq "Y" (
        echo ������ȡ����
        pause
        exit /b 0
    )

    :: ɾ������ǽ����
    echo ����ɾ������ǽ����...
    netsh advfirewall firewall delete rule name="Cisco Packet Tracer ��վ" >nul 2>&1
    if %errorlevel% neq 0 (
        echo ���棺ɾ����վ����ʧ�ܣ����ܹ��򲻴��ڡ�
    )

    netsh advfirewall firewall delete rule name="Cisco Packet Tracer ��վ" >nul 2>&1
    if %errorlevel% neq 0 (
        echo ���棺ɾ����վ����ʧ�ܣ����ܹ��򲻴��ڡ�
    )

    echo ����ǽ�����ѳɹ�ɾ����Cisco Packet Tracer �����������ѻָ���
    pause
    exit /b 0

:SearchPath
    echo �����Զ����� PacketTracer.exe �İ�װ·��...
    set "programPath="
    set "defaultPath=C:\Program Files\Cisco Packet Tracer 8.2.2\bin\PacketTracer.exe"

    :: ��ȡĬ��·�������·������
    set "relativePath=%defaultPath:*:=%"

    :: �� C �̿�ʼ���ԣ���ೢ�� 5 ���̷�
    set "driveCount=0"
    for %%a in (C D E F G) do (
        if !driveCount! lss 5 (
            set "testPath=%%a:%relativePath%"
            if exist "!testPath!" (
                set "programPath=!testPath!"
                goto :SearchPath_End
            )
            set /a "driveCount+=1"
        )
    )

    :: ���ͨ���̷��滻δ�ҵ�·�������Բ��ҿ�ݷ�ʽ
    if not defined programPath (
        for %%a in ("ProgramData" "AppData") do (
            for /f "delims=" %%b in ('dir /s /b "%SystemDrive%\Users\%%~na\%%a\Microsoft\Windows\Start Menu\Programs\*.lnk" ^| findstr /i "Cisco Packet Tracer"') do (
                for /f "tokens=2 delims=, " %%c in ('wmic datafile where "name='%%~fb'" get Target /value ^| findstr "="') do (
                    set "programPath=%%c"
                    set "programPath=!programPath:\=\\!"
                    if exist "!programPath!" goto :SearchPath_End
                )
            )
        )
    )

:SearchPath_End
    exit /b 0