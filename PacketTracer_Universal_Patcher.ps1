<#
.SYNOPSIS
    Cisco Packet Tracer 通用特征码自寻址免登录补丁与还原工具
    (跨版本通用 / AOB 特征扫描 / 零外部智能体依赖 / 原生正则纯净版)
#>

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

function Show-Header {
    Clear-Host
    Write-Host "======================================================================" -ForegroundColor Cyan
    Write-Host "   Cisco Packet Tracer 通用特征码自寻址补丁工具 (跨版本通用版)       " -ForegroundColor Yellow
    Write-Host "======================================================================" -ForegroundColor Cyan
    Write-Host " 原理: 基于 AOB 特征码流式匹配，毫秒级自寻址离线分支，动态重算相对跳转" -ForegroundColor Gray
    Write-Host " 优势: 纯原生 .NET 正则流解析，彻底脱离硬编码偏移与编译器依赖" -ForegroundColor Gray
    Write-Host " 特点: 纯原生运行，零常驻后台，不伤其他功能，具备唯一性安全熔断防御" -ForegroundColor Gray
    Write-Host "======================================================================" -ForegroundColor Cyan
    Write-Host ""
}

function Get-PTPath {
    # 策略 1: Windows 注册表官方安装记录探查 (无视盘符与版本号，最精准)
    $regPaths = @(
        'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*',
        'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*',
        'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*'
    )
    $regItems = Get-ItemProperty $regPaths -ErrorAction SilentlyContinue | Where-Object { $_.DisplayName -like '*Packet Tracer*' }
    foreach ($item in $regItems) {
        if ($item.InstallLocation) {
            $candidate = Join-Path $item.InstallLocation "bin\PacketTracer.exe"
            if (Test-Path $candidate) { return $candidate }
        }
        if ($item.UninstallString) {
            $uninst = $item.UninstallString.Trim('"', ' ')
            $dir = Split-Path $uninst -Parent
            $candidate = Join-Path $dir "bin\PacketTracer.exe"
            if (Test-Path $candidate) { return $candidate }
        }
    }

    # 策略 2: 当前正在运行的进程路径
    $proc = Get-Process -Name "PacketTracer" -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($proc -and $proc.Path -and (Test-Path $proc.Path)) {
        return $proc.Path
    }

    # 策略 3: 全盘 Program Files 通配符目录扫描 (兼容解压版/绿色版)
    $drives = Get-PSDrive -PSProvider FileSystem | Select-Object -ExpandProperty Root
    foreach ($d in $drives) {
        $pfPaths = @(
            (Join-Path $d "Program Files"),
            (Join-Path $d "Program Files (x86)")
        )
        foreach ($pf in $pfPaths) {
            if (Test-Path $pf) {
                $ptDirs = Get-ChildItem -Path $pf -Filter "Cisco Packet Tracer*" -Directory -ErrorAction SilentlyContinue
                foreach ($dir in $ptDirs) {
                    $candidate = Join-Path $dir.FullName "bin\PacketTracer.exe"
                    if (Test-Path $candidate) { return $candidate }
                }
            }
        }
    }

    # 策略 4: 兜底手动输入
    Write-Host "未能自动探查到 Packet Tracer，请输入 PacketTracer.exe 完整路径 (或直接把文件拖拽到此处):" -ForegroundColor Yellow
    $custom = (Read-Host).Trim('"', ' ')
    if (Test-Path $custom) { return $custom }
    return $null
}

function Check-Running {
    $procs = Get-Process -Name "PacketTracer" -ErrorAction SilentlyContinue
    if ($procs) {
        Write-Host "检测到 PacketTracer 正在运行，正在为您安全关闭..." -ForegroundColor Yellow
        $procs | Stop-Process -Force
        Start-Sleep -Seconds 1
    }
}

