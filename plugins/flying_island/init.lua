-- mod-version:3 -- priority:105
-- Ported and adapted for Pragtical from:
--   - Flying Island Dark for VS Code: https://github.com/am1dreaming/Flying-Island-dark-for-VS-code
--   - JetBrains Icon Theme (2023+ Dark): https://github.com/chadalen/vscode-jetbrains-icon-theme
local core = require "core"
local common = require "core.common"
local command = require "core.command"
local config = require "core.config"
local keymap = require "core.keymap"
local style = require "core.style"
local json = require "core.json"
local Node = require "core.node"
local View = require "core.view"
local DocView = require "core.docview"
local EmptyView = require "core.emptyview"
local CommandView = require "core.commandview"
local StatusView = require "core.statusview"
local TitleView = require "core.titleview"
local MenuView = require "core.menuview"
local NagView = require "core.nagview"

local TreeView = require "plugins.treeview"

local PLUGIN_DIR = USERDIR .. "/plugins/flying_island"
local THEME_JSON_PATH = PLUGIN_DIR .. "/theme.json"

config.plugins.flying_island = common.merge({
  enabled = true,
  apply_theme = true,
  show_treeview_icons = true,
  show_tab_icons = true,
  island_style = true,
  island_panels = true,
  pill_tabs = true,
  rounded_tree_rows = true,
  styled_toolbar = true,
  island_radius = 10,
  island_gap = 4,
  enable_transparency = true,
  opacity = 0.93,
  win_blur = "acrylic"
}, config.plugins.flying_island)

local cfg = config.plugins.flying_island

local svg_cache = {}
local last_icon_scale = SCALE

--------------------------------------------------------------------------------
-- Icon theme loading & resolution (JetBrains 2023+ UI Dark SVG set)
--------------------------------------------------------------------------------
local icon_defs = {}
local folder_names = {}
local file_names = {}
local file_exts = {}
local default_file_id = "file_text"
local default_folder_id = "folder"
local default_root_id = "folder_root"

local EXTRA_FILE_NAMES = {
  ["cmakelists.txt"] = "file_cmake",
  ["dockerfile"] = "file_docker",
  ["makefile"] = "file_makefile",
  ["gnumakefile"] = "file_makefile",
  ["package.json"] = "file_npm",
  ["package-lock.json"] = "file_npm",
  [".gitignore"] = "file_gitignore",
  [".gitattributes"] = "file_gitignore",
  [".gitmodules"] = "file_gitignore",
  ["cargo.toml"] = "file_cargo",
  ["cargo.lock"] = "file_cargolock",
}

local EXTRA_FILE_EXTS = {
  ["bat"] = "file_shell",
  ["cmd"] = "file_shell",
  ["ps1"] = "file_shell",
  ["psm1"] = "file_shell",
  ["psd1"] = "file_shell",
  ["zsh"] = "file_shell",
  ["fish"] = "file_shell",
  ["sh"] = "file_shell",
  ["hpp"] = "file_h",
  ["hxx"] = "file_h",
  ["hh"] = "file_h",
  ["cxx"] = "file_cpp",
  ["cc"] = "file_cpp",
  ["mjs"] = "file_javascript",
  ["cjs"] = "file_javascript",
  ["mts"] = "file_typescript",
  ["cts"] = "file_typescript",
  ["yml"] = "file_yaml",
  ["yaml"] = "file_yaml",
  ["toml"] = "file_toml",
  ["ini"] = "file_config",
  ["cfg"] = "file_config",
  ["conf"] = "file_config",
  ["md"] = "file_markdown",
  ["markdown"] = "file_markdown",
  ["jsonc"] = "file_json",
  ["svg"] = "file_image",
  ["png"] = "file_image",
  ["jpg"] = "file_image",
  ["jpeg"] = "file_image",
  ["webp"] = "file_image",
  ["gif"] = "file_image",
  ["ico"] = "file_image",
}

local EXTRA_FOLDER_NAMES = {
  [".github"] = "folder_github",
  ["test"] = "folder_test",
  ["tests"] = "folder_test",
  ["spec"] = "folder_test",
  ["specs"] = "folder_test",
  ["vendor"] = "folder_vendor",
  ["controllers"] = "folder_controller",
  ["helpers"] = "folder_helper",
  ["mailers"] = "folder_mailers",
  ["migrate"] = "folder_migrate",
  ["migrations"] = "folder_migrate",
}

