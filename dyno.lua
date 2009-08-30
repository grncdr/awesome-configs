local apptable = config.apps
local terminal = config.terminal
local clientkeys = clientkeys
local pairs = pairs
local type = type
local tags = tags
local tag = tag

local awful = require('awful')
local naughty = require('naughty')
local beautiful = require('beautiful')
module('dyno')

function retag(c)
	local instance = c.instance and c.instance:lower() or ""
	local class = c.class and c.class:lower() or ""
	local name = c.name and c.name:lower() or ""

	local settings = {}

	for k, v in pairs(apptable) do
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

-- {{{ Signals
-- Signal function to execute when a new client appears.
function manage(c, startup)
	if not startup and awful.client.focus.filter(c) then
		c.screen = mouse.screen
	end	
		c.maximized_horizontal = false
		c.maximized_vertical = false
	c.buttons = awful.util.table.join(
		awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
		awful.button({ modkey }, 1, awful.mouse.client.move),
		awful.button({ modkey }, 3, awful.mouse.client.resize)
	)
	c.border_width = beautiful.border_width
	c.border_color = beautiful.border_normal

	-- Set key bindings
	c:keys(clientkeys)
	c:add_signal("mouse::enter", function(c)
		if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
		and awful.client.focus.filter(c) then
			client.focus = c
		end
	end)

	retag_client(c)
end

function manage(c, startup)
	if not startup and awful.client.focus.filter(c) then
		c.screen = mouse.screen
	end	
		c.maximized_horizontal = false
		c.maximized_vertical = false
	c.buttons = awful.util.table.join(
		awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
		awful.button({ modkey }, 1, awful.mouse.client.move),
		awful.button({ modkey }, 3, awful.mouse.client.resize)
	)
	c.border_width = beautiful.border_width
	c.border_color = beautiful.border_normal

	-- Set key bindings
	c:keys(clientkeys)
	c:add_signal("mouse::enter", function(c)
		if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
		and awful.client.focus.filter(c) then
			client.focus = c
		end
	end)
	retag(c)
end

function property(c, prop)
	local instance = c.instance and c.instance:lower() or ""
	local class = c.class and c.class:lower() or ""
	local name = c.name and c.name:lower() or ""
	if prop == 'name' and ( terminal:match(class) or terminal:match(instance) ) and name ~= lastname then
		lastname = name
		retag( c )
		client.focus = c
--		awful.hooks.user.call("focus", c)
	end

	-- Titlebar management
  if c.fullscreen then
		awful.titlebar.remove(c)
  elseif not c.fullscreen then
		if c.titlebar == nil and awful.client.floating.get(c) then
			 awful.titlebar.add(c, { modkey = modkey })
		elseif c.titlebar and not awful.client.floating.get(c) then
			 awful.titlebar.remove(c)
		end
  end
end
