local clientkeys = clientkeys
local client = client
local mouse = mouse
local pairs = pairs
local ipairs = ipairs
local type = type
local tags = tags
local tag = tag
local layouts = config.layouts
local awful = awful
local rules = awful.rules.rules
local match = awful.rules.match
local naughty = require('naughty')
local beautiful = require('beautiful')
module('dyno')

fallback = 'misc'

function retag(c)
	local s = c.screen

	local names = {}
	local switch = {}
	-- check awful.rules.rules to see if anything matches
	for _, r in ipairs(rules) do
		if r.properties.tagname and match(c, r.rule) then
			names[#names + 1] = r.properties.tagname
			if r.properties.switchtotag then
				switch[#switch + 1] = r.properties.tagname
			end
		end
	end

	local tagtable = {}
	local selected = {}
	
	-- if no tagnames specified
	if #names == 0 then
		if fallback then
			if type(fallback) == 'string' then
				names = { fallback }
			elseif type(fallback) == 'tag' then
				tagtable = { fallback }
			end
		else
			names = { c.class:lower() }
		end
	end

	for _, name in ipairs(names) do
		local size = #tagtable
		for i, t in ipairs(tags[s]) do
			if t.name == name then
				if switch[name] ~= nil then selected[#selected+1] = t end
				tagtable[#tagtable + 1] = t
				break
			end
		end
		if #tagtable == size then
			maketag( name, s )
		end
	end
	c:tags(tagtable)
	for _, t in ipairs(selected) do
		t.selected = true
	end
end

function setlayout()
	if layouts[name] ~= nil then
		awful.layout.set(layouts[name][1])
	elseif layouts['default'] ~= nil then
		awful.layout.set(layouts.default[1])
	else
		awful.layout.set(layouts[1])
	end
end

function maketag( name, s )
	tags[s][#tags[s] + 1] = tag({ name = name })
	tags[s][#tags[s]].screen = s
	setlayout()
	tagtable[#tagtable + 1] = tags[s][#tags[s]]
end

client.add_signal("manage", retag)
-- client.add_signal("property::name", retag)

function cleanup(c)
	local s = c.screen
	for _, v in ipairs(c:tags()) do
		if not v:clients() then
			for i, t in ipairs(tags[s]) do
				if t == v then
					table.remove(tags[s], i)
				end
			end
		end
	end
end

client.add_signal("unmanage", cleanup)

awful.tag.attached_add_signal(nil, "property::selected", function()
	if awful.layout.get() == awful.layout.suit.floating then
		awful.layout.set(layouts[awful.tag.selected().name][1])
	end
end)