local function load_icon_theme()
  local f = io.open(THEME_JSON_PATH, "r")
  if not f then
    core.warn("[flying_island] theme.json not found: %s", THEME_JSON_PATH)
    return
  end
  local raw = f:read("*a")
  f:close()
  local ok, data = pcall(json.decode, raw)
  if not ok or type(data) ~= "table" then
    core.warn("[flying_island] Failed to parse theme.json: %s", tostring(data))
    return
  end

  icon_defs = {}
  folder_names = {}
  file_names = {}
  file_exts = {}

  if type(data.iconDefinitions) == "table" then
    for id, entry in pairs(data.iconDefinitions) do
      if type(entry) == "table" and type(entry.iconPath) == "string" then
        local rel = entry.iconPath:gsub("^%./", "")
        local full = PLUGIN_DIR .. "/" .. rel
        icon_defs[id] = full
      end
    end
  end

  if type(data.file) == "string" then default_file_id = data.file end
  if type(data.folder) == "string" then default_folder_id = data.folder end
  if type(data.rootFolder) == "string" then default_root_id = data.rootFolder end

  if type(data.folderNames) == "table" then
    for k, v in pairs(data.folderNames) do
      folder_names[k:lower()] = v
    end
  end
  for k, v in pairs(EXTRA_FOLDER_NAMES) do
    if not folder_names[k] and icon_defs[v] then folder_names[k] = v end
  end

  if type(data.fileNames) == "table" then
    for k, v in pairs(data.fileNames) do
      file_names[k:lower()] = v
    end
  end
  for k, v in pairs(EXTRA_FILE_NAMES) do
    if not file_names[k] and icon_defs[v] then file_names[k] = v end
  end

  if type(data.fileExtensions) == "table" then
    for k, v in pairs(data.fileExtensions) do
      file_exts[k:lower()] = v
    end
  end
  for k, v in pairs(EXTRA_FILE_EXTS) do
    if not file_exts[k] and icon_defs[v] then file_exts[k] = v end
  end
end

load_icon_theme()

local function resolve_icon_def(filename, is_dir, is_root)
  local base = (filename or ""):match("[^/\\]+$") or (filename or "")
  local lower = base:lower()

  if is_dir then
    if is_root then return default_root_id end
    return folder_names[lower] or default_folder_id
  end

  if file_names[lower] then
    return file_names[lower]
  end

  local ext2 = lower:match("%.([^.]+%.[^.]+)$")
  if ext2 and file_exts[ext2] then
    return file_exts[ext2]
  end

  local ext1 = lower:match("%.([^.]+)$")
  if ext1 and file_exts[ext1] then
    return file_exts[ext1]
  end

  return default_file_id
end

local function get_icon_canvas(def_id, px_size)
  if SCALE ~= last_icon_scale then
    svg_cache = {}
    last_icon_scale = SCALE
  end

  local key = tostring(def_id) .. "@" .. tostring(px_size)
  local cached = svg_cache[key]
  if cached ~= nil then
    return cached or nil
  end

  local svg_path = icon_defs[def_id] or icon_defs[default_file_id]
  if not svg_path then
    svg_cache[key] = false
    return nil
  end

  local ok, c = pcall(canvas.load_svg_image, svg_path, px_size, px_size)
  if ok and c then
    svg_cache[key] = c
    return c
  end

  -- Fallback to generic text file icon if an individual SVG fails
  if def_id ~= default_file_id and icon_defs[default_file_id] then
    local ok2, c2 = pcall(canvas.load_svg_image, icon_defs[default_file_id], px_size, px_size)
    if ok2 and c2 then
      svg_cache[key] = c2
      return c2
    end
  end

  svg_cache[key] = false
  return nil
end

--------------------------------------------------------------------------------
-- Vector Geometry Helpers (Conic Bezier Rounded Rects & Island Frames)
--------------------------------------------------------------------------------
local function draw_rounded_rect(x, y, w, h, r, color)
  if w <= 0 or h <= 0 then return end
  r = math.min(common.round(r or 0), math.floor(w / 2), math.floor(h / 2))
  if r <= 0 then
    renderer.draw_rect(x, y, w, h, color)
    return
  end
  renderer.draw_poly({
    { x + r, y },
    { x + w - r, y },
    { x + w - r, y, x + w, y, x + w, y + r },
    { x + w, y + h - r },
    { x + w, y + h - r, x + w, y + h, x + w - r, y + h },
    { x + r, y + h },
    { x + r, y + h, x, y + h, x, y + h - r },
    { x, y + r },
    { x, y + r, x, y, x + r, y },
  }, color)
end

local function draw_rounded_rect_stroke(x, y, w, h, r, thickness, fill_color, border_color)
  if w <= 0 or h <= 0 then return end
  local t = math.max(1, common.round(thickness or 1))
  if border_color and w > t * 2 and h > t * 2 then
    draw_rounded_rect(x, y, w, h, r, border_color)
    draw_rounded_rect(x + t, y + t, w - t * 2, h - t * 2, math.max(0, r - t), fill_color)
  else
    draw_rounded_rect(x, y, w, h, r, fill_color)
  end
end

