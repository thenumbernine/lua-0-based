-- what does this do?
-- it replaces .insert, .remove, and ipairs to be 0-based instead of 1-based

local table = require 'ext.table'

-- syntax to match luaL_argerror:
local function getargoftype(reqtype, i, ...)
	local n = select('#', ...)
	local t = select(i, ...)
	if type(t) ~= reqtype then
		local ttype = i > n and 'no value' or type(t)
		error("bad argument #1 to 'insert' ("..reqtype.." expected, got "..ttype..")")
	end
	return t
end

local ztable = {}
for k,v in pairs(table) do
	ztable[k] = v
end

ztable.__index = ztable 

function ztable.new(...)
	return setmetatable(table.new(...), ztable)
end

-- ztable() creates a new table
setmetatable(ztable, {
	__call = function(t, ...)
		return ztable.new(...)
	end,
})

-- returning the length of a 0-bsed table
function ztable.__len(t)
	local l = rawlen(t)
	if l == 0 and t[0] == nil then
		return 0
	end
	return l+1
end

--[[
.insert(t, v) = inserts v at the end of t (0-based)
.insert(t, i, v) = inserts v at index i in t, pushing all elements up one (0-based)
--]]
function ztable.insert(...)
	local t = getargoftype('table', 1, ...)
	local l = ztable.__len(t)
	local n = select('#', ...)
	if n == 2 then
		local v = select(2, ...)
		t[l] =  v
	elseif n == 3 then
		local i, v = select(2, ...)
		--[[
		for j=l,i,-1 do
			t[j+1] = t[j]
		end
		--]]
		-- [[
		table.move(t, i, l, i+1)
		--]]
		t[i] = v
	else
		error("wrong number of arguments to 'insert'")
	end
end

function ztable.remove(...)
	local t = getargoftype('table', 1, ...)
	local l = ztable.__len(t)
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
			--[[
			for j=i,l-1 do
				t[j] = t[j+1]
			end
			--]]
			-- [[
			table.move(t, i+1, l, i)
			--]]
			t[l] = nil
		end
	end
	return o
end

-- .concat(table, separator, start_inclusive, end_exclusive)
function ztable.concat(...)
	local t,sep,i,j = ...
	local n = select('#', ...)
	if n < 4 then j = #t end
	if n < 3 then i = 0 end
	if not sep then sep = '' end
	local s = ''
	local _sep = ''
	for k=i,j-1 do
		s = s .. _sep .. t[k]
		_sep = sep
	end
	return s
end

-- TODO table.pack table.sort table.unpack
-- but how should unpack's indexes work?  0-based or 1-based, and if 0-based then what about select() or table.unpack() compatability?
function ztable.sort(t, ...)
	local n = ztable.__len(t)
	if n == 0 then return t end
	--[[ if i do this then i'm sorting {'a','b'} but internal sort still picks out a nill value somehow and crashes ...
print(require 'ext.tolua'(t))
	local minv, mini = ztable.inf(t)
print(require 'ext.tolua'{mini=mini, minv=minv})
	t[mini] = t[0]
print(require 'ext.tolua'(t))
	t[0] = nil
print(require 'ext.tolua'(t))
	table.sort(t, ...)
print(require 'ext.tolua'(t))
	t[0] = minv
	return t
	--]]
	-- [[
	return table.sort(t, ...)	-- ... this too... does table.sort use ipairs or something? half the time?
	--]]
end

-- reintroduces the old __ipairs functionality
-- works with the ipairs() override below:
function ztable.__ipairs(t)
	return function(t, i)
		i = i + 1
		local v = t[i]
		if v == nil then return end
		return i, v
	end, t, -1
end

-- global environment changes:

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

-- [[ modify original table.insert and table.remove to call custom insert and remove if exists?
for _,field in ipairs{'insert', 'remove'} do
	local old = table[field]
	local function new(...)
		local t = ...
		local f = t[field]
		if f and f ~= new then
			return f(...)
		else
			return old(...)
		end
	end
	table[field] = new
end
--]]

return ztable
