<#
.SYNOPSIS
    Cisco Packet Tracer 9.0.1 一键免登录补丁与还原工具
    汉化维护: 沧浪同学 (哔哩哔哩: 沧浪同学)
    视频教程: https://www.bilibili.com/video/BV1HocieeE6N
    开源主页: https://github.com/Liu8Can/CiscoPacketTracerChinese
#>

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

function Show-Header {
    Clear-Host
    Write-Host "======================================================================" -ForegroundColor Cyan
    Write-Host "          Cisco Packet Tracer 9.0.1 一键免登录补丁与还原工具          " -ForegroundColor Yellow
    Write-Host "======================================================================" -ForegroundColor Cyan
    Write-Host " 汉化维护: 沧浪同学 (B站: 沧浪同学)" -ForegroundColor Cyan
    Write-Host " 视频教程: https://www.bilibili.com/video/BV1HocieeE6N" -ForegroundColor Green
    Write-Host " 开源发布: https://github.com/Liu8Can/CiscoPacketTracerChinese" -ForegroundColor Cyan
    Write-Host "----------------------------------------------------------------------" -ForegroundColor DarkGray
    Write-Host " 原理: 利用官方内置离线免密通道 (修补 2 字节跳转)，彻底跳过登录模态窗" -ForegroundColor Gray
    Write-Host " 特点: 纯原生运行，无需常驻后台，不伤其他功能，随时一秒无损还原" -ForegroundColor Gray
    Write-Host "======================================================================" -ForegroundColor Cyan
    Write-Host ""
}

