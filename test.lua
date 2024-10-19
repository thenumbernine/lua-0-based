#!/usr/bin/env lua
require 'ext'
local ztable = require '0-based'
local t = ztable()
assert.eq(#t, 0)
ztable.insert(t, 'a')
assert.eq(#t, 1)
assert.eq(t[0], 'a')
assert.eq(t[1], nil)
ztable.insert(t, 'b')
assert.eq(#t, 2)
assert.eq(t[0], 'a')
assert.eq(t[1], 'b')
assert.eq(t[2], nil)
ztable.insert(t, 'c')
assert.eq(#t, 3)
assert.eq(t[0], 'a')
assert.eq(t[1], 'b')
assert.eq(t[2], 'c')
assert.eq(t[3], nil)
assert.eq(t:concat',', 'a,b,c')
t = ztable{'c', 'b', 'a'} -- still isn't builtin to language table initialization syntax
--assert.eq(t:concat',', 'nil,c,b,a') -- won't produce c,b,a because [0] isn't initialized
t = ztable{[0]='c', 'b', 'a'} -- still isn't builtin to language table initialization syntax
assert.eq(#t, 3)
assert.eq(t[0], 'c')
assert.eq(t[1], 'b')
assert.eq(t[2], 'a')
assert.eq(t[3], nil)
t:sort(function(a,b)
	print('cmp', a, b)
	return a < b
end) -- will error maybe because __len==3, so default table.sort thinks [3] exists when it doesn't
assert.eq(#t, 3)
assert.eq(t[0], 'a')
assert.eq(t[1], 'b')
assert.eq(t[2], 'c')
assert.eq(t[3], nil)
