hl.bind("CTRL+SUPER+ALT+Slash", hl.dsp.exec_cmd("xdg-open ~/.config/hypr/custom/keybinds.lua"), {description = "Shell (more): Edit user keybinds"} )

-- 2026-11-07: Super+F1 abre la hoja de atajos (Super+/ en latam es Super+Shift+7)
hl.bind("SUPER + F1", hl.dsp.exec_cmd(QS_IPC .. "cheatsheet toggle"), { description = "Shell (more): Toggle cheatsheet" })

-- 2026-11-13: atajos que el teclado latam deja inalcanzables (=, ;, /, [ y ] piden Shift o AltGr).
-- Zoom: Super + "+" (la tecla a la derecha de la tilde); Super + "-" ya funcionaba.
hl.bind("SUPER + plus", function()
    local z = math.min(3.0, hl.get_config("cursor:zoom_factor") + 0.3)
    hl.config({ cursor = { zoom_factor = z } })
end, { repeating = true, description = "Screen: Zoom in" })
-- Proporción de la división: Super + ñ / Super + { (las mismas teclas físicas que ; y ' en US).
hl.bind("SUPER + code:47", hl.dsp.layout("splitratio -0.1"), { repeating = true, description = "Windows: Adjust split ratio" })
hl.bind("SUPER + code:48", hl.dsp.layout("splitratio +0.1"), { repeating = true, description = "Windows: Adjust split ratio" })
-- Los que usaban "/" pasan a F1.
hl.bind("CTRL + SUPER + ALT + F1", hl.dsp.exec_cmd("xdg-open ~/.config/hypr/custom/keybinds.lua"), { description = "Shell (more): Edit user keybinds" })
hl.bind("SUPER + SHIFT + ALT + F1", hl.dsp.exec_cmd(QS_IPC .. "welcome show"), { description = "Shell (more): Welcome tour" })