local function draw_island_frame(x, y, w, h, gap, radius, frame_color)
  if w <= 0 or h <= 0 then return end
  gap = math.max(0, common.round(gap or 0))
  radius = math.max(0, common.round(radius or 0))

  if gap > 0 then
    local top_h = math.min(gap, h)
    local bot_h = math.min(gap, math.max(0, h - top_h))
    local side_w = math.min(gap, w)
    local side_h = math.max(0, h - top_h - bot_h)
    renderer.draw_rect(x, y, w, top_h, frame_color)
    if bot_h > 0 then
      renderer.draw_rect(x, y + h - bot_h, w, bot_h, frame_color)
    end
    if side_h > 0 and side_w > 0 then
      renderer.draw_rect(x, y + top_h, side_w, side_h, frame_color)
      if w - side_w > 0 then
        renderer.draw_rect(x + w - math.min(gap, w - side_w), y + top_h, math.min(gap, w - side_w), side_h, frame_color)
      end
    end
  end

  local ix = x + gap
  local iy = y + gap
  local iw = w - gap * 2
  local ih = h - gap * 2
  if iw <= 2 or ih <= 2 then return end

  local r = math.min(radius, math.floor(iw / 2), math.floor(ih / 2))
  if r <= 0 then return end

  -- 4 clockwise inverse corner spandrels matching conic bezier rounded rect boundary
  renderer.draw_poly({
    { ix, iy },
    { ix + r, iy },
    { ix + r, iy, ix, iy, ix, iy + r },
  }, frame_color)

  renderer.draw_poly({
    { ix + iw - r, iy },
    { ix + iw, iy },
    { ix + iw, iy + r },
    { ix + iw, iy + r, ix + iw, iy, ix + iw - r, iy },
  }, frame_color)

  renderer.draw_poly({
    { ix + iw, iy + ih - r },
    { ix + iw, iy + ih },
    { ix + iw - r, iy + ih },
    { ix + iw - r, iy + ih, ix + iw, iy + ih, ix + iw, iy + ih - r },
  }, frame_color)

  renderer.draw_poly({
    { ix + r, iy + ih },
    { ix, iy + ih },
    { ix, iy + ih - r },
    { ix, iy + ih - r, ix, iy + ih, ix + r, iy + ih },
  }, frame_color)
end

--------------------------------------------------------------------------------
-- Window Transparency & Windows 11 DWM Backdrop / Dark Mode Effects (LuaJIT FFI)
--------------------------------------------------------------------------------
local ffi_ok, ffi = pcall(require, "ffi")
local win_ffi_inited = false
local user32, dwmapi

local function init_win_ffi()
  if win_ffi_inited or not ffi_ok or PLATFORM ~= "Windows" then
    return win_ffi_inited and ffi_ok
  end
  pcall(ffi.cdef, [[
    typedef void* HANDLE;
    typedef HANDLE HWND;
    typedef uint32_t DWORD;
    typedef int BOOL;
    typedef long HRESULT;
    typedef const char* LPCSTR;
    typedef struct {
      int AccentState;
      int AccentFlags;
      uint32_t GradientColor;
      int AnimationId;
    } FLYING_ISLAND_ACCENT_POLICY;
    typedef struct {
      int Attribute;
      void* Data;
      size_t SizeOfData;
    } FLYING_ISLAND_WINCOMPATTRDATA;
    HWND FindWindowExA(HWND hWndParent, HWND hWndChildAfter, LPCSTR lpszClass, LPCSTR lpszWindow);
    DWORD GetWindowThreadProcessId(HWND hWnd, DWORD* lpdwProcessId);
    BOOL SetWindowCompositionAttribute(HWND hWnd, FLYING_ISLAND_WINCOMPATTRDATA* data);
    HRESULT DwmSetWindowAttribute(HWND hwnd, DWORD dwAttribute, const void* pvAttribute, DWORD cbAttribute);
  ]])
  local ok_u, u = pcall(ffi.load, "user32")
  local ok_d, d = pcall(ffi.load, "dwmapi")
  if ok_u and ok_d then
    user32 = u
    dwmapi = d
    win_ffi_inited = true
    return true
  end
  return false
end

local function find_current_sdl_hwnd()
  if not init_win_ffi() then return nil end
  local my_pid = system.get_process_id()
  local cur = nil
  local pid = ffi.new("uint32_t[1]")
  for _ = 1, 64 do
    cur = user32.FindWindowExA(nil, cur, "SDL_app", nil)
    if cur == nil then break end
    user32.GetWindowThreadProcessId(cur, pid)
    if pid[0] == my_pid then
      return cur
    end
  end
  return nil
end

local function apply_win32_blur(blur_mode)
  if PLATFORM ~= "Windows" or not init_win_ffi() then return false end
  local hwnd = find_current_sdl_hwnd()
  if not hwnd then return false end

  -- Enable Windows 11 dark title bar / window chrome & rounded window corners
  pcall(function()
    local dark = ffi.new("int[1]", 1)
    dwmapi.DwmSetWindowAttribute(hwnd, 20, dark, 4) -- DWMWA_USE_IMMERSIVE_DARK_MODE
    local corner = ffi.new("int[1]", 2)
    dwmapi.DwmSetWindowAttribute(hwnd, 33, corner, 4) -- DWMWCP_ROUND
  end)

  local mode = blur_mode or "acrylic"
  local dwm_backdrop = 1 -- DWMSBT_NONE
  local accent_state = 0 -- ACCENT_DISABLED

  if mode == "acrylic" then
    dwm_backdrop = 3 -- DWMSBT_TRANSIENTWINDOW
    accent_state = 3 -- ACCENT_ENABLE_BLURBEHIND (smooth with GDI/surface)
  elseif mode == "mica" then
    dwm_backdrop = 2 -- DWMSBT_MAINWINDOW
    accent_state = 0
  elseif mode == "tabbed" then
    dwm_backdrop = 4 -- DWMSBT_TABBEDWINDOW
    accent_state = 0
  elseif mode == "blur" then
    dwm_backdrop = 1
    accent_state = 3
  else
    dwm_backdrop = 1
    accent_state = 0
  end

  pcall(function()
    local backdrop = ffi.new("int[1]", dwm_backdrop)
    dwmapi.DwmSetWindowAttribute(hwnd, 38, backdrop, 4) -- DWMWA_SYSTEMBACKDROP_TYPE
  end)

  pcall(function()
    local policy = ffi.new("FLYING_ISLAND_ACCENT_POLICY")
    policy.AccentState = accent_state
    policy.AccentFlags = accent_state ~= 0 and 2 or 0
    policy.GradientColor = 0
    policy.AnimationId = 0
    local data = ffi.new("FLYING_ISLAND_WINCOMPATTRDATA")
    data.Attribute = 19 -- WCA_ACCENT_POLICY
    data.Data = policy
    data.SizeOfData = ffi.sizeof(policy)
    user32.SetWindowCompositionAttribute(hwnd, data)
  end)

  return true
