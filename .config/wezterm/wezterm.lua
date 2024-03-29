local wezterm = require("wezterm")
local mux = wezterm.mux

wezterm.on("gui-startup", function()
	local tab, pane, window = mux.spawn_window(cmd or {})
	window:gui_window():toggle_fullscreen()
end)

return {
	font = wezterm.font("JetBrainsMono Nerd Font Mono"),
	font_size = 20,
	color_scheme = "Catppuccin Mocha",
	window_frame = {
		font_size = 16,
	},
	tab_bar_at_bottom = true,
	window_padding = {
		left = 0,
		right = 0,
		top = 0,
		bottom = 0,
	},
	native_macos_fullscreen_mode = true,
	use_fancy_tab_bar = false,
	default_cursor_style = "BlinkingBar",
}
