---------------------------------------------------------------------------
-- @author Julien Danjou &lt;julien@danjou.info&gt;
-- @copyright 2009 Julien Danjou
-- @release @AWESOME_VERSION@
---------------------------------------------------------------------------

-- Grab environment we need
local client = client
local type = type
local ipairs = ipairs
local pairs = pairs
local aclient = require("awful.client")
local atag = require("awful.tag")

--- Apply rules to clients at startup.
module("awful.rules")

--- This is the global rules table.
-- <p>You should fill this table with your rule and properties to apply.
-- For example, if you want to set xterm maximized at startup, you can add:
-- <br/>
-- <code>
-- { rule = { class = "xterm" },
--   properties = { maximized_vertical = true, maximized_horizontal = true } }
-- </code>
-- </p>
-- <p>If you want to set mplayer floating at startup, you can add:
-- <br/>
-- <code>
-- { rule = { name = "MPlayer" },
--   properties = { floating = true } }
-- </code>
-- </p>
-- <p>If you want to put Firefox on a specific tag at startup, you
-- can add:
-- <br/>
-- <code>
-- { rule = { instance = "firefox" }
--   properties = { tag = mytagobject } }
-- </code>
-- </p>
-- <p>If you want to put Emacs on a specific tag at startup, and
-- immediately switch to that tag you can add:
-- <br/>
-- <code>
-- { rule = { class = "Emacs" }
--   properties = { tag = mytagobject, switchtotag = true } }
-- </code>
-- </p>
-- <p>Rules can also specify either the field or value as a table with a list of
-- entries:
-- <br/>
-- <code>
-- { rule = { {'class','name','instance'} = 'Firefox' },
--   properties = { tag = tags[1][2] } }
-- </code>
-- <br/>or:
-- <code>
-- { rule = { class = {'urxvt', 'xterm', 'terminal' }, name = 'ssh' },
--   properties = { tag = tags[2][2], switchtotag = true } }
-- </code>
-- <br/>or even:
-- <code>
-- { rule = { {'class', 'name', 'instance'} = {'xterm', 'terminal', 'urxvt'} },
--   properties = { tag = tags[2][2], switchtotag = true } }
-- </code>
-- <p>Note that all first-level "rule" entries (such as class = 'class') need to 
-- match. If any of the entry does not match, the rule won't be applied.
-- However, when using tables as keys or values, only <i>one</i> of the possible
-- combinations of rules needs to match for the rule to be applied. </p>
-- <p>If a client matches multiple rules, they're applied in the order they are
-- put in this global rules table. If the value of a rule is a string, then the
-- match function is used to determine if the client matches the rule.</p>
--
-- @class table
-- @name rules
rules = {}

--- Check if a client match a rule.
-- @param c The client.
-- @param rule The rule to check.
-- @return True if it matches, false otherwise.
function match(c, rule)
    for field, value in pairs(rule) do
        if type(field) == "table" then
            for _, f in ipairs(field) do
                if match(c, {[f] = value}) then
                    return true
                end
            end
        end
        if type(value) == "table" do
            for _, v in ipairs(value) do
                if match(c, {[field] = v}) then
                    return true
                end
            end
        end
        if c[field] then
            if type(c[field]) == "string" then
                if not c[field]:match(value) and c[field] ~= value then
                    return false
                end
            elseif c[field] ~= value then
                return false
            end
        end
    end
    return true
end

--- Apply rules to a client.
-- @param c The client.
function apply(c)
    for _, entry in ipairs(rules) do
        if match(c, entry.rule) then
            for property, value in pairs(entry.properties) do
                if property == "floating" then
                    aclient.floating.set(c, value)
                elseif property == "tag" then
                    aclient.movetotag(value, c)
                elseif property == "switchtotag" and value
                    and entry.properties["tag"] then
                    atag.viewonly(entry.properties["tag"])
                elseif type(c[property]) == "function" then
                    c[property](c, value)
                else
                    c[property] = value
                end
            end
            -- Do this at last so we do not erase things done by the focus
            -- signal.
            if entry.properties.focus then
                client.focus = c
            end
        end
    end
end

client.add_signal("manage", apply)

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:encoding=utf-8:textwidth=80
