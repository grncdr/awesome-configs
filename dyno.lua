local clientkeys = clientkeys
local client = client
local mouse = mouse
local pairs = pairs
local ipairs = ipairs
local type = type
local table = table
local screen = screen
local tags = tags
local tag = tag
local layouts = config.layouts
local awful = awful
local rules = awful.rules.rules
local match = awful.rules.match
local naughty = require('naughty')
local beautiful = require('beautiful')
module('dyno')

-- This can be a tag name (string) or tag object or false for auto-generated tag names
fallback = false

function retag(c)
	local s = c.screen

	local tags = tags[s]
	local newtags = {}
	local selected = {}
	-- check awful.rules.rules to see if anything matches
	for _, r in ipairs(rules) do
		if r.properties.tagname and match(c, r.rule) then
			newtags[#newtags + 1] = r.properties.tagname
			if r.properties.switchtotag then
				selected[#selected + 1] = r.properties.tagname
			end
		end
	end

	-- if no tagnames specified
	if #newtags == 0 then
		if fallback then
			if type(fallback) == 'string' then
				newtags = { fallback }
			elseif type(fallback) == 'tag' then
				newtags = { fallback }
			end
		else
			newtags = { c.class:lower() }
		end
	end

	for i, name in ipairs(newtags) do
		for _, t in ipairs(tags) do
			if t.name == name then
				newtags[i] = t
				break
			end
		end
		if type(newtags[i]) == 'string' then
			newtags[i] = maketag( name, s )
		end
		if selected[name] ~= nil then newtags[i].selected = true end
	end
	c:tags(newtags)
	if not awful.tag.selected() then tags[1].selected = true end
end

function maketag( name, s )
	local tags = tags[s]
	local t =  tag({ name = name })
	t.screen = s
	tags[#tags + 1] = t
	if layouts[name] ~= nil then
		awful.layout.set(layouts[name][1], tags[#tags])
	elseif layouts['default'] ~= nil then
		awful.layout.set(layouts['default'][1], t)
	else
		awful.layout.set(layouts[1], t)
	end
end

client.add_signal("manage", retag)
-- client.add_signal("property::name", retag)

function cleanup(c)
	local tags = tags[c.screen]
	for i, t in ipairs(tags) do
		del(tags[i], i)
	end
end

client.add_signal("unmanage", cleanup)

--{{{ del : delete a tag. Taken directly from the shifty sources
--@param tag : the tag to be deleted [current tag]
function del(tag, idx)
  local scr = (tag and tag.screen) or mouse.screen or 1
  local tags = screen[scr]:tags()
  local sel = awful.tag.selected(scr)
  local t = tag or sel

  -- return if tag not empty (except sticky)
  local clients = t:clients()
  local sticky = 0
  for i, c in ipairs(clients) do
    if c.sticky then sticky = sticky + 1 end
  end
  if #clients > sticky then return end

  -- remove tag
  t.screen = nil

  -- if the current tag is being deleted, restore from history
  if t == sel and #tags > 1 then
    awful.tag.history.restore(scr)
    -- this is supposed to cycle if history is invalid?
    -- e.g. if many tags are deleted in a row
    if not awful.tag.selected(scr) then
      awful.tag.viewonly(tags[awful.util.cycle(#tags, idx - 1)])
    end
  end

  -- FIXME: what is this for??
  -- if client.focus then client.focus:raise() end
end
--}}}

