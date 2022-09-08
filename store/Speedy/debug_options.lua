-- DrSpeedy#1852
-- https://github.com/DrSpeedy

local bDrawFVEnabled = false
local bDrawVelVEnabled = false
local bDrawDebugTextEnabled = false
local bDrawCrosshairEnabled = false
local bDrawESP = false

local function DoDrawForwardVector(toggle)
    bDrawFVEnabled = toggle
    util.create_tick_handler(function()
        if (bDrawFVEnabled) then
            local player = PLAYER.PLAYER_PED_ID()
            local fv = ENTITY.GET_ENTITY_FORWARD_VECTOR(player)
            local coords = ENTITY.GET_ENTITY_COORDS(player)

            -- Forward Vector
            GRAPHICS.DRAW_LINE(coords.x, coords.y, coords.z, coords.x + fv.x, coords.y + fv.y, coords.z + fv.z, 255, 0, 255, 255)
            -- FV pointed at horizon (No z-axis)
            GRAPHICS.DRAW_LINE(coords.x, coords.y, coords.z, coords.x + fv.x, coords.y + fv.y, coords.z, 255, 0, 0, 255)
        end
        return bDrawFVEnabled
    end)
end

local function DoDrawVelocityVector(toggle)
    bDrawVelVEnabled = toggle
    util.create_tick_handler(function()
        local player = PLAYER.PLAYER_PED_ID()
        local vel = ENTITY.GET_ENTITY_VELOCITY(player)
        local coords = ENTITY.GET_ENTITY_COORDS(player)

        GRAPHICS.DRAW_LINE(coords.x, coords.y, coords.z, coords.x + vel.x, coords.y + vel.y, coords.z + vel.z, 0, 0, 255, 255)

        return bDrawVelVEnabled
    end)
end

local function DoDrawDebugOverlays(toggle)
    bDrawDebugTextEnabled = toggle
    util.create_tick_handler(function()
        local player = PLAYER.PLAYER_PED_ID()
        local fv = ENTITY.GET_ENTITY_FORWARD_VECTOR(player)
        local vel = ENTITY.GET_ENTITY_VELOCITY(player)
        local coords = ENTITY.GET_ENTITY_COORDS(player)
        local rot = ENTITY.GET_ENTITY_ROTATION(player, 0)
        local speed = ENTITY.GET_ENTITY_SPEED(player)

        util.draw_debug_text('Coords: x: ' .. coords.x .. ' y: ' .. coords.y .. ' z: ' .. coords.z)
        util.draw_debug_text('Rot: x: ' .. rot.x .. ' y: ' .. rot.y .. ' z: ' .. rot.z)
        util.draw_debug_text('FV: x: ' .. fv.x .. ' y: ' .. fv.y .. ' z: ' .. fv.z)
        util.draw_debug_text('Velocity: x: ' .. vel.x .. ' y: ' .. vel.y .. ' z: ' .. vel.z)
        util.draw_debug_text('Speed: ' .. speed)

        return bDrawDebugTextEnabled
    end)
end

function DoDrawCrosshair(toggle)
    bDrawCrosshairEnabled = toggle

    local asset_file = 'resources\\Speedy\\cr3.png'
    local d3texture = directx.create_texture(filesystem.scripts_dir() .. asset_file)
    local d3t_size = 0.03
    local pos_x = 0.5
    local pos_y = 0.5
    local cent_x = 0.5
    local cent_y = 0.5
    local rotation = 0.0

    util.create_tick_handler(function()
        directx.draw_texture(d3texture, d3t_size, d3t_size, cent_x, cent_y, pos_x, pos_y, rotation, {r = 1.0, g = 1.0, b = 1.0, a = 1.0})
        return bDrawCrosshairEnabled
    end)
end

local function DoDrawESP(toggle)
    bDrawESP = toggle
    util.create_tick_handler(function()
        if (util.is_key_down(48) and PadSingleTapHold('RB')) then
            local ped_list = entities.get_all_peds_as_handles()
            local player_pos = ENTITY.GET_ENTITY_COORDS(players.user_ped())
            for i = 1, #ped_list do
                local ped_pos = ENTITY.GET_ENTITY_COORDS(ped_list[i])
                if (not ENTITY.IS_ENTITY_DEAD(ped_list[i]) or players.user_ped() ~= ped_list[i]) then
                    if (PED.IS_PED_A_PLAYER(ped_list[i])) then
                        DrawDebugLine(player_pos, ped_pos, {r = 255, g = 255, b = 0, a = 255})
                    else
                        DrawDebugLine(player_pos, ped_pos, {r = 255, g = 255, b = 255, a = 255})
                    end
                end
            end
        end
        return bDrawESP
    end)
end

local bBigMapMode = false
local function DoBigMapMode(toggle)
    bBigMapMode = toggle

    util.create_tick_handler(function()
        local player_coords = ENTITY.GET_ENTITY_COORDS(players.user_ped())
        local interior = INTERIOR.GET_INTERIOR_AT_COORDS(player_coords.x, player_coords.y, player_coords.z)
        if (INTERIOR.IS_VALID_INTERIOR(interior)) then
            HUD.SET_RADAR_ZOOM_PRECISE(83)
        else
            HUD.SET_RADAR_ZOOM_PRECISE(99)
        end
        return bBigMapMode
    end)
end

local bAimbotDebug = false
local function DoAimbotDebug(toggle)
    bAimbotDebug = toggle
    util.create_tick_handler(function()
        local a, b = v3.new()
        a = PED.GET_PED_BONE_COORDS(players.user_ped(), 31086, 0.1, 0.15, 0)
        b = PED.GET_PED_BONE_COORDS(players.user_ped(), 31086, 0.1, -0.15, 0)
        GRAPHICS.DRAW_LINE(a.x, a.y, a.z, b.x, b.y, b.z, 255, 255, 0, 255)
        return bAimbotDebug
    end)
end

function MenuDebugOptionsSetup(menu_root)
    menu.toggle(menu_root, 'Draw Forward Vector', {}, '', function(toggle) DoDrawForwardVector(toggle) end)
    menu.toggle(menu_root, 'Draw Velocity Vector', {}, '', function(toggle) DoDrawVelocityVector(toggle) end)
    menu.toggle(menu_root, 'Draw Debug Overlays', {}, '', function(toggle) DoDrawDebugOverlays(toggle) end)
    menu.toggle(menu_root, 'Draw Crosshair', {}, '', function(toggle) DoDrawCrosshair(toggle) end)
    menu.toggle(menu_root, 'Draw ESP', {}, '', function(toggle) DoDrawESP(toggle) end)
    menu.toggle(menu_root, 'Draw Ped Head Debug', {}, '', function(toggle) DoAimbotDebug(toggle) end)
    menu.toggle(menu_root, 'Big Map Mode', {}, '', function(toggle) DoBigMapMode(toggle) end)
end