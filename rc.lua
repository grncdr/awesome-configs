-- Standard awesome library
require("awful")
-- Theme handling library
require("beautiful")
-- Notification library
require("naughty")
require("colour")

require("obvious")

dofile(awful.util.getdir('config') .. '/config.lua')

-- A couple of utility functions
function nextlayout() 
	awful.layout.inc(config.tags[awful.tag.getproperty(awful.tag.selected(), 'index')].layouts, 1)
end

function prevlayout() 
	awful.layout.inc(config.tags[awful.tag.getproperty(awful.tag.selected(), 'index')].layouts, -1)
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
	for s = 1, screen.count() do
			tags[s] = { }
			for i, v in ipairs(config.tags) do
					tags[s][i] = tag(v.name)
					tags[s][i].screen = s
					awful.tag.setproperty(tags[s][i], 'index', i)
					awful.tag.setproperty(tags[s][i], "layout", v.layouts[1])
--					awful.tag.setproperty(tags[s][i], "mwfact", v.mwfact)
--					awful.tag.setproperty(tags[s][i], "nmaster", v.nmaster)
--					awful.tag.setproperty(tags[s][i], "ncols", v.ncols)
--					awful.tag.setproperty(tags[s][i], "icon", v.icon)
			end
			tags[s][1].selected = true
	end
end
-- }}}