end

local function apply_window_effects()
  local target_opacity = 1.0
  local blur_mode = "off"
  if cfg.enabled and cfg.enable_transparency then
    target_opacity = common.clamp(tonumber(cfg.opacity) or 0.93, 0.30, 1.00)
    blur_mode = cfg.win_blur or "acrylic"
  end

  if core.window and system.set_window_opacity then
    pcall(system.set_window_opacity, core.window, target_opacity)
  end
  if PLATFORM == "Windows" then
    pcall(apply_win32_blur, blur_mode)
  end
end

local function apply_inline_island_theme()
  style.background       = { common.color "#1E1F22" }
  style.background2      = { common.color "#191A1C" }
  style.background3      = { common.color "#26282B" }
  style.text             = { common.color "#DFE1E5" }
  style.caret            = { common.color "#BBBBBB" }
  style.accent           = { common.color "#3574F0" }
  style.dim              = { common.color "#6F737A" }
  style.divider          = { common.color "#26282B" }
  style.selection        = { common.color "#214283" }
  style.line_number      = { common.color "#4E5157" }
  style.line_number2     = { common.color "#9DA0A8" }
  style.line_highlight   = { common.color "#2B2D30" }
  style.scrollbar        = { common.color "#80808059" }
  style.scrollbar2       = { common.color "#8080808C" }
  style.scrollbar_track  = { common.color "#00000000" }
  style.nagbar           = { common.color "#26282B" }
  style.nagbar_text      = { common.color "#DFE1E5" }
  style.nagbar_dim       = { common.color "#00000066" }
  style.drag_overlay     = { common.color "#3574F033" }
  style.drag_overlay_tab = { common.color "#3574F0" }
  style.good             = { common.color "#549159" }
  style.warn             = { common.color "#D6AE58" }
  style.error            = { common.color "#DB5C5C" }
  style.modified         = { common.color "#375FAD" }
  style.island_frame         = { common.color "#26282B" }
  style.island_editor        = { common.color "#1E1F22" }
  style.island_sidebar       = { common.color "#191A1C" }
  style.island_border        = { common.color "#2B2D30" }
  style.island_tab_active_bg = { common.color "#25324D" }
  style.island_tab_active_bd = { common.color "#35538F" }
  style.island_tab_hover_bg  = { common.color "#2B2D30" }
  style.island_tree_select   = { common.color "#2E436E" }
  style.island_tree_unfocus  = { common.color "#393B40" }
  style.island_tree_hover    = { common.color "#252629" }
  style.syntax["normal"]     = { common.color "#A9B7C6" }
  style.syntax["symbol"]     = { common.color "#A9B7C6" }
  style.syntax["comment"]    = { common.color "#7A7E85" }
  style.syntax["keyword"]    = { common.color "#CC7832" }
  style.syntax["keyword2"]   = { common.color "#B5B6E3" }
  style.syntax["number"]     = { common.color "#6897BB" }
  style.syntax["literal"]    = { common.color "#9876AA" }
  style.syntax["string"]     = { common.color "#6A8759" }
  style.syntax["operator"]   = { common.color "#A9B7C6" }
  style.syntax["function"]   = { common.color "#FFC66D" }
  style.syntax["annotation"] = { common.color "#BBB529" }
end

local function apply_island_theme()
  if not (cfg.enabled and cfg.apply_theme) then return end
  local ok = pcall(core.reload_module, "colors.flying_island_dark")
  if not ok then
    apply_inline_island_theme()
  end
  core.redraw = true
end

--------------------------------------------------------------------------------
-- Theme startup application (respects user selecting another theme if saved)
--------------------------------------------------------------------------------
local function maybe_apply_startup_theme()
  local ok_s, data = pcall(dofile, USERDIR .. PATHSEP .. "user_settings.lua")
  local sc = ok_s and type(data) == "table" and type(data.config) == "table" and data.config or nil
  local fi = sc and type(sc.plugins) == "table" and type(sc.plugins.flying_island) == "table" and sc.plugins.flying_island or nil
  local disabled = sc and type(sc.disabled_plugins) == "table" and sc.disabled_plugins.flying_island == true
  if disabled then return end
  if fi then
    if fi.enabled == false or fi.apply_theme == false then return end
  end
  if not (cfg.enabled and cfg.apply_theme) then return end
  local saved_theme = sc and sc.theme
  if not saved_theme or saved_theme == "default" or saved_theme == "flying_island_dark" then
    apply_island_theme()
  end
