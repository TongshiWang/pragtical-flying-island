# pragtical-flying-island

**English** | [简体中文](README.zh-CN.md)

[![Pragtical mod-version](https://img.shields.io/badge/Pragtical-mod--version%203-3574F0.svg)](https://pragtical.dev/)
[![Release](https://img.shields.io/github/v/release/TongshiWang/pragtical-flying-island?color=549159)](https://github.com/TongshiWang/pragtical-flying-island/releases)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

> **Ported From / Credits**
> - UI design, floating islands palette, and translucency style ported from **[am1dreaming/Flying-Island-dark-for-VS-code](https://github.com/am1dreaming/Flying-Island-dark-for-VS-code)**
> - 120 SVG icons sourced from **[chadalen/vscode-jetbrains-icon-theme](https://github.com/chadalen/vscode-jetbrains-icon-theme)** (JetBrains 2023+ UI Dark icon set)

Bring the **JetBrains New UI Floating Islands**, **JetBrains 2023+ Dark SVG file/folder icons**, **Darcula Contrast color theme**, and **translucent Windows 11 DWM blur** to [Pragtical](https://pragtical.dev/).

<p align="center">
  <img src="docs/preview-translucent.png" alt="Flying Island Dark Translucent Preview" width="95%" />
</p>

<p align="center">
  <img src="docs/preview-main.png" alt="Flying Island Dark Main UI and JetBrains SVG Icons" width="95%" />
</p>

---

## Features & Modular Toggles

Every visual domain in Flying Island can be toggled independently from **Tools > Settings > Plugins > Flying Island** or **View > Flying Island** — mix and match only the parts you want:

- **JetBrains 2023+ Dark SVG Icons** (`show_treeview_icons`, `show_tab_icons`):
  - Bundles 120 high-DPI SVG icons with `theme.json` filename, compound-extension (`*.test.ts`, `CMakeLists.txt`, `Dockerfile`, `package.json`), and folder mappings (`tests`, `.github`, root module).
  - Toggle **File Tree** icons and **Document Tab** icons independently — SVG tab icons even work cleanly with stock tabs when pill tabs are turned off.
- **Floating Rounded Islands UI** (`island_style`, `island_panels`, `pill_tabs`, `rounded_tree_rows`, `styled_toolbar`, `island_radius`, `island_gap`):
  - **Floating Panel Islands** (`island_panels`): Frames TreeView (`#191A1C`) and editor leaf panes (`#1E1F22`) as rounded floating islands (default `10px` radius, `4px` gap).
  - **Pill Tabs** (`pill_tabs`): Pill-shaped active/hovered editor tabs (`#25324D` fill, `#35538F` outline).
  - **Rounded TreeView Rows & Chevrons** (`rounded_tree_rows`): Rounded TreeView selection/hover pills (`#2E436E`) and vector chevrons.
  - **Styled Activity Toolbar** (`styled_toolbar`): `#26282B` activity bar backdrop and rounded icon hover highlights.
- **Window Transparency & Windows 11 Native Blur** (`enable_transparency`, `opacity`, `win_blur`):
  - Toggle window translucency on/off independently (`enable_transparency`), tune window opacity (`0.93` default), and pick Windows 11 native DWM effects (`Acrylic`, `Mica`, `Tabbed`, `Blur Behind`, or `Off`).
- **Flying Island Dark Theme (`colors/flying_island_dark.lua`)** (`apply_theme`):
  - Auto-applied on startup (unless disabled in Settings or overridden by another chosen theme), combining JetBrains New UI surface colors with Darcula Contrast syntax highlighting.

### Popular Combinations

- **Icons-only mode**: Turn off `island_style` and `enable_transparency` (and optionally `apply_theme`) to keep your existing UI & theme while enjoying the 120 JetBrains SVG icons.
- **Opaque Islands UI mode**: Keep `island_style = true` and turn off `enable_transparency` if you want JetBrains floating islands without window transparency.
- **Pill tabs & icons without outer panel frames**: Set `island_panels = false` while keeping `pill_tabs = true` and SVG icons enabled.

---

## Platform Compatibility

Tested on **Pragtical 3.15.0-jit** (`mod-version: 3`).

| Feature | Windows 10 / 11 | Linux | macOS |
| :--- | :---: | :---: | :---: |
| Flying Island Dark color scheme | Yes | Yes | Yes |
| JetBrains 2023+ SVG icons (Tree & Tabs) | Yes | Yes | Yes |
| Floating rounded islands & pill tabs | Yes | Yes | Yes |
| Window opacity (`system.set_window_opacity`) | Yes | Depends on WM/compositor | Yes |
| Native DWM Acrylic / Mica / Tabbed blur | Windows 11 | Skipped cleanly | Skipped cleanly |

---

## Installation

### Method 1: PPM / Plugin Manager (Recommended — Windows / Linux / macOS)

Now included in the official `pragtical/plugins` and `pragtical/colors` repositories! Install with a single command via `ppm`:

```sh
ppm install flying_island
```

- Or search for **`flying_island`** directly inside Pragtical's **Tools > Plugin Manager** and click **Install**.
- To install only the standalone dark color scheme: `ppm install flying_island_dark`.
- *(Optional)* To track bleeding-edge `main` directly: `ppm repo add https://github.com/TongshiWang/pragtical-flying-island.git:main` before running `ppm install flying_island`.

### Method 2: PowerShell Installer (Windows)

```powershell
git clone https://github.com/TongshiWang/pragtical-flying-island.git
cd pragtical-flying-island
.\install.ps1
```

### Method 3: Manual Install

Copy the files into your Pragtical `USERDIR`:
- `plugins/flying_island/` -> `<USERDIR>/plugins/flying_island/`
- `colors/flying_island_dark.lua` -> `<USERDIR>/colors/flying_island_dark.lua`

Common `USERDIR` locations:
- **Windows (Installer / Portable with `user` folder)**: `%LOCALAPPDATA%\Programs\Pragtical\user`
- **Windows (Config dir)**: `%USERPROFILE%\.config\pragtical`
- **Linux / macOS**: `~/.config/pragtical`

Restart Pragtical after installing.

---

## Shortcuts & Settings

Control everything live from **Tools > Settings > Plugins > Flying Island**, **View > Flying Island**, or via hotkeys:

| Shortcut | Action |
| :--- | :--- |
| `Ctrl+Alt+T` | Toggle window transparency on/off |
| `Ctrl+Alt+=` | Increase window opacity (+3%) |
| `Ctrl+Alt+-` | Decrease window opacity (-3%) |

Configurable options include: `enabled`, `apply_theme`, `show_treeview_icons`, `show_tab_icons`, `island_style`, `island_panels`, `island_radius`, `island_gap`, `pill_tabs`, `rounded_tree_rows`, `styled_toolbar`, `enable_transparency`, `opacity`, and `win_blur` (`acrylic` / `mica` / `tabbed` / `blur` / `off`).

---

## Uninstallation

- **If installed via PPM**:
  ```sh
  ppm uninstall flying_island flying_island_dark
  ```
- **If installed via PowerShell on Windows**:
  ```powershell
  .\uninstall.ps1
  ```
- **Manual**: Delete `<USERDIR>/plugins/flying_island` and `<USERDIR>/colors/flying_island_dark.lua`, then restart Pragtical.

---

## License

[MIT License](LICENSE)
