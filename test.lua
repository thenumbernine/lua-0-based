#!/usr/bin/env lua
require 'ext'
local ztable = require '0-based'
local t = ztable()
asserteq(#t, 0)
ztable.insert(t, 'a')
asserteq(#t, 1)
asserteq(t[0], 'a')
asserteq(t[1], nil)
ztable.insert(t, 'b')
asserteq(#t, 2)
asserteq(t[0], 'a')
asserteq(t[1], 'b')
asserteq(t[2], nil)
ztable.insert(t, 'c')
asserteq(#t, 3)
asserteq(t[0], 'a')
asserteq(t[1], 'b')
asserteq(t[2], 'c')
asserteq(t[3], nil)
asserteq(t:concat',', 'a,b,c')
t = ztable{'c', 'b', 'a'} -- still isn't builtin to language table initialization syntax
--asserteq(t:concat',', 'nil,c,b,a') -- won't produce c,b,a because [0] isn't initialized
t = ztable{[0]='c', 'b', 'a'} -- still isn't builtin to language table initialization syntax
asserteq(#t, 3)
asserteq(t[0], 'c')
asserteq(t[1], 'b')
asserteq(t[2], 'a')
asserteq(t[3], nil)
t:sort(function(a,b)
	print('cmp', a, b)
	return a < b
end) -- will error maybe because __len==3, so default table.sort thinks [3] exists when it doesn't
asserteq(#t, 3)
asserteq(t[0], 'a')
asserteq(t[1], 'b')
asserteq(t[2], 'c')
asserteq(t[3], nil)
