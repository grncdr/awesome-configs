-- Standard awesome library
require("awful")
require("awful.autofocus")
-- Theme handling library
require("beautiful")
-- Notification library
require("naughty")
require("colour")

require("obvious")

modkey = "Mod4"
dofile(awful.util.getdir('config') .. '/config.lua')

-- A couple of utility functions
function nextlayout() 
	awful.layout.inc(config.tags[awful.tag.selected().name].layouts, 1)
end

function prevlayout() 
	awful.layout.inc(config.tags[awful.tag.selected().name].layouts, -1)
end


-- Actually load theme
beautiful.init(config.theme)

-- {{{ Tags
-- Define tags table.
-- require("shifty-config")
tags = {}
for s = 1, screen.count() do
	-- Each screen has its own tag table.
  tags[s] = {}
	for i, t in ipairs(config.tags) do
				tags[s][i] = tag({ name = t.name })
        tags[s][i].screen = s
        awful.tag.setproperty(tags[s][i], "layout", t.layouts[1])
	end
  -- Select the first tag.
	tags[s][1].selected = true
end
-- }}}

-- {{{ Wibox

-- Create a laucher widget and a main menu
myawesomemenu = {
   { "manual", config.terminal .. " -e man awesome" },
   { "edit rc", config.editor .. " " .. awful.util.getdir("config") .. "/rc.lua" },
   { "edit theme", config.editor .. " " .. awful.util.getdir("config") .. "/themes/current/theme.lua" },
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
					awful.button({ modkey }, 1, awful.client.movetotag),
					awful.button({ }, 3, function (tag) tag.selected = not tag.selected end),
					awful.button({ modkey }, 3, awful.client.toggletag)
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
		awful.button({ }, 1, nextlayout),
		awful.button({ }, 3, prevlayout)
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
	awful.key({ modkey		   }, "Left",   awful.tag.viewprev	   ),
	awful.key({ modkey		   }, "Right",  awful.tag.viewnext	   ),
	awful.key({ modkey		   }, "Escape", awful.tag.history.restore),
	awful.key({ modkey		   }, "j",
		function ()
			awful.client.focus.byidx( 1)
			if client.focus then client.focus:raise() end
		end),
	awful.key({ modkey,		   }, "k",
		function ()
			awful.client.focus.byidx(-1)
			if client.focus then client.focus:raise() end
		end),
	awful.key({ modkey,		   }, "w", function () mymainmenu:show(true)		end),

		-- Quicklaunch apps
	awful.key({ modkey,		   }, "n", function () awful.util.spawn(config.terminal .. " -e wicd-curses") end ),
	awful.key({ modkey,		   }, "m", function () awful.util.spawn(config.terminal .. " -e alsamixer") end ),

	-- Layout manipulation
	awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1) end),
	awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1) end),
	awful.key({ modkey, "Control" }, "j", function () awful.screen.focus( 1)	   end),
	awful.key({ modkey, "Control" }, "k", function () awful.screen.focus(-1)	   end),
	awful.key({ modkey,		   }, "u", awful.client.urgent.jumpto),
	awful.key({ modkey,		   }, "Tab",
		function ()
			awful.client.focus.history.previous()
			if client.focus then
				client.focus:raise()
			end
		end),

	-- Standard program
	awful.key({ modkey, "Control" }, "Return", function () awful.util.spawn(config.terminal) end),
	awful.key({ modkey, "Control" }, "r", awesome.restart),
	awful.key({ modkey, "Shift", "Control" }, "q", awesome.quit),

	awful.key({ modkey,		   }, "l",	 function () awful.tag.incmwfact( 0.05)	end),
	awful.key({ modkey,		   }, "h",	 function () awful.tag.incmwfact(-0.05)	end),
	awful.key({ modkey, "Shift"   }, "h",	 function () awful.tag.incnmaster( 1)	  end),
	awful.key({ modkey, "Shift"   }, "l",	 function () awful.tag.incnmaster(-1)	  end),
	awful.key({ modkey, "Control" }, "h",	 function () awful.tag.incncol( 1)		 end),
	awful.key({ modkey, "Control" }, "l",	 function () awful.tag.incncol(-1)		 end),
	awful.key({ modkey,		   }, "BackSpace", nextlayout),
	awful.key({ modkey, "Shift"   }, "BackSpace", prevlayout),

	-- Prompts
  awful.key({ modkey }, "Return", config.prompts.default),
  awful.key({ modkey }, "r", config.prompts.default),
	awful.key({ modkey, "Mod1" }, "Return", config.prompts.capture_output),
	awful.key({ modkey }, "x", config.prompts.lua),
	awful.key({ modkey }, "s", config.prompts.ssh)
)


-- tag key shortcuts
-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(9, math.max(#tags[s], keynumber));
end

for i = 1, keynumber do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, i,
                  function ()
                        local screen = mouse.screen
                        if tags[screen][i] then
                            awful.tag.viewonly(tags[screen][i])
                        end
                  end),
        awful.key({ modkey, "Control" }, i,
                  function ()
                      local screen = mouse.screen
                      if tags[screen][i] then
                          tags[screen][i].selected = not tags[screen][i].selected
                      end
                  end),
        awful.key({ modkey, "Shift" }, i,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.movetotag(tags[client.focus.screen][i])
                      end
                  end),
        awful.key({ modkey, "Control", "Shift" }, i,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.toggletag(tags[client.focus.screen][i])
                      end
                  end))
end

-- Set keys
root.keys(globalkeys)
-- }}}

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Per client keybindings
clientkeys = awful.util.table.join(
	awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
 	awful.key({ modkey,           }, "q",      function (c) c:kill()                         end),
 	awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
-- 	awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
 	awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
	awful.key({ modkey, "Shift"   }, "r",      function (c) c:redraw() end)
)

require("dyno")

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.add_signal("manage", dyno.manage)

client.add_signal("property::name", dyno.property)

client.add_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.add_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}
