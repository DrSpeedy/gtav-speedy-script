-- DrSpeedy#1852
-- https://github.com/DrSpeedy

local bSuperJumpEnabled = false
local function DoSuperJump(toggle)
    bSuperJumpEnabled = toggle
    util.create_tick_handler(function()
        local player = PLAYER.PLAYER_PED_ID()
        local jumping = PED.IS_PED_JUMPING(player)
        local velocity = ENTITY.GET_ENTITY_VELOCITY(player)
        local direction = ENTITY.GET_ENTITY_FORWARD_VECTOR(player)

        if(CheckInput('[t]X:[d]VK(48)') and jumping) then
            ENTITY.SET_ENTITY_VELOCITY(player, velocity.x+(direction.x*1.1), velocity.y+(direction.y*1.1), velocity.z + 15)
        end
        return bSuperJumpEnabled
    end)
end

-- Quick Teleports
local function DoTeleportForward()
    local player = PLAYER.PLAYER_PED_ID()
    local coords = ENTITY.GET_ENTITY_COORDS(player)
    local direction = ENTITY.GET_ENTITY_FORWARD_VECTOR(player)
    local distance = 4

    local x = coords.x + (direction.x * distance)
    local y = coords.y + (direction.y * distance)
    local z = coords.z + (direction.z * distance)

    ENTITY.SET_ENTITY_COORDS(player, x, y, z)
end

local function DoTeleportUpward()
    local player = PLAYER.PLAYER_PED_ID()
    local coords = ENTITY.GET_ENTITY_COORDS(player)
    local distance = 10

    local x = coords.x
    local y = coords.y
    local z = coords.z + distance

    ENTITY.SET_ENTITY_COORDS(player, x, y, z)
end

local function MenuQuickTeleSetup(menu_root)
    menu.action(menu_root, 'Cayo Vault', {}, '', function ()
        TeleportPed(players.user_ped(), v3.new(380.32, -51.35, 111.96), v3.new(-0.38, -0.92, 0.0), false)
    end)
    menu.action(menu_root, 'Cayo Compound Exit', {}, '', function ()
        TeleportPed(players.user_ped(), v3.new(4990.54,-5719.12,19.88), v3.new(0,-4,47), true)
    end)
    menu.divider(menu_root, '====================')
    menu.action(menu_root, 'Teleport Forward', {}, '', function() DoTeleportForward() end)
    menu.action(menu_root, 'Teleport Upward', {}, '', function() DoTeleportUpward() end)
    menu.action(menu_root, 'Copy TP to Clipboard', {}, '', function()
        local pos = ENTITY.GET_ENTITY_COORDS(players.user_ped())
        local rot = ENTITY.GET_ENTITY_ROTATION(players.user_ped(), 0)
        local str = 'TeleportPed(players.user_ped(), v3.new('..pos.x..','..pos.y..','..pos.z..'), v3.new('..rot.x..','..rot.y..','..rot.z..'), true)'
        util.copy_to_clipboard(str, true)
    end)
end

local bRegenHealthEnabled = false
local function DoRegenHealth(toggle)
    bRegenHealthEnabled = toggle
    local delay = 25 -- Delay in ticks
    local step = 10 -- % of max health/armor to add to current value
    local tick = 0

    util.create_tick_handler(function()
        if (tick > delay) then
            local player = players.user_ped()
            tick = 0

            local max_health = ENTITY.GET_ENTITY_MAX_HEALTH(player)
            local max_armor = 50
            local current_health = ENTITY.GET_ENTITY_HEALTH(player)
            local current_armor = PED.GET_PED_ARMOUR(player)
            local health_modifier = math.floor((max_health / 100) * step)
            local armor_modifier = math.floor((max_armor / 100) * step)
            if (current_health < max_health) then
                if ((current_health + health_modifier) > max_health) then
                    current_health = current_health + (max_health - current_health)
                else
                    current_health = current_health + health_modifier
                end
                ENTITY.SET_ENTITY_HEALTH(player, current_health)
            elseif (current_armor < max_armor) then
                if ((current_armor + armor_modifier) > max_armor) then
                    current_armor = current_armor + (max_armor - current_armor)
                else
                    current_armor = current_armor + armor_modifier
                end
                PED.SET_PED_ARMOUR(player, current_armor)
            end
        else
            tick = tick + 1
        end
        return bRegenHealthEnabled
    end)
end

local bTelekModeEnabled = false
local function DoTelekMode(toggle)
    bTelekModeEnabled = toggle

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
        return bTelekModeEnabled
    end)
end

function MenuSelfSetup(menu_root)
    -- Self Menu
    menuIdTbl['Self.Super Run'] = menu.list(menu_root, 'Super Run', {}, '')
    menuIdTbl['Self.Super Flight'] = menu.list(menu_root, 'Super Flight', {}, '')
    menuIdTbl['Self.Quick Teleport'] = menu.list(menu_root, 'Quick Teleport', {}, '')
    menuIdTbl['Self.Aimbot'] = menu.list(menu_root, 'Aimbot', {}, '')
    menu.toggle(menu_root, 'Telekinesis', {}, 'Hold down \'0\' key to activate', function(toggle) DoTelekMode(toggle) end)
    menu.toggle(menu_root, 'Regenerate Health', {}, '', function(toggle) DoRegenHealth(toggle) end)
    menu.toggle(menu_root, 'Super Jump', {}, '', function(toggle) DoSuperJump(toggle) end)

    MenuSetupSelfAimbot(menuIdTbl['Self.Aimbot'])
    MenuQuickTeleSetup(menuIdTbl['Self.Quick Teleport'])
end