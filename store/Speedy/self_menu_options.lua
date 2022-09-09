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
    menu.action(menu_root, 'Agency Gun Shop', {}, '', function ()
        TeleportPed(players.user_ped(), v3.new(380.32, -51.35, 111.96), v3.new(-0.38, -0.92, 0.0), false)
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

function MenuSelfSetup(menu_root)
    -- Self Menu
    menuIdTbl['Self.Super Run'] = menu.list(menu_root, 'Super Run', {}, '')
    menuIdTbl['Self.Super Flight'] = menu.list(menu_root, 'Super Flight', {}, '')
    menuIdTbl['Self.Quick Teleport'] = menu.list(menu_root, 'Quick Teleport', {}, '')
    menuIdTbl['Self.Aimbot'] = menu.list(menu_root, 'Aimbot', {}, '')
    menu.toggle(menu_root, 'Regenerate Health', {}, '', function(toggle) DoRegenHealth(toggle) end)
    menu.toggle(menu_root, 'Super Jump', {}, '', function(toggle) DoSuperJump(toggle) end)

    MenuSetupSelfAimbot(menuIdTbl['Self.Aimbot'])
    MenuQuickTeleSetup(menuIdTbl['Self.Quick Teleport'])
end