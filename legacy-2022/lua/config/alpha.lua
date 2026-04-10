local alpha = require("alpha")
local dashboard = require("alpha.themes.dashboard")
local fortune = require("alpha.fortune")

-- Set header
dashboard.section.header.val = {
    "                                                     ",
    "  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗ ",
    "  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║ ",
    "  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║ ",
    "  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║ ",
    "  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║ ",
    "  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝ ",
    "                                                     ",
}

-- Set menu
-- Set menu
dashboard.section.buttons.val = {
    dashboard.button("e", "  New file", ":ene <BAR> startinsert <CR>"),
    dashboard.button("SPC f", "  Find file", ":Telescope find_files <CR>"),
    dashboard.button("SPC f p", "  Recent Projects", ":Telescope projects <CR>"),
    dashboard.button("SPC f r", "  Frecency/MRU"),
    dashboard.button("SPC f g", "  Find word"),
    dashboard.button("SPC f m", "  Jump to bookmarks"),
    dashboard.button("SPC s l", "  Open last session"),
    dashboard.button("C", "  Config", ":e ~/.config/nvim/init.lua <CR>")
}

-- Daily Quote
dashboard.section.footer.val = fortune()

alpha.setup(dashboard.opts)

-- Send config to alpha
alpha.setup(dashboard.opts)