end

maybe_apply_startup_theme()

--------------------------------------------------------------------------------
-- TreeView Hooks: SVG File/Folder Icons, Clean Chevrons, Rounded Rows & Island
--------------------------------------------------------------------------------
local orig_tv_draw_item_icon = TreeView.draw_item_icon
function TreeView:draw_item_icon(item, active, hovered, x, y, w, h)
  if cfg.enabled and cfg.show_treeview_icons then
    local is_dir = (item.type == "dir")
    local is_root = is_dir and (item.depth == 0)
    local icon_px = common.round(16 * SCALE)
    local def_id = resolve_icon_def(item.filename or item.name or "", is_dir, is_root)
    local c = get_icon_canvas(def_id, icon_px)
    if c then
      renderer.draw_canvas(c, common.round(x), common.round(y + (h - icon_px) / 2))
      return icon_px + style.padding.x / 2
    end
  end
  return orig_tv_draw_item_icon(self, item, active, hovered, x, y, w, h)
end

local orig_tv_draw_item_chevron = TreeView.draw_item_chevron
function TreeView:draw_item_chevron(item, active, hovered, x, y, w, h)
  if cfg.enabled and cfg.island_style and cfg.rounded_tree_rows then
    if item.type == "dir" then
      local color = hovered and style.text or style.dim
      local cx = common.round(x + style.padding.x / 2 - 2 * SCALE)
      local cy = common.round(y + h / 2)
      local s = common.round(4 * SCALE)
      if item.expanded then
        renderer.draw_poly({
          { cx - s, cy - 2 },
          { cx + s, cy - 2 },
          { cx, cy + s - 1 },
        }, color)
      else
        renderer.draw_poly({
          { cx - 2, cy - s },
          { cx + s - 1, cy },
          { cx - 2, cy + s },
        }, color)
      end
    end
    return style.padding.x
  end
  return orig_tv_draw_item_chevron(self, item, active, hovered, x, y, w, h)
end

local orig_tv_get_item_text = TreeView.get_item_text
function TreeView:get_item_text(item, active, hovered)
  local text, font, color = orig_tv_get_item_text(self, item, active, hovered)
  if cfg.enabled and cfg.island_style and cfg.rounded_tree_rows and (active or hovered) and color == style.accent then
    color = style.text
  end
  return text, font, color
end

local orig_tv_draw_item_background = TreeView.draw_item_background
function TreeView:draw_item_background(item, active, hovered, x, y, w, h)
  if cfg.enabled and cfg.island_style and cfg.rounded_tree_rows then
    if active or hovered then
      local gap = cfg.island_panels and common.round((cfg.island_gap or 4) * SCALE) or 0
      local inset_x = gap + common.round(4 * SCALE)
      local inset_y = common.round(1 * SCALE)
      local rw = math.max(8, self.size.x - inset_x * 2)
      local rh = math.max(4, h - inset_y * 2)
      local rad = common.round(5 * SCALE)
      local bg
      if active then
        if core.active_view == self then
          bg = style.island_tree_select or style.selection
        else
          bg = style.island_tree_unfocus or style.line_highlight
        end
      else
        bg = style.island_tree_hover or style.line_highlight
      end
      draw_rounded_rect(self.position.x + inset_x, y + inset_y, rw, rh, rad, bg)
    end
    return
  end
  return orig_tv_draw_item_background(self, item, active, hovered, x, y, w, h)
end

local orig_tv_draw = TreeView.draw
function TreeView:draw()
  orig_tv_draw(self)
  if cfg.enabled and cfg.island_style and cfg.island_panels and self.visible and self.size.x > 16 and self.size.y > 16 then
    draw_island_frame(
      self.position.x, self.position.y,
      self.size.x, self.size.y,
      common.round((cfg.island_gap or 4) * SCALE),
      common.round((cfg.island_radius or 10) * SCALE),
      style.island_frame or style.background3
    )
  end
end

