config = {
	editor = 'gvim',
	terminal = 'urxvtc',
	theme = awful.util.getdir('config') .. '/themes/current/theme.lua',
	browser = 'firefox',
	modkey = 'Mod4',
}

config.layouts = {
	default = {
		awful.layout.suit.tile.bottom,
		awful.layout.suit.fair.horizontal,
		awful.layout.suit.tile,
		awful.layout.suit.fair,
		awful.layout.suit.max,
	},
	code = {
		awful.layout.suit.tile.bottom,
		awful.layout.suit.fair.horizontal,
		awful.layout.suit.tile,
		awful.layout.suit.fair,
	},
	web = { -- Tag 2
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
			if not s:match('return') then s = 'return ' .. s end
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

