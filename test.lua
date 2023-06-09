#!/usr/bin/env lua

-- everything must be global
local function run(s)
	print('>'..s)
	xpcall(function()
		print(load(s)())
	end, function(err)
		print(err..'\n'..debug.traceback()..'\n')
	end)
end

local function runall(s)
	for i,l in ipairs(require 'ext.string'.split(s, '\n')) do
		run(l)
	end
end

ztable = require '0-based'

runall[[
t = ztable()
print(#t)
ztable.insert(t, 'a')
print(#t)
print(t[0])
print(t[1])
ztable.insert(t, 'b')
ztable.insert(t, 'c')
for i,v in ipairs(t) do print(i,v) end
print(t:concat',')
t = ztable{'c', 'b', 'a'} -- still isn't builtin to language table initialization syntax
print(t:concat',') -- will fail
t = ztable{[0]='c', 'b', 'a'} -- still isn't builtin to language table initialization syntax
print(t[0], t[1], t[2])
t:sort() -- will error maybe because __len==3, so default table.sort thinks [3] exists when it doesn't
print(t[0], t[1], t[2])
]]
