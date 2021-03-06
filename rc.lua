-- Standard awesome library
require("awful")
require("awful.rules")
require("awful.autofocus")
-- Theme handling library
require("beautiful")
-- Notification library
require("naughty")
require("colour")

require("obvious")

dofile(awful.util.getdir('config') .. '/config.lua')

-- A couple of utility functions
function layout_change(idx) 
	if config.layouts[awful.tag.selected().name] then
		awful.layout.inc(config.layouts[awful.tag.selected().name], idx)
	else
		awful.layout.inc(config.layouts.default, idx)
	end
end

-- Actually load theme
beautiful.init(config.theme)


-- {{{ Tags
-- Define tags table.
tags = {}
for s = 1, screen.count() do
	-- Each screen has its own tag table.
	tags[s] = {}
end
-- }}}

-- {{{ Wibox

-- Create a laucher widget and a main menu
myawesomemenu = {
	 { "manual", config.terminal .. " -e man awesome" },
	 { "edit rc", config.editor .. " " .. awful.util.getdir("config") .. "/rc.lua" },
	 { "edit theme", config.editor .. " " .. awful.util.getdir("config") .. "/themes/current/theme.lua" },
	 { "Xephyr", "Xephyr -ac -br -noreset -screen 1280x780 :1" },
	 { "test config", config.terminal .. "-e DISPLAY=:1.0 awesome" },
	 { "restart", awesome.restart },
	 { "terminal", config.terminal },
	 { "quit", awesome.quit }
}

mymusicmenu = {
	{ "patchage", "patchage" },
	{ "qjackctl", "qjackctl" },
	{ "sooperlooper", "slgui" },
	{ "reaper", "reaper" }
}

myappsmenu = {
	{ "firefox", "firefox" },
	{ "nautilus", "nautilus --no-desktop" },
	{ "midori", "midori" },
	{ "CellWriter", "cellwriter" },
	{ "thunar", "thunar" },
	{ "gajim", "gajim" },
	{ "evince", "evince" },
	{ "xournal", "xournal" },
	{ "calc", "gcalc" },
	{ "qalculate", "qalculate" }
}

myrotatemenu = {
	{ "left", "rotate.sh left" },
	{ "right", "rotate.sh right" },
	{ "180", "rotate.sh 180" },
	{ "Toggle Touch", "toggle_touch.sh" }
}

mymainmenu = awful.menu.new({ 
	items = { 
		{ "awesome", myawesomemenu, beautiful.awesome_icon },
		{ "apps", myappsmenu },
		{ "music", mymusicmenu },
		{ "rotate", myrotatemenu }
	}
})

mylauncher = awful.widget.launcher({ image = image(beautiful.awesome_icon),
									 menu = mymainmenu })

-- Create a systray
mysystray = widget({ type = "systray" })

-- Create a wibox for each screen and add it
mywibox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
					awful.button({ }, 1, awful.tag.viewonly),
					awful.button({ config.modkey }, 1, awful.client.movetotag),
					awful.button({ }, 3, function (tag) tag.selected = not tag.selected end),
					awful.button({ config.modkey }, 3, awful.client.toggletag)
					)
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
					 awful.button({ }, 1, function (c)
												if not c:isvisible() then
													awful.tag.viewonly(c:tags()[1])
												end
												client.focus = c
												c:raise()
											end),
					 awful.button({ }, 3, function ()
												if instance then
													instance:hide()
													instance = nil
												else
													instance = awful.menu.clients({ width=250 })
												end
											end),
					 awful.button({ }, 4, function ()
												awful.client.focus.byidx(1)
												if client.focus then client.focus:raise() end
											end),
					 awful.button({ }, 5, function ()
												awful.client.focus.byidx(-1)
												if client.focus then client.focus:raise() end
											end))
for s = 1, screen.count() do
	-- Create an imagebox widget which will contains an icon indicating which layout we're using.
	-- We need one layoutbox per screen.
	mylayoutbox[s] = awful.widget.layoutbox(s)
	mylayoutbox[s].buttons = awful.util.table.join(
		awful.button({ }, 1, function() layout_change(1) end),
		awful.button({ }, 3, function() layout_change(-1) end)
	)
	-- Create a taglist widget
	mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, mytaglist.buttons)

	-- Create a tasklist widget
	mytasklist[s] = awful.widget.tasklist(function(c)
												return awful.widget.tasklist.label.currenttags(c, s)
											end, mytasklist.buttons)

	-- Create the wibox
	mywibox[s] = awful.wibox({ position = "top", screen = s })
	-- Add widgets to the wibox - order matters
	mywibox[s].widgets = {
		{
			mylauncher,
			mytaglist[s],
			layout = awful.widget.layout.horizontal.leftright
		},
		mylayoutbox[s],
		obvious.clock(),
		obvious.battery(),
		s == 1 and mysystray or nil,
		mytasklist[s],
		layout = awful.widget.layout.horizontal.rightleft
		}
end
-- }}}

