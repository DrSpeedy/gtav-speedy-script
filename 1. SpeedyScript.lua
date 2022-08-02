-- Discord: DrSpeedy#1852
-- https://github.com/DrSpeedy
require 'lib/natives-1627063482'

menuIdTbl = {}
keys = {}
keys['X'] = 193
keys['LB'] = 185
keys['RB'] = 183
keys['LT'] = 207
keys['RT'] = 208
keys['R3'] = 184
keys['L3'] = 28
keys['LEFT_AN_DOWN'] = 196
keys['LEFT_AN_UP'] = 32

require 'store/Speedy/util'
-- Self
require 'store/Speedy/superrun_options'
require 'store/Speedy/superflight_options'
require 'store/Speedy/self_menu_options'
-- Debug
require 'store/Speedy/debug_options'

local function Init()
    -- Main Menu
    menuIdTbl['Self'] = menu.list(menu.my_root(), 'Self', {}, '')
    menuIdTbl['Debug'] = menu.list(menu.my_root(), 'Debug', {}, '')

    MenuSelfSetup(menuIdTbl['Self'])
    MenuSuperRunSetup(menuIdTbl['Self.Super Run'])
    MenuSuperFlightSetup(menuIdTbl['Self.Super Flight'])

    MenuDebugOptionsSetup(menuIdTbl['Debug'])
end

Init()

while true do
	util.yield()
end