--------------------------------------------------------------------------------
-- Node Hooks: Pill Active Tabs + Tab SVG Icons + Floating Editor Islands
--------------------------------------------------------------------------------
local orig_node_draw_tab = Node.draw_tab
function Node:draw_tab(view, is_active, is_hovered, is_close_hovered, x, y, w, h, standalone)
  local use_pill_tabs = cfg.island_style and cfg.pill_tabs
  if not cfg.enabled or (not use_pill_tabs and not cfg.show_tab_icons) then
    return orig_node_draw_tab(self, view, is_active, is_hovered, is_close_hovered, x, y, w, h, standalone)
  end

  local margin_y = style.margin and style.margin.tab and style.margin.tab.top or 0
  local ty = y + margin_y
  local th = h - margin_y

  local ix, iy, iw, ih = x, ty, w, th
  if use_pill_tabs then
    local gap = (standalone or not cfg.island_panels) and 0 or common.round((cfg.island_gap or 4) * SCALE)
    local top_off = math.max(gap + common.round(2 * SCALE), common.round(4 * SCALE))
    local bot_off = common.round(3 * SCALE)
    local side_off = common.round(2 * SCALE)
    local px = x + side_off
    local py = ty + top_off
    local pw = math.max(4, w - side_off * 2)
    local ph = math.max(style.font:get_height() + common.round(2 * SCALE), th - top_off - bot_off)
    if standalone then
      renderer.draw_rect(x - 1, ty - 1, w + 2, th + 2, style.background2)
    end
    local pr = common.round(6 * SCALE)
    if is_active then
      draw_rounded_rect_stroke(
        px, py, pw, ph, pr,
        math.max(1, common.round(1 * SCALE)),
        style.island_tab_active_bg or style.background,
        style.island_tab_active_bd or style.accent
      )
    elseif is_hovered then
      draw_rounded_rect(px, py, pw, ph, pr, style.island_tab_hover_bg or style.line_highlight)
    end
    ix, iy, iw, ih = px, py, pw, ph
  else
    ix, iy, iw, ih = self:draw_tab_borders(view, is_active, is_hovered, x, ty, w, th, standalone)
  end

  -- Close button
  local cw = style.icon_font:get_width("C")
  local cpad = style.padding.x / 2
  local cx = ix + iw - cw - cpad
  local show_close_button = ((is_active or is_hovered) and not standalone and config.tab_close_button)
  if show_close_button then
    local close_style = is_close_hovered and style.text or style.dim
    common.draw_text(style.icon_font, close_style, "C", nil, cx, iy, cw, ih)
  end

  -- Left JetBrains SVG icon inside tab
  local content_x = ix + cpad
  local content_w = math.max(0, cx - content_x)
  if cfg.show_tab_icons and view then
    local filename = (view.doc and (view.doc.filename or view.doc.abs_filename))
      or view.filename or view.path
    if type(filename) == "string" and filename ~= "" then
      local icon_px = common.round(15 * SCALE)
      if content_w > icon_px + style.padding.x then
        local def_id = resolve_icon_def(filename, false, false)
        local c = get_icon_canvas(def_id, icon_px)
        if c then
          renderer.draw_canvas(c, common.round(content_x), common.round(iy + (ih - icon_px) / 2))
          local step = icon_px + math.max(3, common.round(4 * SCALE))
          content_x = content_x + step
          content_w = math.max(0, cx - content_x)
        end
      end
    end
  end

  -- Title
  if content_w > 0 and ih > 0 then
    core.push_clip_rect(content_x, iy, content_w, ih)
    self:draw_tab_title(view, style.font, is_active, is_hovered, content_x, iy, content_w, ih)
    core.pop_clip_rect()
  end
end

local function is_chrome_view(view)
  if not view then return true end
  if view:is(TreeView) then return true end
  if CommandView and view:is(CommandView) then return true end
  if StatusView and view:is(StatusView) then return true end
  if TitleView and view:is(TitleView) then return true end
  if MenuView and view:is(MenuView) then return true end
  if NagView and view:is(NagView) then return true end
  local ToolbarView = package.loaded["plugins.toolbarview"]
  if ToolbarView and view:is(ToolbarView) then return true end
  return false
end

local orig_node_draw = Node.draw
function Node:draw()
  orig_node_draw(self)
  if cfg.enabled and cfg.island_style and cfg.island_panels and self.type == "leaf"
     and self.size.x > 24 and self.size.y > 24
     and not is_chrome_view(self.active_view)
  then
    draw_island_frame(
      self.position.x, self.position.y,
      self.size.x, self.size.y,
      common.round((cfg.island_gap or 4) * SCALE),
      common.round((cfg.island_radius or 10) * SCALE),
      style.island_frame or style.background3
    )
  end
end

--------------------------------------------------------------------------------
-- ToolbarView Hooks: Rounded Pill Hover Highlights & #26282B Activity Stripe
--------------------------------------------------------------------------------
local ToolbarView = package.loaded["plugins.toolbarview"]
if not ToolbarView then
  local ok_tb, tb = pcall(require, "plugins.toolbarview")
  if ok_tb then ToolbarView = tb end
end

if ToolbarView then
  local orig_tb_draw = ToolbarView.draw
  function ToolbarView:draw()
    if not (cfg.enabled and cfg.island_style and cfg.styled_toolbar) then
      return orig_tb_draw(self)
    end
    if not self:is_visible() then return end
    self:draw_background(style.island_frame or style.background3)
    local pad = common.round(5 * SCALE)
    local rad = common.round(6 * SCALE)
    for item, x, y, w, h in self:each_item() do
      local is_hov = (item == self.hovered_item) and command.is_valid(item.command)
      if is_hov then
        draw_rounded_rect(x - pad, y - pad, w + pad * 2, h + pad * 2, rad, { 255, 255, 255, 24 })
      end
      local color = is_hov and style.text or style.dim
      common.draw_text(
        item.font or self.toolbar_font,
        color,
        item.symbol,
        "center",
        x, y, w, h
      )
    end
  end
end

--------------------------------------------------------------------------------
-- Background Startup Effect Application (wait until core.window exists)
--------------------------------------------------------------------------------
core.add_thread(function()
  while not core.window do
    coroutine.yield(0.05)
  end
  apply_window_effects()
  core.redraw = true
end)

