local wezterm                       = require 'wezterm'
local config                        = wezterm.config_builder()

config.color_scheme                 = 'Chester'
config.font                         = wezterm.font 'Cascadia Code NF'

config.use_fancy_tab_bar            = false
config.hide_tab_bar_if_only_one_tab = true
config.tab_bar_at_bottom            = true

config.default_prog                 = { 'powershell.exe', '-NoLogo' }
config.default_cwd                  = "C:\\Users\\fumen\\Desktop"

config.window_close_confirmation    = 'NeverPrompt'
config.keys                         = {
    -- {
    --     key = 'w',
    --     mods = 'CTRL|SHIFT',
    --     action = wezterm.action.CloseCurrentTab { confirm = false },
    -- },
    {
        key = 'w',
        mods = 'CTRL|SHIFT',
        action = wezterm.action.CloseCurrentPane { confirm = false },
    },
}

return config