function Scan-File($filePath) {
    if (-not (Test-Path $filePath)) { return @() }
    
    $bytes = [System.IO.File]::ReadAllBytes($filePath)
    $enc = [System.Text.Encoding]::GetEncoding(28591)
    $str = $enc.GetString($bytes)

    # 特征指令序列:
    # 80 bc 24 ?? ?? 00 00 00 (cmp byte ptr [rsp+offset], 0)
    # ( 0f 85 [4 bytes] | e9 [4 bytes] 90 )
    # .. 80 3d [4 bytes] 00 0f 85
    $pattern = "\x80\xbc\x24..\x00\x00\x00(?:\x0f\x85.{4}|\xe9.{4}\x90).{0,2}\x80\x3d.{4}\x00\x0f\x85"
    $regexMatches = [System.Text.RegularExpressions.Regex]::Matches($str, $pattern, [System.Text.RegularExpressions.RegexOptions]::Singleline)

    $results = @()
    foreach ($m in $regexMatches) {
        $patchOffset = $m.Index + 8
        $opcode = $bytes[$patchOffset]
        $isPatched = ($opcode -eq 0xE9)

        $oldRel = 0
        $newRel = 0
        if ($isPatched) {
            $newRel = [System.BitConverter]::ToInt32($bytes, $patchOffset + 1)
            $oldRel = $newRel - 1
        } else {
            $oldRel = [System.BitConverter]::ToInt32($bytes, $patchOffset + 2)
            $newRel = $oldRel + 1
        }

        $results += [PSCustomObject]@{
            Offset = $patchOffset
            IsPatched = $isPatched
            OldRelOffset = $oldRel
            NewRelOffset = $newRel
        }
    }
    return ,$results
}