--------------------------------------------------------------------------------
-- Commands, Keybindings & Menu Items
--------------------------------------------------------------------------------
local function notify_opacity()
  local effective = (cfg.enabled and cfg.enable_transparency) and cfg.opacity or 1.0
  core.status_view:show_message("i", style.accent, string.format("Flying Island Opacity: %d%%", common.round(effective * 100)))
end

command.add(nil, {
  ["flying-island:toggle-transparency"] = function()
    cfg.enable_transparency = not cfg.enable_transparency
    apply_window_effects()
    notify_opacity()
  end,
  ["flying-island:increase-opacity"] = function()
    cfg.enable_transparency = true
    cfg.opacity = common.clamp(common.round((cfg.opacity + 0.03) * 100) / 100, 0.40, 1.00)
    apply_window_effects()
    notify_opacity()
  end,
  ["flying-island:decrease-opacity"] = function()
    cfg.enable_transparency = true
    cfg.opacity = common.clamp(common.round((cfg.opacity - 0.03) * 100) / 100, 0.40, 1.00)
    apply_window_effects()
    notify_opacity()
  end,
  ["flying-island:toggle-island-style"] = function()
    cfg.island_style = not cfg.island_style
    core.redraw = true
  end,
  ["flying-island:toggle-island-panels"] = function()
    cfg.island_panels = not cfg.island_panels
    core.redraw = true
  end,
  ["flying-island:toggle-pill-tabs"] = function()
    cfg.pill_tabs = not cfg.pill_tabs
    core.redraw = true
  end,
  ["flying-island:toggle-tree-rows"] = function()
    cfg.rounded_tree_rows = not cfg.rounded_tree_rows
    core.redraw = true
  end,
  ["flying-island:toggle-toolbar-style"] = function()
    cfg.styled_toolbar = not cfg.styled_toolbar
    core.redraw = true
  end,
  ["flying-island:toggle-icons"] = function()
    local next_state = not (cfg.show_treeview_icons or cfg.show_tab_icons)
    cfg.show_treeview_icons = next_state
    cfg.show_tab_icons = next_state
    core.redraw = true
  end,
  ["flying-island:toggle-treeview-icons"] = function()
    cfg.show_treeview_icons = not cfg.show_treeview_icons
    core.redraw = true
  end,
  ["flying-island:toggle-tab-icons"] = function()
    cfg.show_tab_icons = not cfg.show_tab_icons
    core.redraw = true
  end,
})

keymap.add {
  ["ctrl+alt+t"] = "flying-island:toggle-transparency",
  ["ctrl+alt+="] = "flying-island:increase-opacity",
  ["ctrl+alt+-"] = "flying-island:decrease-opacity",
}

if core.menu_view and core.menu_view.register then
  core.menu_view:register({ "view" }, {
    {
      id = "flying-island",
      text = "Flying Island",
      items = {
        {
          id = "fi-toggle-transparency",
          text = "Enable Window Transparency & Blur",
          command = "flying-island:toggle-transparency",
          checked = function() return cfg.enabled and cfg.enable_transparency end
        },
        {
          id = "fi-increase-opacity",
          text = "Increase Opacity",
          command = "flying-island:increase-opacity"
        },
        {
          id = "fi-decrease-opacity",
          text = "Decrease Opacity",
          command = "flying-island:decrease-opacity"
        },
        MenuView.DIVIDER,
        {
          id = "fi-toggle-island-style",
          text = "Floating Rounded Islands UI Style",
          command = "flying-island:toggle-island-style",
          checked = function() return cfg.island_style end
        },
        {
          id = "fi-toggle-island-panels",
          text = "Floating Rounded Panel Islands",
          command = "flying-island:toggle-island-panels",
          checked = function() return cfg.island_panels end
        },
        {
          id = "fi-toggle-pill-tabs",
          text = "Pill-Shaped Editor Tabs",
          command = "flying-island:toggle-pill-tabs",
          checked = function() return cfg.pill_tabs end
        },
        {
          id = "fi-toggle-tree-rows",
          text = "Rounded File Tree Rows & Chevrons",
          command = "flying-island:toggle-tree-rows",
          checked = function() return cfg.rounded_tree_rows end
        },
        {
          id = "fi-toggle-toolbar-style",
          text = "Styled Activity Toolbar",
          command = "flying-island:toggle-toolbar-style",
          checked = function() return cfg.styled_toolbar end
        },
        MenuView.DIVIDER,
        {
          id = "fi-toggle-icons",
          text = "JetBrains SVG Icons",
          command = "flying-island:toggle-icons",
          checked = function() return cfg.show_treeview_icons or cfg.show_tab_icons end
        },
        {
          id = "fi-toggle-treeview-icons",
          text = "File Tree SVG Icons",
          command = "flying-island:toggle-treeview-icons",
          checked = function() return cfg.show_treeview_icons end
        },
        {
          id = "fi-toggle-tab-icons",
          text = "Editor Tab SVG Icons",
          command = "flying-island:toggle-tab-icons",
          checked = function() return cfg.show_tab_icons end
        },
      }
    }
  }, "flying_island")
end

