@echo off
setlocal
cd /d "%~dp0"
title Cisco Packet Tracer Universal Patcher

:: Check Administrator privileges
net session >nul 2>&1
if %errorLevel% neq 0 (
    powershell -NoProfile -Command "Start-Process cmd -ArgumentList '/k \"\"%~f0\"\"' -Verb RunAs"
    exit /b
)

:: Run PowerShell Universal Patcher
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0PacketTracer_Universal_Patcher.ps1"
if %errorLevel% neq 0 (
    echo.
    echo 脚本执行异常，请查看上方输出。按任意键退出...
    pause >nul
)