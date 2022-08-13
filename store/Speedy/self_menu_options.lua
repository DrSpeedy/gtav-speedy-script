-- DrSpeedy#1852
-- https://github.com/DrSpeedy

local bSuperJumpEnabled = false
local bOnFootAimbotEnabled = false
local bTeleportWhereLookingEnabled = false
local bTeleportWhereLookingEnabled2 = false

local function DoSuperJump(toggle)
    bSuperJumpEnabled = toggle
    util.create_tick_handler(function()
        local player = PLAYER.PLAYER_PED_ID()
        local jumping = PED.IS_PED_JUMPING(player)
        local velocity = ENTITY.GET_ENTITY_VELOCITY(player)
        local direction = ENTITY.GET_ENTITY_FORWARD_VECTOR(player)

        if(jumping and PadMultiTapHold('X', 1)) then
            ENTITY.SET_ENTITY_VELOCITY(player, velocity.x+(direction.x*1.1), velocity.y+(direction.y*1.1), velocity.z + 3)
        end
        return bSuperJumpEnabled
    end)
end

local function DoOnFootAimbot(toggle)
    bOnFootAimbotEnabled = toggle
    util.create_tick_handler(function()
        if (PadSingleTapHold('LT')) then
            PointGameplayCamAtCoords(v3.new(0.0, 0.0, 0.0))
            local player = PLAYER.PLAYER_PED_ID()
            local aim_coords = GetOffsetFromCam(80)
            local target_id = GetClosestPlayerToCoords(aim_coords, 80)
            if (target_id ~= -1 and target_id ~= PLAYER.PLAYER_ID()) then
                local target_ped = PLAYER.GET_PLAYER_PED(target_id)
                local target_coords = ENTITY.GET_ENTITY_COORDS(target_ped)
                PointGameplayCamAtCoords(v3.new(0.0, 0.0, 0.0))
                --[[if (ENTITY.HAS_ENTITY_CLEAR_LOS_TO_ENTITY_IN_FRONT(player, target_ped)) then
                    local cam_coords = CAM.GET_GAMEPLAY_CAM_COORD()
                    local dX = target_coords.x - cam_coords.x
                    local dY = target_coords.y - cam_coords.y
                    local dZ = target_coords.z - cam_coords.z

                    local pitch = MISC.ATAN2(dX, dY) / math.pi
                    local yaw = MISC.ASIN(dZ / GetDistanceBetweenCoords(target_coords, cam_coords)) * 180 / math.pi
                    local roll = 0.0
                    util.draw_debug_text('Pitch: ' .. pitch .. ' Yaw: ' .. yaw)
                    CAM._SET_GAMEPLAY_CAM_RELATIVE_ROTATION(roll, pitch, yaw)
                --end]]
            end
        end
        return bOnFootAimbotEnabled
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

local function DoTeleportWhereLooking(toggle)
    bTeleportWhereLookingEnabled = toggle
    util.create_tick_handler(function()
        if (PadSingleTapHold('LT') and PadMultiTap('R3', 1)) then
            local player = PLAYER.PLAYER_PED_ID()
            local cam_rot = CAM.GET_GAMEPLAY_CAM_ROT(0)
            local target_min = GetOffsetFromCam(1)
            local target_max = GetOffsetFromCam(10000)
            local raytest_id = SHAPETEST.START_EXPENSIVE_SYNCHRONOUS_SHAPE_TEST_LOS_PROBE(
                target_min.x,
                target_min.y,
                target_min.z,
                target_max.x,
                target_max.y,
                target_max.z,
                -1, 0, 7
            )
            local data = GetShapeTestResult(raytest_id)
            if (data.bHit) then
                Notification('Entity test: '.. data.Entity)
                ENTITY.SET_ENTITY_COORDS(player, data.v3Coords.x, data.v3Coords.y, data.v3Coords.z)
                ENTITY.SET_ENTITY_ROTATION(player, cam_rot.x, cam_rot.y, cam_rot.z)
            else
                Notification("No hit")
            end
        end

        return bTeleportWhereLookingEnabled
    end)
end
-- Not viable
local function DoTeleportWhereLooking2(toggle)
    bTeleportWhereLookingEnabled2 = toggle
    util.create_tick_handler(function()
        --if (PadSingleTapHold('LT') and PadMultiTap('R3', 1)) then
            local player = PLAYER.PLAYER_PED_ID()
            local cam_rot = CAM.GET_GAMEPLAY_CAM_ROT(0)

            local distance = 2000
            local target = GetOffsetFromCam(distance)
            local losobj = entities.create_object(1054209047, target) -- Spawn a screwdriver to test LOS... lol
            for i=distance, 1, -1 do
                if (ENTITY.HAS_ENTITY_CLEAR_LOS_TO_ENTITY(player, losobj, 17)) then
                    util.draw_ar_beacon(target)
                    --ENTITY.SET_ENTITY_COORDS(player, target.x, target.y, target.z)
                    --ENTITY.SET_ENTITY_ROTATION(player, cam_rot.x, cam_rot.y, cam_rot.z, 1, true)
                    break
                end
                target = GetOffsetFromCam(i)
                ENTITY.SET_ENTITY_COORDS(losobj, target.x, target.y, target.z)
            end
            entities.delete_by_handle(losobj)
        --end

        return bTeleportWhereLookingEnabled2
    end)
end

local function MenuQuickTeleSetup(menu_root)
    menu.action(menu_root, 'Teleport Forward', {}, '', function() DoTeleportForward() end)
    menu.action(menu_root, 'Teleport Upward', {}, '', function() DoTeleportUpward() end)
    menu.toggle(menu_root, 'Teleport Where Looking', {}, '', function(toggle) DoTeleportWhereLooking(toggle) end)
    menu.toggle(menu_root, 'Teleport Where Looking 2', {}, '', function(toggle) DoTeleportWhereLooking2(toggle) end)
end

function MenuSelfSetup(menu_root)
    -- Self Menu
    menuIdTbl['Self.Super Run'] = menu.list(menu_root, 'Super Run', {}, '')
    menuIdTbl['Self.Super Flight'] = menu.list(menu_root, 'Super Flight', {}, '')
    menuIdTbl['Self.Quick Teleport'] = menu.list(menu_root, 'Quick Teleport', {}, '')
    menu.toggle(menu_root, 'Aimbot', {}, '', function(toggle) DoOnFootAimbot(toggle) end)
    menu.toggle(menu_root, 'Super Jump', {}, '', function(toggle) DoSuperJump(toggle) end)

    MenuQuickTeleSetup(menuIdTbl['Self.Quick Teleport'])
end