--------------------------------------------------------------------------------
-- GUI Settings Spec (integrates into Settings > Plugins > Flying Island)
--------------------------------------------------------------------------------
config.plugins.flying_island.config_spec = {
  name = "Flying Island",
  {
    label = "Enable Flying Island UI & Icons",
    description = "Enable JetBrains SVG icons, floating islands, and window translucency.",
    path = "enabled",
    type = "toggle",
    default = true,
    on_apply = function(value)
      cfg.enabled = value
      if value and cfg.apply_theme then
        apply_island_theme()
      end
      apply_window_effects()
      core.redraw = true
    end
  },
  {
    label = "Apply Flying Island Dark Theme",
    description = "Automatically apply the Flying Island Dark color scheme (#1E1F22 / #191A1C / #26282B).",
    path = "apply_theme",
    type = "toggle",
    default = true,
    on_apply = function(value)
      cfg.apply_theme = value
      if value then
        apply_island_theme()
      end
      core.redraw = true
    end
  },
  {
    label = "Show JetBrains SVG Icons in File Tree",
    description = "Render JetBrains 2023+ Dark SVG icons in TreeView.",
    path = "show_treeview_icons",
    type = "toggle",
    default = true,
    on_apply = function(value)
      cfg.show_treeview_icons = value
      core.redraw = true
    end
  },
  {
    label = "Show JetBrains SVG Icons in Editor Tabs",
    description = "Render JetBrains 2023+ Dark SVG file icons inside document tabs.",
    path = "show_tab_icons",
    type = "toggle",
    default = true,
    on_apply = function(value)
      cfg.show_tab_icons = value
      core.redraw = true
    end
  },
  {
    label = "Floating Rounded Islands UI Style",
    description = "Master switch for Floating Islands UI styling (panels, pill tabs, tree rows, and toolbar).",
    path = "island_style",
    type = "toggle",
    default = true,
    on_apply = function(value)
      cfg.island_style = value
      core.redraw = true
    end
  },
  {
    label = "Floating Rounded Panel Islands",
    description = "Draw rounded floating island frames around the file tree and editor panes.",
    path = "island_panels",
    type = "toggle",
    default = true,
    on_apply = function(value)
      cfg.island_panels = value
      core.redraw = true
    end
  },
  {
    label = "Island Corner Radius (px)",
    description = "Corner radius for floating TreeView and editor islands.",
    path = "island_radius",
    type = "number",
    default = 10,
    min = 0,
    max = 20,
    step = 1,
    on_apply = function(value)
      cfg.island_radius = value
      core.redraw = true
    end
  },
  {
    label = "Island Gap Width (px)",
    description = "Outer gap thickness framing each floating island.",
    path = "island_gap",
    type = "number",
    default = 4,
    min = 0,
    max = 14,
    step = 1,
    on_apply = function(value)
      cfg.island_gap = value
      core.redraw = true
    end
  },
  {
    label = "Pill-Shaped Editor Tabs",
    description = "Render active and hovered document tabs as rounded JetBrains-style pills.",
    path = "pill_tabs",
    type = "toggle",
    default = true,
    on_apply = function(value)
      cfg.pill_tabs = value
      core.redraw = true
    end
  },
  {
    label = "Rounded File Tree Rows & Chevrons",
    description = "Use rounded selection/hover pills and vector folder chevrons in TreeView.",
    path = "rounded_tree_rows",
    type = "toggle",
    default = true,
    on_apply = function(value)
      cfg.rounded_tree_rows = value
      core.redraw = true
    end
  },
  {
    label = "Styled Activity Toolbar",
    description = "Apply the Flying Island dark activity bar background and rounded hover highlights.",
    path = "styled_toolbar",
    type = "toggle",
    default = true,
    on_apply = function(value)
      cfg.styled_toolbar = value
      core.redraw = true
    end
  },
  {
    label = "Enable Window Transparency & Blur",
    description = "Enable custom window opacity and Windows 11 native DWM backdrop blur effects.",
    path = "enable_transparency",
    type = "toggle",
    default = true,
    on_apply = function(value)
      cfg.enable_transparency = value
      apply_window_effects()
    end
  },
  {
    label = "Window Opacity",
    description = "Overall window opacity (1.00 is opaque, 0.93 gives translucent glass vibrancy).",
    path = "opacity",
    type = "number",
    default = 0.93,
    min = 0.40,
    max = 1.00,
    step = 0.01,
    on_apply = function(value)
      cfg.opacity = value
      apply_window_effects()
    end
  },
  {
    label = "Windows 11 DWM Blur Mode",
    description = "Native Windows 11 DWM backdrop / blur composition effect.",
    path = "win_blur",
    type = "selection",
    default = "acrylic",
    values = {
      { "Acrylic", "acrylic" },
      { "Mica", "mica" },
      { "Tabbed", "tabbed" },
      { "Blur Behind", "blur" },
      { "Off", "off" }
    },
    on_apply = function(value)
      cfg.win_blur = value
      apply_window_effects()
    end
  }
}

return {
  resolve_icon_def = resolve_icon_def,
  get_icon_canvas = get_icon_canvas,
  apply_window_effects = apply_window_effects,
  apply_island_theme = apply_island_theme,
  draw_rounded_rect = draw_rounded_rect,
  draw_island_frame = draw_island_frame,
}
