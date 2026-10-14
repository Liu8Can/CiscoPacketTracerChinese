@echo off
chcp 65001 >nul
title Cisco Packet Tracer 9.0.1 一键补丁工具 - 沧浪同学

:: 如果需要管理员权限自动提权
net session >nul 2>&1
if %errorLevel% neq 0 (
    powershell -NoProfile -Command "Start-Process cmd -ArgumentList '/c \"\"%~f0\"\"' -Verb RunAs"
    exit /b
)

:: 运行 PowerShell 补丁脚本
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0PacketTracer_Patcher.ps1"
