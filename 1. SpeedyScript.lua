---@diagnostic disable: undefined-global
-- Discord: DrSpeedy#1852
-- https://github.com/DrSpeedy
--[[
    TODO:
    * Quick player actions
    * Loadout manager ripoff
    * Copy loadout to player
    * Remove/fix broken aimbot code (camera one)
    * Auto shoot closest ped to crosshairs in head
]]
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
require 'store/Speedy/pad_handler'
require 'store/Speedy/aimbot'
-- Self
require 'store/Speedy/superrun_options'
require 'store/Speedy/superflight_options'
require 'store/Speedy/self_menu_options'
-- Debug
require 'store/Speedy/debug_options'

local function MemTest()
    local ptr_v3 = memory.alloc(24)
    memory.write_vector3(ptr_v3, v3.new(1.0, 2.0, 3.0))

    local controlv3 = memory.read_vector3(ptr_v3)

    Notification('Control test: ' .. controlv3.x .. ' ' .. controlv3.y .. ' ' .. controlv3.z)

    local testv3x = memory.read_float(ptr_v3)
    local testv3y = memory.read_float(ptr_v3 + 8)
    local testv3z = memory.read_float(ptr_v3 + 16)

    Notification('RF test: ' .. testv3x .. ' ' .. testv3y .. ' ' .. testv3z)
end

local function IsPlayerPointing()
    -- skidded from wiriscript
    return ReadGlobalInt(4521801 + 930) == 3
end

local bGodFingerEnabled = false
local function DoGodFinger(toggle)
    bGodFingerEnabled = toggle

    local max_distance = 30000.0
    util.create_tick_handler(function()
        if (IsPlayerPointing()) then
            WriteGlobalInt(4521801 + 935, NETWORK.GET_NETWORK_TIME()) -- to avoid the animation to stop -- skidded from wiriscript

            local cam_pos = CAM.GET_GAMEPLAY_CAM_COORD()
            local ofst_pos = GetOffsetFromCam(max_distance)
            local player = players.user_ped()
            local player_coords = ENTITY.GET_ENTITY_COORDS(player)
            local ray_test = StartShapeTest(cam_pos, ofst_pos, 319, 0, 7)
            local data = GetShapeTestResult(ray_test)

            DrawDebugLine(player_coords, ofst_pos, {r=255, g=0, b=0, a=255})

            if (data.bHit) then
                util.draw_ar_beacon(data.v3Coords)
                if (PAD.IS_CONTROL_PRESSED(2, keys['RB'])) then
                    local target = GetClosestPlayerToCoords(data.v3Coords, 5, true)
                    if (target_id ~= -1) then
                        ShootPedInHead(target, 'VEHICLE_WEAPON_DOGFIGHTER_MG', 500)
                    end
                end
            end
            --STREAMING.REQUEST_COLLISION_AT_COORD(ofst_pos.x, ofst_pos.y, ofst_pos.z)
        end
        return bGodFingerEnabled
    end)
end

local function Init()
    StartPadHandler()
    -- Main Menu
    menu.toggle(menu.my_root(), 'God Finger Test', {}, '', function (toggle)
        DoGodFinger(toggle)
    end)
    menu.action(menu.my_root(), 'Mem v3 test', {}, '', function ()
        
        local TraceFlag =
        {
            everything = 4294967295,
            none = 0,
            world = 1,
            vehicles = 2,
            pedsSimpleCollision = 4,
            peds = 8,
            objects = 16,
            water = 32,
            foliage = 256,
        }
        local test = TraceFlag.world | TraceFlag.peds | TraceFlag.water
        Notification('' .. test)
    end)
    MenuSetupSelfAimbot(menu.my_root())
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