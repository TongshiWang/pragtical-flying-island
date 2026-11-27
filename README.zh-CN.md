# pragtical-flying-island

[English](README.md) | **简体中文**

[![Pragtical mod-version](https://img.shields.io/badge/Pragtical-mod--version%203-3574F0.svg)](https://pragtical.dev/)
[![Release](https://img.shields.io/github/v/release/TongshiWang/pragtical-flying-island?color=549159)](https://github.com/TongshiWang/pragtical-flying-island/releases)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

> **改造来源 / Ported From**
> - 本项目改造移植自 VS Code 主题与界面增强项目：**[am1dreaming/Flying-Island-dark-for-VS-code](https://github.com/am1dreaming/Flying-Island-dark-for-VS-code)**
> - 图标资源来自：**[chadalen/vscode-jetbrains-icon-theme](https://github.com/chadalen/vscode-jetbrains-icon-theme)**（JetBrains 2023+ Dark SVG 图标集）

为 [Pragtical](https://pragtical.dev/) 打造的 **Flying Island Dark** 视觉插件与配色主题（`mod-version: 3`），带来 JetBrains New UI 圆角浮岛布局、120 枚彩色 SVG 图标以及 Windows 11 原生透明模糊质感。

<p align="center">
  <img src="docs/preview-translucent.png" alt="Flying Island Dark 半透明效果预览" width="95%" />
</p>

<p align="center">
  <img src="docs/preview-main.png" alt="Flying Island Dark 主界面与 JetBrains SVG 图标" width="95%" />
</p>

---

## 功能特性

- **JetBrains 2023+ Dark 彩色 SVG 图标**：内置 120 个矢量 SVG 图标与 `theme.json` 映射规则（覆盖常见后缀、`CMakeLists.txt`、`Dockerfile`、`package.json`、`*.test.ts` 与特殊文件夹），同时支持**文件树（TreeView）**和**编辑器标签栏（Tabs）**。
- **Floating Islands 圆角浮岛界面**：
  - 文件树（`#191A1C`）与编辑区窗格（`#1E1F22`）均呈圆角悬浮浮岛（默认 `10px` 圆角、`4px` `#26282B` 外框间距）。
  - 活动标签页采用胶囊式高亮（`#25324D` 填充 + `#35538F` 描边），文件树采用圆角选中行（`#2E436E`）、矢量折叠箭头与工具栏圆角悬停高亮。
- **窗口透明与 Windows 11 原生 DWM 模糊**：
  - 默认 `0.93` 半透明质感，支持 Windows 11 原生 DWM 暗色边框、窗口圆角及 Acrylic / Mica / Tabbed / Blur Behind 合成效果。
  - Linux 与 macOS 自动跳过 Win32 DWM 调用，图标、浮岛 UI、配色与不透明度调节均可正常使用。
- **配套 Flying Island Dark 配色主题（`colors/flying_island_dark.lua`）**：融合 JetBrains New UI 暗色调与 Darcula Contrast 语法高亮。

---

## 兼容性

已在 **Pragtical 3.15.0-jit**（`mod-version: 3`）实测通过：

| 功能项 | Windows 10 / 11 | Linux | macOS |
| :--- | :---: | :---: | :---: |
| Flying Island Dark 配色主题 | 支持 | 支持 | 支持 |
| JetBrains 2023+ SVG 图标（文件树 + 标签页） | 支持 | 支持 | 支持 |
| 圆角浮岛与胶囊标签 UI | 支持 | 支持 | 支持 |
| 窗口不透明度（`system.set_window_opacity`） | 支持 | 视桌面合成器而定 | 支持 |
| Win11 DWM Acrylic / Mica / Tabbed 模糊 | Windows 11 原生支持 | 自动跳过 | 自动跳过 |

---

## 安装方法

### 方式一：通过 PPM / 官方插件管理器安装（推荐，全平台适用）

现已正式收录进 Pragtical 官方插件与配色目录！一行命令即可安装：

```sh
ppm install flying_island
```

- 也可以直接在 Pragtical 中打开 **工具 > 插件管理器 (Plugin Manager)**，搜索 **`flying_island`** 一键安装。
- 若仅需独立配色方案：`ppm install flying_island_dark`。
- *（可选）* 如需抢先体验 `main` 分支最新提交，可先执行 `ppm repo add https://github.com/TongshiWang/pragtical-flying-island.git:main`。

### 方式二：PowerShell 一键安装（Windows）

```powershell
git clone https://github.com/TongshiWang/pragtical-flying-island.git
cd pragtical-flying-island
.\install.ps1
```

### 方式三：手动安装

将文件复制到 Pragtical 的用户配置目录 `<USERDIR>`：
- `plugins/flying_island/` -> `<USERDIR>/plugins/flying_island/`
- `colors/flying_island_dark.lua` -> `<USERDIR>/colors/flying_island_dark.lua`

常见 `<USERDIR>` 路径说明：
- **Windows 默认安装包（含内置 `user` 目录）**：`%LOCALAPPDATA%\Programs\Pragtical\user`
- **Windows 标准配置目录**：`%USERPROFILE%\.config\pragtical`
- **Linux / macOS**：`~/.config/pragtical`

安装完成后重启 Pragtical 即可生效。

---

## 快捷键与设置

可在 **设置 > 插件 > Flying Island** 中实时调整全部参数，或使用顶部菜单 **视图 > Flying Island** 与以下快捷键：

| 快捷键 | 功能 |
| :--- | :--- |
| `Ctrl+Alt+T` | 切换窗口透明效果 |
| `Ctrl+Alt+=` | 提高窗口不透明度（+3%） |
| `Ctrl+Alt+-` | 降低窗口不透明度（-3%） |

---

## 卸载方法

- **PPM 安装**：`ppm uninstall flying_island flying_island_dark`
- **Windows 脚本**：在仓库目录运行 `.\uninstall.ps1`
- **手动卸载**：删除 `<USERDIR>/plugins/flying_island` 与 `<USERDIR>/colors/flying_island_dark.lua` 后重启 Pragtical。

---

## 许可证

[MIT License](LICENSE)
