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
-- Debug
require 'store/Speedy/debug_options'

-- Flight HUD
require 'store/Speedy/flight_hud'

local function IsPlayerPointing()
    -- skidded from wiriscript
    return ReadGlobalInt(4521801 + 930) == 3
end

local bAdminModeEnabled = false
local function DoAdminMode(toggle)
    bAdminModeEnabled = toggle

    local max_distance = 30000.0
    local target_entity = -1
    local prev_target = -1
    local target_data = {}
    local reset_target = false
    util.create_tick_handler(function()

        if (reset_target) then
            prev_target = target_entity
            target_entity = -1
            target_data = {}
            reset_target = false
        end

        if (CheckInput('[D]VK(48)')) then
            DisableAllControlsThisTick({'RIGHT_STICK', 'LEFT_STICK', 'X'})
            local cam_pos = CAM.GET_GAMEPLAY_CAM_COORD()
            local ofst_pos = GetOffsetFromCam(max_distance)
            local player = players.user_ped()
            local player_coords = ENTITY.GET_ENTITY_COORDS(player)

            if (not ENTITY.DOES_ENTITY_EXIST(target_entity)) then
                local ray_test = StartShapeTest(cam_pos, ofst_pos, 319, 0, 7)
                target_data = GetShapeTestResult(ray_test)

                DrawDebugLine(player_coords, ofst_pos, {r=255, g=0, b=0, a=255})

                if (target_data.bHit) then
                    util.draw_ar_beacon(target_data.v3Coords)
                    if (prev_target ~= target_data.Entity and target_data.Entity ~= players.user_ped() and
                    (ENTITY.IS_ENTITY_A_VEHICLE(target_data.Entity) or ENTITY.IS_ENTITY_A_PED(target_data.Entity))) then
                        target_entity = target_data.Entity
                    end
                end
            else
                util.draw_ar_beacon(target_data.v3Coords)
            end
            -- At this point we are either still raycasting or we have a target_entity
            if (target_data.bHit) then
                local distance = player_coords:distance(target_data.v3Coords)

                -- Teleport where looking
                if (CheckInput('[t2]RB')) then
                    TeleportPed(player, target_data.v3Coords, nil, true)
                end

                if (ENTITY.DOES_ENTITY_EXIST(target_entity)) then
                    target_data.v3Coords = ENTITY.GET_ENTITY_COORDS(target_entity)
                    if (ENTITY.IS_ENTITY_A_PED(target_entity) or ENTITY.IS_ENTITY_A_VEHICLE(target_entity)) then
                        
                        -- PED Only Options
                        if (ENTITY.IS_ENTITY_A_PED(target_entity)) then
                            if (CheckInput('[t]RT')) then
                                local hash = LoadWeaponAsset('VEHICLE_WEAPON_DOGFIGHTER_MG')
                                ShootPedInHead(target_entity, hash, 500)
                            elseif (CheckInput('[T]DPAD_UP')) then
                                local hash = LoadWeaponAsset('WEAPON_RPG')
                                ShootPedInHead(target_entity, hash, WEAPON.GET_WEAPON_DAMAGE(hash))
                            elseif (CheckInput('[T]DPAD_RIGHT')) then
                                local hash = LoadWeaponAsset('WEAPON_STUNGUN_MP')
                                ShootPedInHead(target_entity, hash, WEAPON.GET_WEAPON_DAMAGE(hash))
                            elseif (CheckInput('[t]DPAD_LEFT')) then
                                local hash = LoadWeaponAsset('WEAPON_MOLOTOV')
                                ShootPedInHead(target_entity, hash, WEAPON.GET_WEAPON_DAMAGE(hash))
                            end
                        end
                        
                        -- Vehicle only
                        if (ENTITY.IS_ENTITY_A_VEHICLE(target_entity)) then
                            -- Drop a molotov on all vehicle ocupants
                            if (CheckInput('[t]DPAD_LEFT')) then
                                local hash = LoadWeaponAsset('WEAPON_MOLOTOV')
                                for i = -1, 10 do
                                    local p = VEHICLE.GET_PED_IN_VEHICLE_SEAT(target_entity, i, true)
                                    if (ENTITY.IS_ENTITY_A_PED(p)) then
                                        ShootPedInHead(p, hash, 50)
                                    end
                                end
                            -- Delete vehicle
                            elseif (CheckInput('[T2]DPAD_RIGHT')) then
                                Notification('Attempting to delete vehicle')
                                RequestControlOfNetworkEntity(target_entity)
                                entities.delete_by_handle(target_entity)
                            -- Disable vehicle
                            elseif (CheckInput('[T2]DPAD_DOWN')) then
                                Notification('Attempting to disable vehicle')
                                RequestControlOfNetworkEntity(target_entity)
                                VEHICLE.SET_VEHICLE_ENGINE_ON(target_entity, false, true, true)
                                VEHICLE.SET_VEHICLE_ENGINE_HEALTH(target_entity, 0)
                            -- Explode vehicle
                            elseif (CheckInput('[T]DPAD_UP')) then
                                Notification('Exploding vehicle')
                                local hash = LoadWeaponAsset('WEAPON_RPG')
                                ShootAtEntity(target_entity, hash, WEAPON.GET_WEAPON_DAMAGE(hash))
                            -- Warp into first available vehicle seat
                            elseif (CheckInput('[T]Y')) then
                                Notification('Attempting to warp into vehicle')
                                RequestControlOfNetworkEntity(target_entity)
                                PED.SET_PED_INTO_VEHICLE(players.user_ped(), target_entity, -2)
                            end
                        end

                        -- Pick up the entity
                        if (CheckInput('[H]LT')) then
                            local movement_pos_ofst = v3.new(CAM.GET_GAMEPLAY_CAM_ROT(0):toDir())
                            movement_pos_ofst:mul(distance)
                            movement_pos_ofst:add(player_coords)
                            util.draw_ar_beacon(movement_pos_ofst)
                            local movement_dir = v3.new(movement_pos_ofst)
                            movement_dir:sub(target_data.v3Coords)
                            movement_dir:normalise()
                            if (ENTITY.IS_ENTITY_A_VEHICLE(target_entity)) then
                                RequestControlOfNetworkEntity(target_entity)
                                local vel_magnitude = target_data.v3Coords:distance(movement_pos_ofst)
                                local movement_vel = v3.new(movement_dir)
                                if (vel_magnitude < 10) then vel_magnitude = 10 end
                                movement_vel:mul(vel_magnitude)
                                ENTITY.SET_ENTITY_VELOCITY(target_entity, movement_vel.x, movement_vel.y, movement_vel.z)
                                if (CheckInput('[T]RT')) then
                                    local speed_ofst = GetOffsetFromCam(1000)
                                    movement_vel.x = speed_ofst.x - target_data.v3Coords.x
                                    movement_vel.y = speed_ofst.y - target_data.v3Coords.y
                                    movement_vel.z = speed_ofst.z - target_data.v3Coords.z

                                    ENTITY.SET_ENTITY_VELOCITY(target_entity, movement_vel.x, movement_vel.y, movement_vel.z)
                                    reset_target = true
                                elseif (CheckInput('[H]DPAD_DOWN')) then
                                    movement_vel = v3.new(player_coords)
                                    movement_vel:sub(target_data.v3Coords)
                                    movement_vel:normalise()
                                    movement_vel:add(movement_dir)
                                    --util.draw_debug_text('vX: ' .. movement_vel.x .. ' vY: ' ..movement_vel.y.. ' vZ: '.. movement_vel.z)
                                    movement_vel:normalise()
                                    movement_vel:mul(vel_magnitude)

                                    ENTITY.SET_ENTITY_VELOCITY(target_entity, movement_vel.x, movement_vel.y, movement_vel.z)
                                elseif (CheckInput('[H]DPAD_UP')) then
                                    movement_vel = v3.new(target_data.v3Coords)
                                    movement_vel:sub(player_coords)
                                    movement_vel:normalise()
                                    movement_vel:add(movement_dir)
                                    movement_vel:normalise()
                                    movement_vel:mul(vel_magnitude)

                                    ENTITY.SET_ENTITY_VELOCITY(target_entity, movement_vel.x, movement_vel.y, movement_vel.z)
                                end
                            end
                        end
                    end
                end
            end
        else
            reset_target = true
        end
        return bAdminModeEnabled
    end)
end

local function Init()
    StartPadHandler()
    StartCheatHandler()
    -- Main Menu
    MenuWeaponLoadoutSetup(menu.my_root())
    menu.toggle(menu.my_root(), 'Admin Mode', {}, '', function (toggle)
        DoAdminMode(toggle)
    end)

    menuIdTbl['Self'] = menu.list(menu.my_root(), 'Self', {}, '')
    menuIdTbl['FlightHUD'] = menu.list(menu.my_root(), 'Flight HUD', {}, '')
    MenuOnlineQuickOptsSetup(menu.my_root())
    menuIdTbl['Debug'] = menu.list(menu.my_root(), 'Debug', {}, '')

    -- Self
    MenuSelfSetup(menuIdTbl['Self'])
    MenuSuperRunSetup(menuIdTbl['Self.Super Run'])
    MenuSuperFlightSetup(menuIdTbl['Self.Super Flight'])

    --- Flight Hud
    MenuFlightHUDSetup(menuIdTbl['FlightHUD'])

    MenuDebugOptionsSetup(menuIdTbl['Debug'])
end

Init()

while true do
	util.yield()
end