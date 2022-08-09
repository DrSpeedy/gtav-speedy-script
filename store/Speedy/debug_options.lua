-- DrSpeedy#1852
-- https://github.com/DrSpeedy

local bDrawFVEnabled = false
local bDrawVelVEnabled = false
local bDrawDebugTextEnabled = false
local bDrawCrosshairEnabled = false

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
        local speed = ENTITY.GET_ENTITY_SPEED(player)

        util.draw_debug_text('Coords: x: ' .. coords.x .. ' y: ' .. coords.y .. ' z: ' .. coords.z)
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

function MenuDebugOptionsSetup(menu_root)
    menu.toggle(menu_root, 'Draw Forward Vector', {}, '', function(toggle) DoDrawForwardVector(toggle) end)
    menu.toggle(menu_root, 'Draw Velocity Vector', {}, '', function(toggle) DoDrawVelocityVector(toggle) end)
    menu.toggle(menu_root, 'Draw Debug Overlays', {}, '', function(toggle) DoDrawDebugOverlays(toggle) end)
    menu.toggle(menu_root, 'Draw Crosshair', {}, '', function(toggle) DoDrawCrosshair(toggle) end)
end