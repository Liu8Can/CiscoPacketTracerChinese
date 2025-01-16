@ECHO OFF
:: 脚本名称：Cisco Packet Tracer 防火墙管理
:: 功能：开启或删除防火墙规则，禁止或恢复 Cisco Packet Tracer 的网络连接

:: 检查管理员权限
(PUSHD "%~DP0")&(REG QUERY "HKU\S-1-5-19">NUL 2>&1)||(
    powershell -Command "Start-Process '%~dpnx0' -Verb RunAs"
    EXIT
)
Setlocal EnableDelayedExpansion
:: 设置背景颜色和前景颜色（湖蓝色背景，亮白色文字）
color 3F

:: 设置标题和主题
title 禁止 Cisco Packet Tracer 网络连接
echo =====================================================================
echo            禁止 Cisco Packet Tracer 网络连接
echo            BY 沧浪同学 哔哩哔哩
echo            GitHub https://github.com/Liu8Can/CiscoPacketTracerChinese
echo            如遇到bug请通过同名公众号或GitHub issue向我反馈
echo =====================================================================
echo 本脚本将创建防火墙规则，禁止 Cisco Packet Tracer 的网络连接。
echo 以达到禁用账号验证的目的，且不影响使用体验。
echo.

:: 自动搜索路径
call :SearchPath

:: 如果自动搜索失败，尝试使用默认路径，如果默认路径不存在则提示用户输入路径
if "%programPath%"=="" (
    set "programPath=%defaultPath%"
    if not exist "%programPath%" (
        echo 未能自动找到 PacketTracer.exe 的安装路径。
        set /p programPath=请输入 Cisco Packet Tracer 的可执行文件路径：
    )
)

:: 去掉路径两端的引号（如果有）
set programPath=%programPath:"=%

:: 检查路径是否存在
if not exist "%programPath%" (
    echo 错误：路径 "%programPath%" 不存在，请检查后重试。
    pause
    exit /b 1
)

:: 提示用户选择操作
echo 找到路径: %programPath%
echo 请选择操作：
echo 1. 开启防火墙规则（禁止网络连接）
echo 2. 删除防火墙规则（恢复网络连接）
echo 3. 退出
set /p choice=请输入选项 (1、2 或 3):

if "%choice%"=="1" (
    :: 开启防火墙规则
    call :EnableFirewall
) else if "%choice%"=="2" (
    :: 删除防火墙规则
    call :DisableFirewall
) else if "%choice%"=="3" (
    :: 退出
    echo 即将退出...
    echo 3
    timeout /t 1 /nobreak >nul
    echo 2
    timeout /t 1 /nobreak >nul
    echo 1
    timeout /t 1 /nobreak >nul
    exit /b 0
) else (
    echo 错误：无效选项，请输入 1、2 或 3。
    pause
    exit /b 1
)

:: 结束脚本
exit /b 0

:EnableFirewall
    :: 用户确认
    set /p confirm=确定要禁止 "%programPath%" 的网络连接吗？(Y/N):
    if /i "%confirm%" neq "Y" (
        echo 操作已取消。
        pause
        exit /b 0
    )

    :: 删除已有的防火墙规则（避免重复）
    echo 正在删除已有的防火墙规则...
    netsh advfirewall firewall delete rule name="Cisco Packet Tracer 出站" >nul 2>&1
    netsh advfirewall firewall delete rule name="Cisco Packet Tracer 入站" >nul 2>&1

    :: 添加新的防火墙规则
    echo 正在添加防火墙规则...
    netsh advfirewall firewall add rule name="Cisco Packet Tracer 出站" dir=out action=block profile=any program="%programPath%" enable=yes
    if %errorlevel% neq 0 (
        echo 错误：创建出站规则失败。
        pause
        exit /b 1
    )

    netsh advfirewall firewall add rule name="Cisco Packet Tracer 入站" dir=in action=block profile=any program="%programPath%" enable=yes
    if %errorlevel% neq 0 (
        echo 错误：创建入站规则失败。
        pause
        exit /b 1
    )

    echo 防火墙规则已成功创建，"%programPath%" 的网络连接已被禁止。
    pause
    exit /b 0

:DisableFirewall
    :: 用户确认
    set /p confirm=确定要恢复 Cisco Packet Tracer 的网络连接吗？(Y/N):
    if /i "%confirm%" neq "Y" (
        echo 操作已取消。
        pause
        exit /b 0
    )

    :: 删除防火墙规则
    echo 正在删除防火墙规则...
    netsh advfirewall firewall delete rule name="Cisco Packet Tracer 出站" >nul 2>&1
    if %errorlevel% neq 0 (
        echo 警告：删除出站规则失败，可能规则不存在。
    )

    netsh advfirewall firewall delete rule name="Cisco Packet Tracer 入站" >nul 2>&1
    if %errorlevel% neq 0 (
        echo 警告：删除入站规则失败，可能规则不存在。
    )

    echo 防火墙规则已成功删除，Cisco Packet Tracer 的网络连接已恢复。
    pause
    exit /b 0

:SearchPath
    echo 正在自动搜索 PacketTracer.exe 的安装路径...
    set "programPath="
    set "defaultPath=C:\Program Files\Cisco Packet Tracer 8.2.2\bin\PacketTracer.exe"

    :: 提取默认路径的相对路径部分
    set "relativePath=%defaultPath:*:=%"

    :: 从 C 盘开始尝试，最多尝试 5 个盘符
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

    :: 如果通过盘符替换未找到路径，则尝试查找快捷方式
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