-- {{{ Mouse bindings
root.buttons = awful.util.table.join(
	awful.button({ }, 3, function () mymainmenu:toggle() end),
	awful.button({ }, 4, awful.tag.viewnext),
	awful.button({ }, 5, awful.tag.viewprev))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
	awful.key({ config.modkey			 }, "Left",	 awful.tag.viewprev		 ),
	awful.key({ config.modkey			 }, "Right",	awful.tag.viewnext		 ),
	awful.key({ config.modkey			 }, "Escape", awful.tag.history.restore),
	awful.key({ config.modkey			 }, "j",
		function ()
			awful.client.focus.byidx( 1)
			if client.focus then client.focus:raise() end
		end),
	awful.key({ config.modkey,			 }, "k",
		function ()
			awful.client.focus.byidx(-1)
			if client.focus then client.focus:raise() end
		end),
	awful.key({ config.modkey,			 }, "w", function () mymainmenu:show(true)		end),

		-- Quicklaunch apps
	awful.key({ config.modkey,			 }, "n", function () awful.util.spawn(config.terminal .. " -name wicd-curses -e wicd-curses") end ),
	awful.key({ config.modkey,			 }, "m", function () awful.util.spawn(config.terminal .. " -name alsamixer -e alsamixer") end ),

	-- Layout manipulation
	awful.key({ config.modkey, "Shift"	 }, "j", function () awful.client.swap.byidx(	1) end),
	awful.key({ config.modkey, "Shift"	 }, "k", function () awful.client.swap.byidx( -1) end),
	awful.key({ config.modkey, "Control" }, "j", function () awful.screen.focus( 1)		 end),
	awful.key({ config.modkey, "Control" }, "k", function () awful.screen.focus(-1)		 end),
	awful.key({ config.modkey,			 }, "u", awful.client.urgent.jumpto),
	awful.key({ config.modkey,			 }, "Tab",
		function ()
			awful.client.focus.history.previous()
			if client.focus then
				client.focus:raise()
			end
		end),

	-- Standard program
	awful.key({ config.modkey,					 }, "Return", function () awful.util.spawn(config.terminal) end),
	awful.key({ config.modkey, "Control" }, "r", awesome.restart),
	awful.key({ config.modkey, "Shift", "Control" }, "q", awesome.quit),

	awful.key({ config.modkey,			 }, "l",	 function () awful.tag.incmwfact( 0.05)	end),
	awful.key({ config.modkey,			 }, "h",	 function () awful.tag.incmwfact(-0.05)	end),
	awful.key({ config.modkey, "Shift"	 }, "h",	 function () awful.tag.incnmaster( 1)		end),
	awful.key({ config.modkey, "Shift"	 }, "l",	 function () awful.tag.incnmaster(-1)		end),
	awful.key({ config.modkey, "Control" }, "h",	 function () awful.tag.incncol( 1)		 end),
	awful.key({ config.modkey, "Control" }, "l",	 function () awful.tag.incncol(-1)		 end),
	awful.key({ config.modkey,			 }, "BackSpace", function () layout_change(1) end),
	awful.key({ config.modkey, "Shift"	 }, "BackSpace", function () layout_change(-1) end),

	-- Prompts
	awful.key({ config.modkey }, "r", config.prompts.default),
	awful.key({ config.modkey, "Mod1" }, "Return", config.prompts.capture_output),
	awful.key({ config.modkey }, "x", config.prompts.lua),
	awful.key({ config.modkey }, "s", config.prompts.ssh)
)


-- tag key shortcuts
for i = 1, 9 do
		globalkeys = awful.util.table.join(globalkeys,
				awful.key({ config.modkey }, i,
									function ()
											local screen = mouse.screen
											if tags[screen][i] then
												awful.tag.viewonly(tags[screen][i])
											end
									end),
				awful.key({ config.modkey, "Control" }, i,
									function ()
											local screen = mouse.screen
											if tags[screen][i] then
													tags[screen][i].selected = not tags[screen][i].selected
											end
									end),
				awful.key({ config.modkey, "Shift" }, i,
									function ()
											if client.focus and tags[client.focus.screen][i] then
													awful.client.movetotag(tags[client.focus.screen][i])
											end
									end),
				awful.key({ config.modkey, "Control", "Shift" }, i,
									function ()
											if client.focus and tags[client.focus.screen][i] then
													awful.client.toggletag(tags[client.focus.screen][i])
											end
									end))
end

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.add_signal("manage", function (c, startup)
		-- If we are not managing this application at startup,
		-- move it to the screen where the mouse is.
		-- We only do it for filtered windows (i.e. no dock, etc).
		if not startup and awful.client.focus.filter(c) then
				c.screen = mouse.screen
		end

		-- Add a titlebar
		if awful.client.floating.get(c) then
			awful.titlebar.add(c, { modkey = config.modkey })
		end


		-- Enable sloppy focus
		c:add_signal("mouse::enter", function(c)
				if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
						and awful.client.focus.filter(c) then
						client.focus = c
				end
		end)

		-- Set the windows at the slave,
		-- i.e. put it at the end of others instead of setting it master.
		-- awful.client.setslave(c)
end)

client.add_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.add_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}
require("dyno")