function Get-PTPath {
    $candidates = @()
    # 动态扫描所有固定磁盘分区
    $drives = [System.IO.DriveInfo]::GetDrives() | Where-Object { $_.DriveType -eq "Fixed" } | ForEach-Object { $_.RootDirectory.FullName.TrimEnd("\") }
    foreach ($d in $drives) {
        $candidates += "$d\Program Files\Cisco Packet Tracer 9.0.1\bin\PacketTracer.exe"
        $candidates += "$d\Program Files (x86)\Cisco Packet Tracer 9.0.1\bin\PacketTracer.exe"
        $candidates += "$d\Cisco Packet Tracer 9.0.1\bin\PacketTracer.exe"
    }

    # 检查当前脚本所在目录及相关相对路径
    if ($PSScriptRoot) {
        $candidates += Join-Path $PSScriptRoot "PacketTracer.exe"
        $candidates += Join-Path $PSScriptRoot "bin\PacketTracer.exe"
        $candidates += Join-Path (Split-Path $PSScriptRoot -Parent) "bin\PacketTracer.exe"
    }

    $found = $candidates | Where-Object { Test-Path $_ } | Select-Object -First 1
    if (-not $found) {
        Write-Host "未在默认路径检测到 Packet Tracer 9.0.1，请输入 PacketTracer.exe 的完整路径:" -ForegroundColor Yellow
        $custom = Read-Host
        if ($custom) {
            $custom = $custom.Trim('"', "'")
            if ((Test-Path $custom) -and ((Get-Item $custom) -is [System.IO.DirectoryInfo])) {
                $subExe = Join-Path $custom "bin\PacketTracer.exe"
                if (Test-Path $subExe) { $custom = $subExe }
            }
            if (Test-Path $custom) { $found = $custom }
        }
    }
    return $found
}

function Get-PatchStatus($exePath) {
    if (-not (Test-Path $exePath)) { return "NOT_FOUND" }
    $offset = 0x24a1068
    $fs = [System.IO.File]::Open($exePath, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::ReadWrite)
    $buf = New-Object byte[] 6
    $fs.Seek($offset, [System.IO.SeekOrigin]::Begin) | Out-Null
    $fs.Read($buf, 0, 6) | Out-Null
    $fs.Close()
    $hex = ($buf | ForEach-Object { "{0:X2}" -f $_ }) -join " "

    if ($hex -eq "0F 85 B0 0C 00 00") {
        return @{ Status = "ORIGINAL"; Hex = $hex }
    } elseif ($hex -eq "E9 B1 0C 00 00 90") {
        return @{ Status = "PATCHED"; Hex = $hex }
    } else {
        return @{ Status = "UNKNOWN"; Hex = $hex }
    }
}

$ptPath = Get-PTPath

if (-not $ptPath) {
    Write-Host "错误: 找不到 PacketTracer.exe，请确认软件已安装。" -ForegroundColor Red
    pause
    exit
}

while ($true) {
    Show-Header
    Write-Host "当前目标文件: $ptPath" -ForegroundColor DarkGray
    $current = Get-PatchStatus $ptPath

    Write-Host -NoNewline "当前版本状态: "
    if ($current.Status -eq "ORIGINAL") {
        Write-Host "[官方原版] (启动会弹出登录窗口)" -ForegroundColor Yellow
    } elseif ($current.Status -eq "PATCHED") {
        Write-Host "[已打免登录补丁] (秒进拓扑工作区)" -ForegroundColor Green
    } else {
        Write-Host "[未知版本或已被修改] ($($current.Hex))" -ForegroundColor Magenta
    }
    Write-Host ""

    Write-Host " [1] 应用免登录补丁 (自动备份原版并修补)" -ForegroundColor White
    Write-Host " [2] 还原官方原版 (从 PacketTracer.exe.bak 恢复)" -ForegroundColor White
    Write-Host " [3] 刷新检测当前状态" -ForegroundColor White
    Write-Host " [4] 退出工具" -ForegroundColor White
    Write-Host ""
    $choice = Read-Host "请输入选项 [1-4]"

    switch ($choice) {
        "1" {
            Write-Host "`n[1/3] 正在检查后台进程..." -ForegroundColor Cyan
            Get-Process -Name "*PacketTracer*" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
            Start-Sleep -Milliseconds 400

            $bakPath = $ptPath + ".bak"
            if (-not (Test-Path $bakPath)) {
                Write-Host "[2/3] 正在创建官方原版备份: PacketTracer.exe.bak ..." -ForegroundColor Yellow
                Copy-Item -Path $ptPath -Destination $bakPath -Force
            } else {
                Write-Host "[2/3] 原版备份已存在，保留最原始版本。" -ForegroundColor Gray
            }

            Write-Host "[3/3] 正在写入免登录跳转补丁..." -ForegroundColor Cyan
            $offset = 0x24a1068
            $fs = [System.IO.File]::Open($ptPath, [System.IO.FileMode]::Open, [System.IO.FileAccess]::ReadWrite)
            $patch = [byte[]]@(0xE9, 0xB1, 0x0C, 0x00, 0x00, 0x90)
            $fs.Seek($offset, [System.IO.SeekOrigin]::Begin) | Out-Null
            $fs.Write($patch, 0, 6)
            $fs.Flush()
            $fs.Close()

            Write-Host "🎉 补丁修补成功！现在直接双击软件或任意 .pkt 文件，均可免登录直入工作区！" -ForegroundColor Green
            Write-Host "按回车键继续..." -ForegroundColor Gray
            Read-Host | Out-Null
        }
        "2" {
            $bakPath = $ptPath + ".bak"
            if (-not (Test-Path $bakPath)) {
                Write-Host "`n错误: 找不到备份文件: $bakPath，无法还原！" -ForegroundColor Red
            } else {
                Write-Host "`n正在从备份还原官方原版..." -ForegroundColor Cyan
                Get-Process -Name "*PacketTracer*" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
                Start-Sleep -Milliseconds 400
                Copy-Item -Path $bakPath -Destination $ptPath -Force
                Write-Host "✅ 已成功还原为 100% 官方原始未修改版本！" -ForegroundColor Green
            }
            Write-Host "按回车键继续..." -ForegroundColor Gray
            Read-Host | Out-Null
        }
        "3" {
            # 刷新循环
        }
        "4" {
            exit
        }
        default {
            Write-Host "无效输入，请重新输入 1-4" -ForegroundColor Red
            Start-Sleep -Seconds 1
        }
    }
}
