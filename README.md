# 🚀 CiscoPacketTracerChinese

![Project Logo](https://img.icons8.com/color/96/000000/translation.png)
**高质量的思科模拟器汉化与免登录全套套件**
*让 Cisco Packet Tracer 更贴近中文用户！*

---

[![License](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Version](https://img.shields.io/badge/Supported_Version-9.0.1%20%7C%208.2.2-brightgreen)](https://github.com/Liu8Can/CiscoPacketTracerChinese)
[![Bilibili](https://img.shields.io/badge/Bilibili-%E6%B2%A7%E6%B5%AA%E5%90%8C%E5%AD%A6-fb7299.svg)](https://space.bilibili.com/520050693)
[![GitHub Stars](https://img.shields.io/github/stars/Liu8Can/CiscoPacketTracerChinese?style=social)](https://github.com/Liu8Can/CiscoPacketTracerChinese/stargazers)
[![GitHub Forks](https://img.shields.io/github/forks/Liu8Can/CiscoPacketTracerChinese?style=social)](https://github.com/Liu8Can/CiscoPacketTracerChinese/network/members)

---

## 📺 [视频教程 - 点击前往 B 站观看 ✋](https://www.bilibili.com/video/BV1HocieeE6N)
> 视频内有详细的安装与配置演示，欢迎三连支持！

🔬 **底层原理与逆向解析白皮书**：[TECHNICAL_DOCS.md](TECHNICAL_DOCS.md)（深入揭秘为什么悬停提示是英文、9.0.1 二进制跳转修补原理等技术细节）

---

## 📜 项目简介

**CiscoPacketTracerChinese** 是专为思科网络模拟器（Cisco Packet Tracer）打造的深度中文汉化包与配套工具集。
- 深度兼容 **9.0.1** 及 **8.2.2** 两个主要主流版本。
- 采用先进大语言模型（GLM-4 / Qwen2.5 / Jev）结合网络工程术语词表与人工专业逐条校对，告别劣质机翻与漏翻。
- 提供 9.0.1 专属的**原生离线免登录补丁工具**，彻底解决高版本思科强制网络认证与登录窗口弹出的痛点。

---

## 🌟 主要特点

- **高质量专业翻译**：针对网络工程专业术语（VLAN、ACL、OSPF、Trunk、NAT、CEF 等）做精准语义对应，快捷键（`&File`、`&Edit`）原生适配。
- **全自动化一键安装**：内置 `一键安装汉化包.bat`，全自动扫描多盘符安装路径，无需手动寻找复杂的系统目录。
- **全新 9.0.1 原生免登录机制**：9.x 版本防火墙方案失效后，全新推出二进制精准跳转补丁，1秒即可完成免登录直入工作区，并支持一键无损还原官方原版。
- **纯净安全**：不常驻系统后台，无多余依赖，完全开源透明。

---

## 🛠️ 文件说明与下载

从 [Releases 页面](https://github.com/Liu8Can/CiscoPacketTracerChinese/releases) 下载所需文件：

| 文件名 | 适用版本 | 功能说明 |
| :--- | :--- | :--- |
| `哔哩哔哩 沧浪同学 中文汉化包.ptl` | **9.0.1** | 9.0.1 最终编译二进制汉化语言包 |
| `PacketTracer_通用特征码自寻址补丁工具.bat` | **跨版本通用** | **推荐**：AOB 特征自寻址免登录补丁入口（管理员运行，自动适配各版本） |
| `PacketTracer_Universal_Patcher.ps1` | **跨版本通用** | 核心自寻址修补引擎（动态重算跳转，注册表秒定位，带唯一性安全熔断） |
| `PacketTracer9.0.1_一键补丁工具.bat` | **9.0.1** | 9.0.1 专属一键免登录修补/还原入口（管理员运行） |
| `PacketTracer_Patcher.ps1` | **9.0.1** | 9.0.1 固定偏移修补逻辑（备份还原版） |
| `Chinese-canglang-8.2.2.ptl` | **8.2.2** | 8.2.2 经典稳定版汉化语言包 |
| `BanNetwork.bat` | **8.2.2** | 8.2.2 版本 Windows 防火墙出入站阻止脚本 |
| `一键安装汉化包.bat` | 通用 | 自动检测本机 CPT 安装目录并一键复制 `.ptl` 文件 |

---

## 🚀 使用指南

### 第一步：安装汉化包

#### 方法 A（推荐：一键自动安装）：
1. 将下载的 `哔哩哔哩 沧浪同学 中文汉化包.ptl`（或 8.2.2 版）与 `一键安装汉化包.bat` 放在**同一个文件夹**下。
2. 鼠标双击运行 `一键安装汉化包.bat`，脚本会自动寻找所有磁盘的 Packet Tracer 安装目录并完成复制。

#### 方法 B（手动复制）：
1. 打开你的 Cisco Packet Tracer 安装目录下的 `languages` 文件夹，例如：
   ```text
   C:\Program Files\Cisco Packet Tracer 9.0.1\languages
   或
   D:\Program Files\Cisco Packet Tracer 9.0.1\languages
   ```
2. 将对应版本的 `.ptl` 文件复制到该 `languages` 文件夹中。

---

### 第二步：在软件中切换为中文

1. 打开 Cisco Packet Tracer。
2. 在顶部菜单栏点击：
   ```text
   Options → Preferences → Interface
   ```
3. 在底部的语言列表（Select Language）中选中刚才添加的汉化包（如 `哔哩哔哩 沧浪同学 中文汉化包.ptl`）。
4. 点击右下角 **Change Language** 按钮。
5. **重启软件**，即可看到完整中文界面！

---

### 第三步：跳过思科登录（免登录使用）

#### 🔹 推荐使用：跨版本通用特征码自寻址补丁（支持 9.0.1 及后续版本）
1. 鼠标右键以管理员身份运行 `PacketTracer_通用特征码自寻址补丁工具.bat`。
2. 工具会自动通过注册表秒级探查 Packet Tracer 安装路径，并执行 AOB 毫秒级自寻址：
   - 输入 `1`：**应用免登录补丁**（动态匹配鉴权跳转并重算相对偏移，自动创建 `.bak` 备份并注入无条件跳转，彻底跳过登录窗口）。
   - 输入 `2`：**还原官方原版**（动态自适应恢复原版条件跳转）。

#### 🔹 备用工具（针对 9.0.1 固定偏移版）：
- 也可直接以管理员身份运行 `PacketTracer9.0.1_一键补丁工具.bat`。

#### 🔹 针对 8.2.2 版本：
- 双击运行 `BanNetwork.bat`，利用 Windows 高级防火墙出站+入站规则阻止联网认证。

---

## 🤝 贡献与后续更新

- 如果你在使用过程中发现任何翻译不妥或遗漏之处，欢迎提交 [Issue](https://github.com/Liu8Can/CiscoPacketTracerChinese/issues) 或 Pull Request。
- 后续如 Cisco 发布更高版本（如 9.0.2 / 9.1 等），只需在 Issue 中提供新版 `languages/template.ts` 或 `default.ts` 文件，我将在收到后更新适配。

---

## 📜 许可证与防伪声明

- 本项目采用 [MIT 许可证](LICENSE)。
- 汉化与补丁维护者：**沧浪同学**（哔哩哔哩：[沧浪同学](https://space.bilibili.com/520050693)）
- 官方发布主页：[https://github.com/Liu8Can/CiscoPacketTracerChinese](https://github.com/Liu8Can/CiscoPacketTracerChinese)
- 本汉化包完全**免费开源**，严禁任何倒卖或打包收费行为。如果本套件帮到了你，请点一个免费的 ⭐️ **Star** 支持一下！
