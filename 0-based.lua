-- what does this do?
-- it replaces table.insert, table.remove, and ipairs to be 0-based instead of 1-based
local table = require 'ext.table'

local super = table

local zerotable = {}
for k,v in pairs(table) do
	zerotable[k] = v
end

zerotable.__index = zerotable 

function zerotable.new(...)
	return setmetatable(super.new(...), zerotable)
end

-- zerotable() creates a new table
setmetatable(zerotable, {
	__call = function(t, ...)
		return zerotable.new(...)
	end,
})

-- returning the length of a 0-bsed table
function zerotable.__len(t)
	local l = rawlen(t)
	if l == 0 then
		if type(t[0]) == 'nil' then
			return 0
		end
	end
	return l+1
end

local function getargoftype(reqtype, i, ...)
	local n = select('#', ...)
	local t = select(i, ...)
	if type(t) ~= reqtype then
		local ttype = i > n and 'no value' or type(t)
		error("bad argument #1 to 'insert' ("..reqtype.." expected, got "..ttype..")")
	end
	return t
end

--[[
	table.insert(t, v) = inserts v at the end of t (0-based)
	table.insert(t, i, v) = inserts v at index i in t, pushing all elements up one (0-based)
--]]
function zerotable.insert(...)
	local t = getargoftype('table', 1, ...)
	local l = zerotable.__len(t)
	local n = select('#', ...)
	if n == 2 then
		local v = select(2, ...)
		t[l] =  v
	elseif n == 3 then
		local i, v = select(2, ...)
		for j=l,i,-1 do
			t[j+1] = t[j]
		end
		t[i] = v
	else
		error("wrong number of arguments to 'insert'")
	end
end

function zerotable.remove(...)
	local t = getargoftype('table', 1, ...)
	local l = zerotable.__len(t)
	local n = select('#', ...)
	local o
	if n == 1 then
		if l > 0 then
			o = t[l-1]
			t[l-1] = nil
		end
	else
		local i = getargoftype('number', 2, ...)
		if l > 0 then
			o = t[i]
			for j=i,l-1 do
				t[j] = t[j+1]
			end
			t[l] = nil
		end
	end
	return o
end

-- metatable.__ipairs is deprecated in 5.3, but the 5.3.3 ubuntu apt bundle is built with backwards compatability for 5.2 so it still exists
-- TODO 5.2 ipairs compat test here?
local oldipairs = ipairs
function ipairs(t)
	local mt = getmetatable(t)
	if mt then
		local mipairs = mt.__ipairs
		if mipairs then
			return mipairs(t)
		end
	end
	return oldipairs(t)
end

function zerotable.__ipairs(t)
	return function(t, i)
		i = i + 1
		local v = t[i]
		if v == nil then return end
		return i, v
	end, t, -1
end

return zerotable
