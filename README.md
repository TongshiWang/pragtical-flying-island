# pragtical-flying-island

> **改造来源 / Ported From**
> - 本项目改造移植自 VS Code 主题与界面增强项目：**[am1dreaming/Flying-Island-dark-for-VS-code](https://github.com/am1dreaming/Flying-Island-dark-for-VS-code)**
> - 图标资源来自：**[chadalen/vscode-jetbrains-icon-theme](https://github.com/chadalen/vscode-jetbrains-icon-theme)**（JetBrains 2023+ Dark SVG 图标集）

为 [Pragtical](https://pragtical.dev/) 打造的 **Flying Island Dark** 视觉插件与配色主题（`mod-version: 3`）。

## 功能特性

- **JetBrains 2023+ Dark 彩色 SVG 图标**：
  - 内置 120 个 SVG 图标与 `theme.json` 文件/目录名映射规则。
  - 通过 Pragtical 原生 `canvas.load_svg_image` 光栅化并缓存，在**文件树（TreeView）**与**文档标签页（Tabs）**中显示高清文件与文件夹图标。
- **Floating Islands 圆角浮岛 UI**：
  - 文件树与编辑器窗格采用圆角悬浮浮岛（默认圆角 `10px`、间距 `4px`，外框 `#26282B`）。
  - 活动标签页采用胶囊式高亮（`#25324D` 填充 + `#35538F` 描边）。
  - 文件树采用圆角选中行（`#2E436E`）、矢量折叠箭头与工具栏圆角悬停高亮。
- **窗口透明与 Windows 11 原生 DWM 模糊**：
  - 支持可调窗口不透明度（默认 `0.93`）。
  - 在 Windows 11 下通过 LuaJIT FFI 调用原生 DWM 属性（暗色窗口、圆角窗口、Acrylic / Mica / Tabbed / Blur Behind 背景合成效果）。
- **Flying Island Dark 暗色配色主题**：
  - 配套 `colors/flying_island_dark.lua`，融合 JetBrains New UI 暗色调（`#191A1C` / `#1E1F22` / `#26282B`）与 Darcula Contrast 语法着色。

## 快捷键与菜单

可在顶部菜单 **View > Flying Island** 或使用以下快捷键控制：

| 快捷键 | 功能 |
| :--- | :--- |
| `Ctrl+Alt+T` | 切换窗口透明效果 |
| `Ctrl+Alt+=` | 提高窗口不透明度 |
| `Ctrl+Alt+-` | 降低窗口不透明度 |

所有参数均可直接在 **Settings > Plugins > Flying Island** 中实时可视化调整。

## 安装方法

### 方式一：PowerShell 一键安装（Windows）

```powershell
git clone https://github.com/TongshiWang/pragtical-flying-island.git
cd pragtical-flying-island
.\install.ps1
```

### 方式二：手动安装

将本仓库中的文件复制到 Pragtical 用户配置目录：
- `plugins/flying_island/` -> `<USERDIR>/plugins/flying_island/`
- `colors/flying_island_dark.lua` -> `<USERDIR>/colors/flying_island_dark.lua`

> Windows 默认 `<USERDIR>` 为 `%LOCALAPPDATA%\Programs\Pragtical\user`；Linux / macOS 为 `~/.config/pragtical`。

重启 Pragtical 即可生效。

## 致谢 (Credits)

- 视觉设计、配色与透明风格灵感来源：[am1dreaming/Flying-Island-dark-for-VS-code](https://github.com/am1dreaming/Flying-Island-dark-for-VS-code)
- JetBrains 2023+ Dark SVG 图标集来源：[chadalen/vscode-jetbrains-icon-theme](https://github.com/chadalen/vscode-jetbrains-icon-theme)

## 许可证

[MIT License](LICENSE)
