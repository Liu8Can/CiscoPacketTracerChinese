@echo off
title Cisco Packet Tracer 一键安装汉化包 - 沧浪同学

:: 检查并自动获取管理员权限
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' NEQ '0' (
    echo [提示] 正在请求管理员权限以部署汉化包到系统目录...
    goto UACPrompt
) else (
    goto gotAdmin
)

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"
    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    pushd "%CD%"
    cd /d "%~dp0"

color 0A
echo =====================================================================
echo         Cisco Packet Tracer 一键汉化安装工具
echo         汉化维护：沧浪同学 (哔哩哔哩：沧浪同学)
echo         开源项目：https://github.com/Liu8Can/CiscoPacketTracerChinese
echo =====================================================================
echo.

:: 查找当前脚本同目录下的 ptl 文件
set "ptlFile="
for %%f in ("%~dp0*.ptl") do (
    set "ptlFile=%%~f"
    set "ptlName=%%~nxf"
)

if not "%ptlFile%"=="" goto FoundPTL

echo [X] 错误：在当前脚本目录下未找到任何 .ptl 汉化包文件！
echo 请确保本脚本与 Chinese-canglang-9.0.1.ptl 放在同一个文件夹下。
echo.
pause
exit /b 1

:FoundPTL
echo [OK] 准备安装的汉化包: %ptlName%
echo.
echo 正在全自动扫描 Cisco Packet Tracer 安装目录...

set "installedCount=0"
set "lastExePath="

for %%d in (C D E F G) do (
    if exist "%%d:\" (
        for /d %%p in ("%%d:\Program Files\Cisco Packet Tracer*") do (
            if exist "%%~fp\languages" (
                echo.
                echo   [发现目录] %%~fp\languages
                copy /y "%ptlFile%" "%%~fp\languages\" >nul
                if %errorlevel% equ 0 (
                    set /a installedCount+=1
                    echo   [+] 成功将 %ptlName% 部署到该版本！
                    if exist "%%~fp\bin\PacketTracer.exe" set "lastExePath=%%~fp\bin\PacketTracer.exe"
                )
            )
        )
        for /d %%p in ("%%d:\Program Files (x86)\Cisco Packet Tracer*") do (
            if exist "%%~fp\languages" (
                echo.
                echo   [发现目录] %%~fp\languages
                copy /y "%ptlFile%" "%%~fp\languages\" >nul
                if %errorlevel% equ 0 (
                    set /a installedCount+=1
                    echo   [+] 成功将 %ptlName% 部署到该版本！
                    if exist "%%~fp\bin\PacketTracer.exe" set "lastExePath=%%~fp\bin\PacketTracer.exe"
                )
            )
        )
    )
)

if not %installedCount% equ 0 goto FinishInstall

echo.
echo [!] 未能自动找到 Cisco Packet Tracer 的 languages 文件夹。
echo 请手动输入思科模拟器的安装路径 (例如 D:\Program Files\Cisco Packet Tracer 9.0.1):
set /p customPath=路径: 
if defined customPath set customPath=%customPath:"=%
if exist "%customPath%\languages" (
    copy /y "%ptlFile%" "%customPath%\languages\" >nul
    echo   [+] 手动安装成功！
    if exist "%customPath%\bin\PacketTracer.exe" set "lastExePath=%customPath%\bin\PacketTracer.exe"
    goto FinishInstall
)

echo [X] 指定目录下未找到 languages 文件夹，安装未完成。
pause
exit /b 1

:FinishInstall
echo.
echo =====================================================================
echo   恭喜！汉化包已成功安装完成！
echo =====================================================================
echo.
echo 【汉化生效步骤】：
echo   1. 打开 Cisco Packet Tracer 软件；
echo   2. 点击顶部菜单栏: Options -^> Preferences（首选项）；
echo   3. 在弹出窗口右下角语言列表中选中刚安装的语言包；
echo   4. 点击右下角 "Change Language" 按钮；
echo   5. 关闭并重新启动软件，界面即变为全新中文！
echo.
echo ---------------------------------------------------------------------

if not defined lastExePath goto EndScript

set /p launchNow=是否现在立即启动 Cisco Packet Tracer 验证汉化？(Y/N): 
if /i "%launchNow%"=="Y" (
    start "" "%lastExePath%"
)

:EndScript
pause
exit /b 0
