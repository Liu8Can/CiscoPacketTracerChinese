@ECHO OFF
:: �ű����ƣ�Cisco Packet Tracer ����ǽ����
:: ���ܣ�������ɾ������ǽ���򣬽�ֹ��ָ� Cisco Packet Tracer ����������

:: ������ԱȨ��
(PUSHD "%~DP0")&(REG QUERY "HKU\S-1-5-19">NUL 2>&1)||(
    powershell -Command "Start-Process '%~dpnx0' -Verb RunAs"
    EXIT
)
:: ���ñ�����ɫ��ǰ����ɫ������ɫ����������ɫ���֣�
color 3F

:: ���ñ��������
title ��ֹ Cisco Packet Tracer ��������
echo =====================================================
echo            ��ֹ Cisco Packet Tracer ��������
echo            BY ����ͬѧ ��������
echo            GitHub https://github.com/Liu8Can/CiscoPacketTracerChinese
echo            ������bug��ͨ��ͬ�����ںŻ�GitHub issue���ҷ���
echo =====================================================
echo ���ű�����������ǽ���򣬽�ֹ Cisco Packet Tracer ���������ӡ�
echo �Դﵽ�����˺���֤��Ŀ�ģ��Ҳ�Ӱ��ʹ�����顣
echo.
:: ����Ĭ��·��
set defaultPath="C:\Program Files\Cisco Packet Tracer 8.2.2\bin\PacketTracer.exe"

:: ��ʾ�û�ѡ�����
echo ��ѡ�������
echo 1. ��������ǽ���򣨽�ֹ�������ӣ�
echo 2. ɾ������ǽ���򣨻ָ��������ӣ�
set /p choice=������ѡ�� (1 �� 2):

if "%choice%"=="1" (
    :: ��������ǽ����
    call :EnableFirewall
) else if "%choice%"=="2" (
    :: ɾ������ǽ����
    call :DisableFirewall
) else (
    echo ������Чѡ������� 1 �� 2��
    pause
    exit /b 1
)

:: �����ű�
exit /b 0

:EnableFirewall
    :: ��ʾ�û�����·��
    echo Ĭ��·��Ϊ %defaultPath%
    echo ֱ�ӻس���ʹ��Ĭ��·����
    set /p programPath=������ Cisco Packet Tracer �Ŀ�ִ���ļ�·����

    :: ����û�δ����·������ʹ��Ĭ��·��
    if "%programPath%"=="" (
        set programPath=%defaultPath%
    )

    :: ȥ��·�����˵����ţ�����У�
    set programPath=%programPath:"=%

    :: ���·���Ƿ����
    if not exist "%programPath%" (
        echo ����·�� "%programPath%" �����ڣ���������ԡ�
        pause
        exit /b 1
    )

    :: �û�ȷ��
    set /p confirm=ȷ��Ҫ��ֹ Cisco Packet Tracer ������������(Y/N):
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

    echo ����ǽ�����ѳɹ�������Cisco Packet Tracer �����������ѱ���ֹ��
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