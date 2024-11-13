local wezterm = require("wezterm")

local config = wezterm.config_builder()

local bgColor = "#050014"

-- Color Scheme
local scheme = wezterm.color.get_builtin_schemes()["Tokyo Night Moon"]
scheme.background = bgColor
config.color_schemes = {
	["My Custom Scheme"] = scheme,
}
config.color_scheme = "My Custom Scheme"

-- Font
config.font_size = 18
config.font = wezterm.font("FiraCode Nerd Font Mono")

-- Tab Appearance
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true

config.colors = {
	tab_bar = {
		background = bgColor,

		active_tab = {
			bg_color = bgColor,
			fg_color = scheme.ansi[6],
		},

		inactive_tab = {
			bg_color = bgColor,
			fg_color = scheme.brights[8],
		},

		inactive_tab_hover = {
			bg_color = bgColor,
			fg_color = scheme.ansi[6],
		},

		new_tab = {
			bg_color = bgColor,
			fg_color = scheme.ansi[8],
		},

		new_tab_hover = {
			bg_color = bgColor,
			fg_color = scheme.ansi[6],
		},
	},
}

config.window_decorations = "RESIZE"

local process_icons = {
	["docker"] = wezterm.nerdfonts.linux_docker,
	["docker-compose"] = wezterm.nerdfonts.linux_docker,
	["psql"] = "󱤢",
	["usql"] = "󱤢",
	["kuberlr"] = wezterm.nerdfonts.linux_docker,
	["ssh"] = wezterm.nerdfonts.fa_exchange,
	["ssh-add"] = wezterm.nerdfonts.fa_exchange,
	["kubectl"] = wezterm.nerdfonts.linux_docker,
	["stern"] = wezterm.nerdfonts.linux_docker,
	["nvim"] = wezterm.nerdfonts.custom_vim,
	["make"] = wezterm.nerdfonts.seti_makefile,
	["vim"] = wezterm.nerdfonts.dev_vim,
	["node"] = wezterm.nerdfonts.mdi_hexagon,
	["go"] = wezterm.nerdfonts.seti_go,
	["zsh"] = wezterm.nerdfonts.dev_terminal,
	["bash"] = wezterm.nerdfonts.cod_terminal_bash,
	["btm"] = wezterm.nerdfonts.mdi_chart_donut_variant,
	["htop"] = wezterm.nerdfonts.mdi_chart_donut_variant,
	["cargo"] = wezterm.nerdfonts.dev_rust,
	["sudo"] = wezterm.nerdfonts.fa_hashtag,
	["lazydocker"] = wezterm.nerdfonts.linux_docker,
	["lazygit"] = wezterm.nerdfonts.dev_git,
	["git"] = wezterm.nerdfonts.dev_git,
	["lua"] = wezterm.nerdfonts.seti_lua,
	["wget"] = wezterm.nerdfonts.mdi_arrow_down_box,
	["curl"] = wezterm.nerdfonts.mdi_flattr,
	["gh"] = wezterm.nerdfonts.dev_github_badge,
	["ruby"] = wezterm.nerdfonts.cod_ruby,
}

local function get_current_working_dir(tab)
	local current_dir = tab.active_pane and tab.active_pane.current_working_dir or {
		file_path = "",
	}
	local HOME_DIR = string.format("file://%s", os.getenv("HOME"))

	return current_dir == HOME_DIR and "." or string.gsub(current_dir.file_path, "(.*[/\\])(.*)", "%2")
end

local function get_process(tab)
	if not tab.active_pane or tab.active_pane.foreground_process_name == "" then
		return "[?]"
	end

	local process_name = string.gsub(tab.active_pane.foreground_process_name, "(.*[/\\])(.*)", "%2")
	if string.find(process_name, "kubectl") then
		process_name = "kubectl"
	end

	return process_icons[process_name] or string.format("[%s]", process_name)
end

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
	local has_unseen_output = false
	if not tab.is_active then
		for _, pane in ipairs(tab.panes) do
			if pane.has_unseen_output then
				has_unseen_output = true
				break
			end
		end
	end

	local cwd = wezterm.format({
		{
			Attribute = {
				Intensity = "Bold",
			},
		},
		{
			Text = get_current_working_dir(tab),
		},
	})

	local title = string.format(" %s ~ %s  ", get_process(tab), cwd)

	if has_unseen_output then
		return {
			{
				Foreground = {
					Color = scheme.ansi[5],
				},
			},
			{
				Text = title,
			},
		}
	end

	return { {
		Text = title,
	} }
end)

config.tab_max_width = 60
config.default_cursor_style = "SteadyUnderline"

config.command_palette_font_size = 18
config.command_palette_bg_color = bgColor
-- config.enable_kitty_keyboard = true

config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 3000 }
config.keys = {
	-- Send "CTRL-A" to the terminal when pressing CTRL-A, CTRL-A
	{
		key = "a",
		mods = "LEADER|CTRL",
		action = wezterm.action.SendKey({ key = "a", mods = "CTRL" }),
	},
	-- Make Option-Left equivalent to Alt-b which many line editors interpret as backward-word
	{ key = "LeftArrow",  mods = "OPT", action = wezterm.action({ SendString = "\x1bb" }) },
	-- Make Option-Right equivalent to Alt-f; forward-word
	{ key = "RightArrow", mods = "OPT", action = wezterm.action({ SendString = "\x1bf" }) },
}

-- and finally, return the configuration to wezterm
return config
