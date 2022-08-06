-- DrSpeedy#1852
-- https://github.com/DrSpeedy

local bSuperJumpEnabled = false
local bOnFootAimbotEnabled = false

local function DoSuperJump(toggle)
    bSuperJumpEnabled = toggle
    util.create_tick_handler(function()
        local player = PLAYER.PLAYER_PED_ID()
        local jumping = PED.IS_PED_JUMPING(player)
        local velocity = ENTITY.GET_ENTITY_VELOCITY(player)
        local direction = ENTITY.GET_ENTITY_FORWARD_VECTOR(player)

        if(jumping and PadMultiTap('X', 1)) then
            ENTITY.SET_ENTITY_VELOCITY(player, velocity.x+(direction.x*1.1), velocity.y+(direction.y*1.1), 20)
        end
        return bSuperJumpEnabled
    end)
end

local function DoOnFootAimbot(toggle)
    bOnFootAimbotEnabled = toggle
    util.create_tick_handler(function()
        if (PadSingleHold('LT')) then
            local player = PLAYER.PLAYER_PED_ID()
            local aim_coords = GetOffsetFromCam(80)
            local target_id = GetClosestPlayerToCoords(aim_coords, 80)
            if (target_id ~= -1 and target_id ~= PLAYER.PLAYER_ID()) then
                local target_ped = PLAYER.GET_PLAYER_PED(target_id)
                local target_coords = ENTITY.GET_ENTITY_COORDS(target_ped)

                --if (ENTITY.HAS_ENTITY_CLEAR_LOS_TO_ENTITY_IN_FRONT(player, target_ped)) then
                --    TASK.TASK_TURN_PED_TO_FACE_COORD(player, target_coords.x, target_coords.y, target_coords.z, 1)
                --    TASK.TASK_AIM_GUN_AT_COORD(player, target_coords.x, target_coords.y, target_coords.z, 1, 1, 1)
                --end
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

local function MenuQuickTeleSetup(menu_root)
    menu.action(menu_root, 'Teleport Forward', {}, '', function() DoTeleportForward() end)
    menu.action(menu_root, 'Teleport Upward', {}, '', function() DoTeleportUpward() end)
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