-- {{{ Wibox

-- Create a laucher widget and a main menu
myawesomemenu = {
   { "manual", config.terminal .. " -e man awesome" },
   { "edit rc", config.editor .. " " .. awful.util.getdir("config") .. "/rc.lua" },
   { "edit theme", config.editor .. " " .. awful.util.getdir("config") .. "/themes/current/theme.lua" },
   { "restart", awesome.restart },
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
					awful.button({ config.modkey }, 3, awful.client.toggletag),
					awful.button({ }, 4, awful.tag.viewnext),
					awful.button({ }, 5, awful.tag.viewprev)
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
	awful.key({ config.modkey,		   }, "Left",   awful.tag.viewprev	   ),
	awful.key({ config.modkey,		   }, "Right",  awful.tag.viewnext	   ),
	awful.key({ config.modkey,		   }, "Escape", awful.tag.history.restore),

	awful.key({ config.modkey,		   }, "j",
		function ()
			awful.client.focus.byidx( 1)
			if client.focus then client.focus:raise() end
		end),
	awful.key({ config.modkey,		   }, "k",
		function ()
			awful.client.focus.byidx(-1)
			if client.focus then client.focus:raise() end
		end),
	awful.key({ config.modkey,		   }, "w", function () mymainmenu:show(true)		end),

		-- Quicklaunch apps
	awful.key({ config.modkey,		   }, "n", function () awful.util.spawn(config.terminal .. " -e wicd-curses") end ),
	awful.key({ config.modkey,		   }, "m", function () awful.util.spawn(config.terminal .. " -e alsamixer") end ),

	-- Layout manipulation
	awful.key({ config.modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1) end),
	awful.key({ config.modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1) end),
	awful.key({ config.modkey, "Control" }, "j", function () awful.screen.focus( 1)	   end),
	awful.key({ config.modkey, "Control" }, "k", function () awful.screen.focus(-1)	   end),
	awful.key({ config.modkey,		   }, "u", awful.client.urgent.jumpto),
	awful.key({ config.modkey,		   }, "Tab",
		function ()
			awful.client.focus.history.previous()
			if client.focus then
				client.focus:raise()
			end
		end),

	-- Standard program
	awful.key({ config.modkey, "Control" }, "Return", function () awful.util.spawn(config.terminal) end),
	awful.key({ config.modkey, "Control" }, "r", awesome.restart),
	awful.key({ config.modkey, "Shift", "Control" }, "q", awesome.quit),

	awful.key({ config.modkey,		   }, "l",	 function () awful.tag.incmwfact( 0.05)	end),
	awful.key({ config.modkey,		   }, "h",	 function () awful.tag.incmwfact(-0.05)	end),
	awful.key({ config.modkey, "Shift"   }, "h",	 function () awful.tag.incnmaster( 1)	  end),
	awful.key({ config.modkey, "Shift"   }, "l",	 function () awful.tag.incnmaster(-1)	  end),
	awful.key({ config.modkey, "Control" }, "h",	 function () awful.tag.incncol( 1)		 end),
	awful.key({ config.modkey, "Control" }, "l",	 function () awful.tag.incncol(-1)		 end),
	awful.key({ config.modkey,		   }, "BackSpace", nextlayout),
	awful.key({ config.modkey, "Shift"   }, "BackSpace", prevlayout),

	-- Prompts
  awful.key({ config.modkey }, "Return", config.prompts.default),
  awful.key({ config.modkey }, "r", config.prompts.default),
	awful.key({ config.modkey, "Mod1" }, "Return", config.prompts.capture_output),
	awful.key({ config.modkey }, "x", config.prompts.lua),
	awful.key({ config.modkey }, "s", config.prompts.ssh)
)

-- Per client keybindings
clientkeys = awful.util.table.join(
	awful.key({ config.modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
 	awful.key({ config.modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
 	awful.key({ config.modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
-- 	awful.key({ config.modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
 	awful.key({ config.modkey,           }, "o",      awful.client.movetoscreen                        ),
	awful.key({ config.modkey, "Shift"   }, "r",      function (c) c:redraw() end)
)

-- tag key shortcuts
for i = 1, math.min(10,#tags[1]) do
	globalkeys = awful.util.table.join(globalkeys,
		awful.key({ config.modkey }, i % 10,
				  function ()
						local screen = mouse.screen
						if tags[screen][i] then
							awful.tag.viewonly(tags[screen][i])
						end
				  end),
		awful.key({ config.modkey, "Control" }, i % 10,
				  function ()
					  local screen = mouse.screen
					  if tags[screen][i] then
						  tags[screen][i].selected = not tags[screen][i].selected
					  end
				  end),
		awful.key({ config.modkey, "Shift" }, "F" .. i ,
				  function ()
					  if client.focus and tags[client.focus.screen][i] then
						  awful.client.movetotag(tags[client.focus.screen][i])
					  end
				  end),
		awful.key({ config.modkey, "Control", "Shift" }, i % 10,
				  function ()
					  if client.focus and tags[client.focus.screen][i] then
						  awful.client.toggletag(tags[client.focus.screen][i])
					  end
				  end),
		awful.key({ config.modkey, "Shift" }, "F" .. i % 10,
				  function ()
					  local screen = mouse.screen
					  if tags[screen][i] then
						  for k, c in pairs(awful.client.getmarked()) do
							  awful.client.movetotag(tags[screen][i], c)
						  end
					  end
				   end))
end

-- Set keys
root.keys = globalkeys
-- }}}

-- {{{ Hooks
-- Hook function to execute when focusing a client.
awful.hooks.focus.register(function (c)
	if not awful.client.ismarked(c) then
		c.border_color = beautiful.border_focus
	end
end)

-- Hook function to execute when unfocusing a client.
awful.hooks.unfocus.register(function (c)
	if not awful.client.ismarked(c) then
		c.border_color = beautiful.border_normal
	end
end)

-- Hook function to execute when marking a client
awful.hooks.marked.register(function (c)
	c.border_color = beautiful.border_marked
end)

-- Hook function to execute when unmarking a client.
awful.hooks.unmarked.register(function (c)
	c.border_color = beautiful.border_focus
end)

-- Hook function to execute when the mouse enters a client.
awful.hooks.mouse_enter.register(function (c)
	-- Sloppy focus, but disabled for magnifier layout
	if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
		and awful.client.focus.filter(c) then
		client.focus = c
	end
end)

function retag_client(c)
	local instance = c.instance and c.instance:lower() or ""
	local class = c.class and c.class:lower() or ""
	local name = c.name and c.name:lower() or ""

	local settings = {}

	for k, v in pairs(config.apps) do
		for j, m in pairs(v.match) do
			if name:match(m) or instance:match(m) or class:match(m) then
				if v.tags then
					if not settings.tags then settings.tags = v.tags break end
					--If we have tags and this is only a fallback tag, skip it
					if v.fallback then break end 
					settings.tags = awful.util.table.join(settings.tags, v.tags)
				end
				if v.float ~= nil then
					settings.float = v.float
				end
			end
		end
	end

	if not settings.tags then
		-- Here we will handle clients that don't have a pre-defined tag.
		-- Possibility 1 > client is assigned a catch-all tag
		-- Possibility 2 > client is assigned a dynamic tag based on class/instance
		naughty.notify({text = 'no tags defined for ' .. tostring(c), screen = mouse.screen})
	end
	if settings == {} then return end

	if settings.slave then
		awful.client.setslave(c)
	end
	if settings.size_hints_honor ~= nil then
		c.size_hints_honor = settings.size_hints_honor
	end
	-- Is/are tag(s) defined for this client?
	if settings.tags then
		newtags = {}
		if type(settings.tags) ~= 'table' then
			settings.tags = { settings.tags }
		end
		c:tags({}) -- empty the taglist for the client
		local switch = true
		for i, t in pairs(settings.tags) do
			newtags[#newtags + 1] = tags[c.screen][t]
			for k, v in pairs(awful.tag.selectedlist()) do 
				if v == tags[c.screen][t] then switch = false break end
			end
		end
		c:tags(newtags)
		-- check if we are already viewing the appropiate tag and switch to it if not
		if switch then awful.tag.viewmore(newtags, c.screen) end
	end

	if settings.float ~= nil then
		awful.client.floating.set(c, settings.float)
		c:raise()
	end
end

-- Hook function to execute when a new client appears.
awful.hooks.manage.register( function (c, startup)
	if not startup and awful.client.focus.filter(c) then
		c.screen = mouse.screen
	end	
		c.maximized_horizontal = false
		c.maximized_vertical = false
	c.buttons = awful.util.table.join(
		awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
		awful.button({ config.modkey }, 1, awful.mouse.client.move),
		awful.button({ config.modkey }, 3, awful.mouse.client.resize)
	)
	c.border_width = beautiful.border_width
	c.border_color = beautiful.border_normal

	-- Set key bindings
	c.keys = clientkeys

	retag_client(c)
	client.focus = c
	awful.hooks.user.call("focus", c)

end)

-- Unmanage
awful.hooks.unmanage.register(function (c)
	if c.titlebar ~= nil then
		awful.titlebar.remove(c)
	end
	if not client.focus or not client.focus:isvisible() then
		local c = awful.client.focus.history.get(c.screen, 0)
		if c then client.focus = c end
	end
end)

-- Hook function to execute when switching tag selection.
awful.hooks.tags.register(function (screen, tag, view)
  -- Give focus to the latest client in history if no window has focus
  -- or if the current window is a desktop or a dock one.
	 if not client.focus or not client.focus:isvisible() then
		 local c = awful.client.focus.history.get(screen, 0)
		 if c then client.focus = c end
	 end
end)

awful.hooks.property.register(function (c, prop)
	local instance = c.instance and c.instance:lower() or ""
	local class = c.class and c.class:lower() or ""
	local name = c.name and c.name:lower() or ""
	if prop == 'name' and ( config.terminal:match(class) or config.terminal:match(instance) ) and name ~= config.lastname then
		config.lastname = name
		retag_client( c )
		client.focus = c
		awful.hooks.user.call("focus", c)
	end

	-- Titlebar management
  if c.fullscreen then
		awful.titlebar.remove(c)
  elseif not c.fullscreen then
		if c.titlebar == nil and awful.client.floating.get(c) then
			 awful.titlebar.add(c, { modkey = config.modkey })
		elseif c.titlebar and not awful.client.floating.get(c) then
			 awful.titlebar.remove(c)
		end
  end
end)
