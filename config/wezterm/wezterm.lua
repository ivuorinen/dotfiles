local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- Font and font size
config.font_size = 14.0
config.font = wezterm.font("JetBrainsMonoNL Nerd Font Mono")

-- Make the window a bit transparent
config.window_background_opacity = 0.97

-- Don't show tab bar
config.enable_tab_bar = false

-- Function to detect the theme based on appearance
function Scheme_for_appearance(appearance)
  if appearance:find("Dark") then
    return "Tokyo Night Storm"
  else
    return "Tokyo Night Day"
  end
end

-- Set the color scheme based on appearance
---@diagnostic disable-next-line: unused-local
wezterm.on("window-config-reloaded", function(window, pane)
  local overrides = window:get_config_overrides() or {}
  local appearance = window:get_appearance()
  local scheme = Scheme_for_appearance(appearance)
  if overrides.color_scheme ~= scheme then
    overrides.color_scheme = scheme
    window:set_config_overrides(overrides)
  end
end)

return config
