#!/usr/bin/env lua

-- everything must be global
local function run(s)
	print('>'..s)
	print(assert(load(s))())
end

local function runall(s)
	for i,l in ipairs(require 'ext.string'.split(s, '\n')) do
		run(l)
	end
end

table = require '0-based'

runall[[
t = table()
print(#t)
table.insert(t, 'a')
print(#t)
print(t[0])
print(t[1])
table.insert(t, 'b')
table.insert(t, 'c')
for i,v in ipairs(t) do print(i,v) end
]]
