local terminal = config.terminal
local clientkeys = clientkeys
local pairs = pairs
local type = type
local tags = tags
local tag = tag

local awful = require('awful')
local awful.rules = require('awful.rules')
local naughty = require('naughty')
local beautiful = require('beautiful')
module('dyno')

awful.rules.rules = {
	{ rule = { class = "urxvt" }, tagname = 'term' },
	{ rule = { class = "urxvt", name = "ssh" }, tagname = 'ssh' },
	{ rule = { class = "shiretoko" }, tagname = 'web' },
	{ rule = { class = "evince" }, tagname = 'term' } },
	{ rule = { class = "vim" }, tagname = 'code' },
	{ rule = { class = "qalculate" }, float = true },
	{ rule = { name = "wicd%-curses"}, tagname = 'sys' }
	{ rule = { name = "alsamixer" }, tagname = 'sys' },
}

function taglist(c)
	local s = mouse.screen
	local tagnames = {}

	-- check awful.rules.rules to see if anything matches
	for _, entry in ipairs(awful.rules.rules) do
		-- if we have a match and it has a tags table:
		if awful.rules.match(c, entry.rule) and entry.tagname then
			-- set the client tagnames to the newly compiled tags
			table.insert(tagnames, entry.tagname)
		end
	end

	-- if no tagnames specified
	if tagnames == {} then
		if fallback then
			-- TODO implement this
			naughty.notify({text = "Fallback tag not implemented yet"})
		else
			table.insert(tagnames, c:class:lower())
		end
	end

	local ctags = {}
	for _, name in ipairs(tagnames) do
		local size = #ctags
		for i, t in ipairs(tags[s]) do
			if t.name == name then
				table.insert(ctags, t)
				break
			end
		end
		if #ctags == size then
			table.insert(tags[s], tag(name))
			table.insert(ctags, tags[s][#tags[s]])
	end
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
	c:tags(taglist(c))
end

function property(c, prop)
	local instance = c.instance and c.instance:lower() or ""
	local class = c.class and c.class:lower() or ""
	local name = c.name and c.name:lower() or ""
	if prop == 'name' and ( terminal:match(class) or terminal:match(instance) ) and name ~= lastname then
		lastname = name
		c:tags(taglist(c))
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