try {
    $ptPath = Get-PTPath
    if (-not $ptPath) {
        Write-Host "错误: 找不到 PacketTracer.exe，请确认安装路径。" -ForegroundColor Red
        Write-Host "按任意键退出..."
        [Console]::ReadKey($true) | Out-Null
        exit
    }

    while ($true) {
        Show-Header
        Write-Host "当前目标文件: $ptPath" -ForegroundColor White
        $bakPath = "$ptPath.bak"

        Write-Host "正在进行全文件 AOB 特征码自寻址扫描..." -ForegroundColor Gray
        $sw = [System.Diagnostics.Stopwatch]::StartNew()
        $matches = Scan-File $ptPath
        $sw.Stop()

        $matchCount = $matches.Count
        Write-Host ("扫描完成 (耗时: " + $sw.ElapsedMilliseconds + " ms)") -ForegroundColor DarkGray
        Write-Host ""

        $currentResult = $null

        if ($matchCount -eq 0) {
            Write-Host "[状态检测] 未能匹配到特征码！" -ForegroundColor Red
            Write-Host "说明: 该版本代码结构可能发生重大重构，为保护文件完整性，已触发安全熔断机制。" -ForegroundColor Gray
        } elseif ($matchCount -gt 1) {
            Write-Host "[安全告警] 扫描到多处匹配点 ($matchCount 处)！" -ForegroundColor Red
            Write-Host "说明: 特征码不够唯一，为防止误改其他代码分支，已触发安全防御拒绝修补。" -ForegroundColor Gray
        } else {
            $currentResult = $matches[0]
            $hexOffset = "0x" + $currentResult.Offset.ToString("X")
            if ($currentResult.IsPatched) {
                Write-Host "[当前状态] 已打免登录补丁 (免密离线模式生效中)" -ForegroundColor Green
                Write-Host "  * 动态命中偏移: $hexOffset" -ForegroundColor Gray
                Write-Host "  * 当前指令: jmp rel32 + nop (无条件跳转直达拓扑工作区)" -ForegroundColor Gray
                Write-Host ("  * 跳转相对偏移: 0x" + $currentResult.NewRelOffset.ToString("X")) -ForegroundColor Gray
            } else {
                Write-Host "[当前状态] 官方原版 (强制登录模式)" -ForegroundColor Yellow
                Write-Host "  * 动态命中偏移: $hexOffset" -ForegroundColor Gray
                Write-Host "  * 当前指令: jnz rel32 (条件跳转，未登录时阻断并弹窗)" -ForegroundColor Gray
                Write-Host ("  * 跳转相对偏移: 0x" + $currentResult.OldRelOffset.ToString("X")) -ForegroundColor Gray
            }
        }

        Write-Host ""
        Write-Host "请选择操作:" -ForegroundColor White
        Write-Host "  [1] 应用免登录补丁 (基于特征自寻址，自动重算跳转并修补)" -ForegroundColor Cyan
        Write-Host "  [2] 还原为官方原版 (自适应恢复原始跳转指令)" -ForegroundColor Yellow
        Write-Host "  [3] 重新扫描状态" -ForegroundColor Gray
        Write-Host "  [0] 退出" -ForegroundColor White
        Write-Host ""

        $choice = Read-Host "请输入数字并回车"

        if ($choice -eq "1") {
            if (-not $currentResult) {
                Write-Host "无法打补丁: 未定位到唯一定位点。" -ForegroundColor Red
                Write-Host "按任意键继续..."
                [Console]::ReadKey($true) | Out-Null
                continue
            }
            if ($currentResult.IsPatched) {
                Write-Host "当前文件已经处于免登录补丁状态，无需重复修补！" -ForegroundColor Yellow
                Write-Host "按任意键继续..."
                [Console]::ReadKey($true) | Out-Null
                continue
            }

            Check-Running

            # 1. 自动备份
            if (-not (Test-Path $bakPath)) {
                Write-Host "正在创建官方原版备份 -> $bakPath..." -ForegroundColor Gray
                Copy-Item -Path $ptPath -Destination $bakPath -Force
            }

            # 2. 动态构造补丁机器码
            # jmp: E9 [newRel 4 bytes] 90
            $newRelBytes = [System.BitConverter]::GetBytes([int]$currentResult.NewRelOffset)
            $patchBytes = [byte[]]@(0xE9, $newRelBytes[0], $newRelBytes[1], $newRelBytes[2], $newRelBytes[3], 0x90)

            Write-Host "正在写入自适应跳转补丁 (偏移: 0x$($currentResult.Offset.ToString('X')))..." -ForegroundColor Cyan
            try {
                $fs = [System.IO.File]::Open($ptPath, [System.IO.FileMode]::Open, [System.IO.FileAccess]::ReadWrite, [System.IO.FileShare]::None)
                $fs.Seek($currentResult.Offset, [System.IO.SeekOrigin]::Begin) | Out-Null
                $fs.Write($patchBytes, 0, 6)
                $fs.Close()
                Write-Host "补丁修补成功！已成功切换为免登录离线模式！" -ForegroundColor Green
            } catch {
                Write-Host "写入失败: $($_.Exception.Message)" -ForegroundColor Red
                Write-Host "请确认已以管理员权限运行此工具。" -ForegroundColor Yellow
            }
            Write-Host "按任意键继续..."
            [Console]::ReadKey($true) | Out-Null
        } elseif ($choice -eq "2") {
            if (-not $currentResult) {
                Write-Host "无法还原: 未定位到特征位置。" -ForegroundColor Red
                Write-Host "按任意键继续..."
                [Console]::ReadKey($true) | Out-Null
                continue
            }
            if (-not $currentResult.IsPatched) {
                Write-Host "当前文件已经是官方原版，无需还原！" -ForegroundColor Yellow
                Write-Host "按任意键继续..."
                [Console]::ReadKey($true) | Out-Null
                continue
            }

            Check-Running

            # 动态构造还原机器码
            # jnz: 0F 85 [oldRel 4 bytes]
            $oldRelBytes = [System.BitConverter]::GetBytes([int]$currentResult.OldRelOffset)
            $restoreBytes = [byte[]]@(0x0F, 0x85, $oldRelBytes[0], $oldRelBytes[1], $oldRelBytes[2], $oldRelBytes[3])

            Write-Host "正在恢复官方原始跳转指令 (偏移: 0x$($currentResult.Offset.ToString('X')))..." -ForegroundColor Cyan
            try {
                $fs = [System.IO.File]::Open($ptPath, [System.IO.FileMode]::Open, [System.IO.FileAccess]::ReadWrite, [System.IO.FileShare]::None)
                $fs.Seek($currentResult.Offset, [System.IO.SeekOrigin]::Begin) | Out-Null
                $fs.Write($restoreBytes, 0, 6)
                $fs.Close()
                Write-Host "还原成功！已恢复官方原版登录逻辑。" -ForegroundColor Green
            } catch {
                Write-Host "还原写入失败: $($_.Exception.Message)" -ForegroundColor Red
                Write-Host "请确认已以管理员权限运行此工具。" -ForegroundColor Yellow
            }
            Write-Host "按任意键继续..."
            [Console]::ReadKey($true) | Out-Null
        } elseif ($choice -eq "3") {
            continue
        } elseif ($choice -eq "0") {
            break
        }
    }
} catch {
    Write-Host ""
    Write-Host "脚本运行遇到未捕获异常: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "$($_.ScriptStackTrace)" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "按任意键退出..."
    [Console]::ReadKey($true) | Out-Null
}
