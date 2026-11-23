local style = require "core.style"
local common = require "core.common"

-- Flying Island Dark theme ported from am1dreaming/Flying-Island-dark-for-VS-code
-- Palette combines JetBrains New UI Islands (#191A1C, #1E1F22, #26282B) & Darcula Contrast syntax

style.background       = { common.color "#1E1F22" } -- Editor island background
style.background2      = { common.color "#191A1C" } -- TreeView / Sidebar island & tab bar background
style.background3      = { common.color "#26282B" } -- Outer frame / gap / commandbar
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

style.diff_delete            = { common.color "#8A3F3F" }
style.diff_insert            = { common.color "#3F6B45" }
style.diff_modify            = { common.color "#375FAD" }
style.diff_delete_background = { common.color "#DB5C5C2A" }
style.diff_insert_background = { common.color "#5491592A" }
style.diff_modify_background = { common.color "#3574F02A" }
style.diff_delete_inline     = { common.color "#DB5C5C44" }
style.diff_insert_inline     = { common.color "#54915944" }

style.search_selection      = { common.color "#254C99" }
style.search_selection_text = { common.color "#FFFFFF" }

-- Extended Flying Island UI palette entries
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

-- Darcula Contrast syntax palette
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

style.log["INFO"]  = { icon = "i", color = style.text }
style.log["WARN"]  = { icon = "!", color = style.warn }
style.log["ERROR"] = { icon = "!", color = style.error }

return style
