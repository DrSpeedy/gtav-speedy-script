---@diagnostic disable: undefined-global
-- Discord: DrSpeedy#1852
-- https://github.com/DrSpeedy

ScriptVersion = '1.0.0'
util.require_natives('1627063482')

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
keys['DPAD_DOWN'] = 48
keys['DPAD_UP'] = 42
keys['DPAD_RIGHT'] = 14

VK = {
    ['0'] = 48
}

require 'lib/Speedy/Keys'
require 'store/Speedy/util'
require 'store/Speedy/pad_handler'
require 'store/Speedy/cheat_codes'
-- Self
require 'store/Speedy/superrun_options'
require 'store/Speedy/superflight_options'
require 'store/Speedy/aimbot'
require 'store/Speedy/self_menu_options'
-- Weapons
require 'store/Speedy/weapon_loadout'
-- Online
require 'store/Speedy/online_quick_opts'
-- Misc
require 'store/Speedy/debug_options'
require 'store/Speedy/about'

-- Flight HUD
require 'store/Speedy/flight_hud'

local function IsPlayerPointing()
    -- skidded from wiriscript
    return ReadGlobalInt(4521801 + 930) == 3
end

local function Init()
    StartPadHandler()
    StartCheatHandler()
    -- Main Menu
    MenuWeaponLoadoutSetup(menu.my_root())
    --menu.toggle(menu.my_root(), 'Telekinesis', {}, '', function (toggle) DoTelekMode(toggle) end)

    menuIdTbl['Self'] = menu.list(menu.my_root(), 'Self', {}, '')
    menuIdTbl['FlightHUD'] = menu.list(menu.my_root(), 'Flight HUD', {}, '')
    MenuOnlineQuickOptsSetup(menu.my_root())
    menuIdTbl['Debug'] = menu.list(menu.my_root(), 'Debug', {}, '')
    menuIdTbl['About'] = menu.list(menu.my_root(), 'About', {}, '')
    MenuAboutSetup(menuIdTbl['About'])

    -- Self
    MenuSelfSetup(menuIdTbl['Self'])
    MenuSuperRunSetup(menuIdTbl['Self.Super Run'])
    MenuSuperFlightSetup(menuIdTbl['Self.Super Flight'])

    --- Flight Hud
    MenuFlightHUDSetup(menuIdTbl['FlightHUD'])

    MenuDebugOptionsSetup(menuIdTbl['Debug'])


    -- Updater
    -- CheckForUpdates()
end

Init()

while true do
	util.yield()
end