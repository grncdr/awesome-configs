config = {
	editor = 'urxvt -e vim',
	terminal = 'urxvt',
	theme = awful.util.getdir('config') .. '/themes/current/theme.lua',
	browser = 'firefox',
	modkey = 'Mod4',
}

config.layouts = {
	default = { -- Used on auto-generated tags and tags without their own layout table
		awful.layout.suit.tile,
		awful.layout.suit.fair,
		awful.layout.suit.tile.bottom,
		awful.layout.suit.fair.horizontal,
		awful.layout.suit.max,
		awful.layout.suit.floating,
	},
	code = {
		awful.layout.suit.tile.bottom,
		awful.layout.suit.fair.horizontal,
		awful.layout.suit.max,
	},
	web = { -- Tag 2
		awful.layout.suit.max,
	},
	pdf = { -- Tag 2
		awful.layout.suit.max,
	},
	bore = { -- Tag 3
		awful.layout.suit.max,
		awful.layout.suit.magnifier,
	},
	sys = {
		awful.layout.suit.tile.bottom,
		awful.layout.suit.fair.horizontal,
		awful.layout.suit.tile,
		awful.layout.suit.fair,
		awful.layout.suit.max,
	},
	term = { -- Tag 5
		awful.layout.suit.tile.bottom,
		awful.layout.suit.fair.horizontal,
		awful.layout.suit.tile.top,
		awful.layout.suit.fair,
		awful.layout.suit.tile,
		awful.layout.suit.tile.left,
		awful.layout.suit.max,
		awful.layout.suit.spiral.dwindle,
	},
	ssh = { -- Tag 6
		awful.layout.suit.tile.bottom,
		awful.layout.suit.fair.horizontal,
		awful.layout.suit.tile,
		awful.layout.suit.fair,
		awful.layout.suit.max,
	},
}

-- Table of application class/instance names to match and do things with in hooks.manage

-- Widget Settings --
obvious.clock.set_editor(config.editor)
obvious.clock.set_shortformat("%I:%M %d/%m/%y ")
obvious.clock.set_longformat(function ()
		local str = "  %a, %b %d"
		local date = os.date('%d')
		local date = { tonumber(date:sub(1,1)), tonumber(date:sub(1,1)) }
		if date[0] == 0 or date[0] == 2 then
			if date[1] == 3 then
				str = str .. 'rd '
			elseif date[1] == 2 then
				str = str .. 'nd '
			elseif date[1] == 1 then
				str = str .. 'st '
			else
				str = str .. 'th '
			end
		else
			str = str .. 'th '
		end
		return str
	end)

obvious.popup_run_prompt.set_slide(true)
-- Table of prompt functions for keybindings
config.prompts = {
	default = function ()
		obvious.popup_run_prompt.set_run_function(function (s)
			local rv = awful.util.spawn(s, true)
			if rv then naughty.notify({ text = awful.util.escape(rv), screen = mouse.screen }) end
		end)
		obvious.popup_run_prompt.set_prompt_string(" $ ")
		obvious.popup_run_prompt.run_prompt()
	end,
	capture_output = function ()
		obvious.popup_run_prompt.set_prompt_string(' $ ')
		obvious.popup_run_prompt.set_run_function(function (s)
			local out = awful.util.escape(awful.util.pread(s.." 2>&1"))
			if out then naughty.notify({ text = txt, timeout = 0, screen = mouse.screen }) end
		end)
		obvious.popup_run_prompt.run_prompt()
	end,
	lua = function ()
		obvious.popup_run_prompt.set_prompt_string(' lua> ')
		obvious.popup_run_prompt.set_run_function(function (s)
			if not (s:match('return') or s:match('=')) then s = 'return ' .. s end
			local rv = awful.util.eval(s)
			if rv then naughty.notify({ text = tostring(rv), screen = mouse.screen }) end
		end)
		obvious.popup_run_prompt.set_completion_function(awful.completion.shell)
		obvious.popup_run_prompt.run_prompt()
	end,
	ssh = function ()
		obvious.popup_run_prompt.set_prompt_string(' ssh ')
		obvious.popup_run_prompt.set_run_function(function (s)
			awful.util.spawn(config.terminal .. ' -e ssh ' .. s)
		end)
		obvious.popup_run_prompt.set_completion_function(function(command, cur_pos, ncomp, shell)
			cmd, pos = awful.completion.shell( 'ssh ' .. command, cur_pos + 4, ncomp + 1, shell )
			return cmd:sub(5), pos
		end)
		obvious.popup_run_prompt.run_prompt()
	end,
}

clientbuttons = awful.util.table.join(
		awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
		awful.button({ config.modkey }, 1, awful.mouse.client.move),
		awful.button({ config.modkey }, 3, awful.mouse.client.resize))

-- Per client keybindings
clientkeys = awful.util.table.join(
	awful.key({ config.modkey,					 }, "f",			function (c) c.fullscreen = not c.fullscreen	end),
	awful.key({ config.modkey,					 }, "q",			function (c) c:kill()												 end),
	awful.key({ config.modkey, "Control" }, "space",	awful.client.floating.toggle										 ),
--	awful.key({ config.modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
	awful.key({ config.modkey,					 }, "o",			awful.client.movetoscreen												),
	awful.key({ config.modkey, "Shift"	 }, "r",			function (c) c:redraw() end)
)

-- {{{ Awful / Dyno rules
awful.rules.rules = {
	{ rule = { },
		properties = { 
			border_width = beautiful.border_width,
			border_color = beautiful.border_normal,
			focus = true,
			keys = clientkeys,
			buttons = clientbuttons } },
	-- URxvt apps
	{ rule = { class = "URxvt", name = "@" },
		properties = { tagname = 'ssh' } },
	{ rule = { class = "URxvt", name = "MOC" },
		properties = { tagname = 'media' } },
	{ rule = { class = "URxvt", name = "WeeChat" },
		properties = { tagname = 'chat' } },
	{ rule = { name = "VIM" }, 
		properties = { tagname = 'code' } },
	{ rule = { class = "URxvt", name = "vim" }, 
		properties = { tagname = 'code' } },
	{ rule = { name = "wicd%-curses"}, 
		properties = { tagname = 'sys' } },
	{ rule = { name = "yaourt"}, 
		properties = { tagname = 'sys' } },
	{ rule = { name = "alsamixer" }, 
		properties = { tagname = 'sys' } },
	{ rule = { class = "URxvt" }, 
		properties = { tagname = 'term' } },

	-- GUI apps
	{ rule = { class = "Shiretoko" }, 
		properties = { tagname = 'web', switchtotag = true  } },
	{ rule = { class = "Firefox" }, 
		properties = { tagname = 'web', switchtotag = true  } },
	{ rule = { class = "Evince" }, 
		properties = { tagname = 'pdf' } },
	{ rule = { name = "Save As" }, 
		properties = { tagname = 'any' } },
	
	-- Floating apps
	{ rule = { class = "Qalculate" }, 
		properties = { floating = true, tagname = 'any' } },
	{ rule = { class = "Cellwriter" }, 
		properties = { floating = true, sticky = true, tagname = 'any' } },
}
-- }}}
