local bFlightHUDEnabled = false
local bContactThreadRunning = false
local bProjectileRadarThreadRunning = false

local bMissileNearby = false

function GetEntityHeadingUnsigned(entity)
    local s_h = -ENTITY.GET_ENTITY_ROTATION(entity).z
    local h = s_h
    if s_h < 0 then
        h = 360 + s_h
    end
    return h
end

function GetEntityPitchUnsigned(entity)
    local s_p = ENTITY.GET_ENTITY_ROTATION(entity).y
    local p = s_p
    if s_p < 0 then
        p = 360 + s_p
    end
    return p
end

function GetEntityMapDirection(entity)
    local str = ''
    local h = GetEntityHeadingUnsigned(entity)

    if h >= 0 and h < 22.5 then
        str = 'N'
    elseif h >= 22.5 and h < 67.5 then
        str = 'NE'
    elseif h >= 67.5 and h < 112.5 then
        str = 'E'
    elseif h >= 112.5 and h < 157.5 then
        str = 'SE'
    elseif h >= 157.5 and h < 202.5 then
        str = 'S'
    elseif h >= 202.5 and h < 247.5 then
        str = 'SW'
    elseif h >= 247.5 and h < 292.5 then
        str = 'W'
    elseif h >= 292.5 and h < 337.5 then
        str = 'NW'
    else
        str = 'N'
    end
    return str
end

-- Compass
function DoDrawCompass()
    local f_draw_y = 0.1
    local player_veh = entities.get_user_vehicle_as_handle()
    local h = GetEntityHeadingUnsigned(player_veh)

    local compass_col = {r=0,g=255,b=0,a=255}
    directx.draw_text(0.5, 0, "HDG: " .. tostring(math.floor(h)) .. "° " .. GetEntityMapDirection(player_veh), 1, 0.5, compass_col, true)
    directx.draw_rect(0.3, f_draw_y, 0.4, 3 / 1000, compass_col)
    directx.draw_rect(0.5, f_draw_y + 0.015, 3 / 1000, 0.03, compass_col)

    local s_h = ENTITY.GET_ENTITY_ROTATION(player_veh).z
    local a = ((s_h % 10) + (s_h - math.floor(s_h))) / 10
    local b = math.floor(h / 10)
    local c = b - 5
    if c < 0 then
        c = 36 + c
    end
    local d = b + 5
    if d > 35 then
        d = math.abs(36 - d)
    end

    for i=0,9,1 do
        local e = 0
        if d - c == 10 or c + i < 36 then
            e = c + i + 1
        else
            e = math.abs(36 - (c + i + 1))
        end
        if e == 36 then
            e = 0
        end

        local mark = tostring(e)
        if e == 0 then
            mark = 'N'
        elseif e == 9 then
            mark = 'E'
        elseif e == 18 then
            mark = 'S'
        elseif e == 27 then
            mark = 'W'
        end

        local x = 0.30000001192092896 + i * 0.039999999105930328 + a * 0.039999999105930328
        if e % 3 == 0 then
            directx.draw_text(x, f_draw_y - 0.06, mark, 1, 0.5, compass_col, true)
            directx.draw_rect(x, f_draw_y - 0.015, 3 / 1000, 0.03, compass_col)
        else
            directx.draw_rect(x, f_draw_y - 0.0075, 3 / 1000, 0.015, compass_col)
        end
    end
end

function DoDrawArtificialHorizon()
    local player_veh = entities.get_user_vehicle_as_handle()
    local player_veh_coords = ENTITY.GET_ENTITY_COORDS(player_veh)
    local player_veh_fv = ENTITY.GET_ENTITY_FORWARD_VECTOR(player_veh)
    local v3_rot = ENTITY.GET_ENTITY_ROTATION(player_veh)
    local col = {r = 0, g = 200, b = 0, a = 100}
    local col_horizon = {r = 200, g = 200, b = 200, a = 255}

    local v2_screen_coords = WorldToScreen(v3.add(player_veh_coords, v3.mul(player_veh_fv, 100)))
    local a = -(v2_screen_coords.y / 0.5)
    local b = v2_screen_coords.x / 0.5
    a = 0
    b = 0

    local c = 0.3
    local d = 0.1

    local pitch = v3_rot.x
    if pitch > 90 then
        pitch = 90 - pitch - 90
    elseif pitch < -90 then
        pitch = -((pitch + 90) - 90)
    end
    -- ((s_h % 10) + (s_h - math.floor(s_h))) / 10
    local e = ((pitch % 10) + (pitch - math.floor(pitch))) / 10
    local f = pitch - pitch % 10

    for i=0,4,1 do
        local g = 0
        if i == 0 then
            g = f + 20
        elseif i == 1 then
            g = f + 10
        elseif i == 2 then
            g = f
        elseif i == 3 then
            g = f - 10
        elseif i == 4 then
            g = f -20
        end
        if g > 90 then
            g = 90 - (g - 90)
        elseif g < -90 then
            g = -(g + 90) - 90
        end

        local str = tostring(math.floor(g))
        local y = c + i * d - a + e * d
        util.draw_debug_text(str[1])
        if str == '0' then   
            directx.draw_rect(b + 0.4 - (4 / 160) - 0.03437500074505806, y, 15 / 160, 1 / 500, col_horizon)
            directx.draw_rect(b + 0.6 - 0.02812499925494194, y, 15 / 160, 1 / 500, col_horizon)
        else
            if str[1] == '-' then          
                for j=0,5,1 do
                    directx.draw_rect(0.4 + (j * 2) * (1/160) + b - 0.03437500074505806, y, 1 / 160, 1 / 500, col)
                    directx.draw_rect(0.6 + (j * 2) * (1/160) + b - 0.02812499925494194, y, 1 / 160, 1 / 500, col)
                    --directx.draw_rect
                end
            else
                directx.draw_rect(0.4 + b - 0.03437500074505806, y, 11 / 160, 1/ 500, {r=0, g=255,b=0,a=150})
                directx.draw_rect(0.6 + b - 0.02812499925494194, y, 11 / 160, 1/ 500, {r=0, g=255,b=0,a=150})
            end
            directx.draw_rect(0.3635 + b, y - 0.004, 1 / 500, 0.009735, col)
            directx.draw_rect(0.6395 + b, y - 0.004, 1 / 500, 0.009735, col)
        end
        directx.draw_text(0.3425 + b, y, str, 1, 0.4, col)
        directx.draw_text(0.6575 + b, y, str, 1, 0.4, col)
    end

end

function StartContactsThread()
    local player_veh = entities.get_user_vehicle_as_handle()
    local players_unknown = players.list(true, true, true)
    local players_friends = players.list(false, true, false)
    local all_vehicles = entities.get_all_vehicles_as_handles()
    local txt_contact = directx.create_texture(filesystem.resources_dir() .. '/Speedy/air_vehicles/contact.png')

    
    if not bContactThreadRunning then
        bContactThreadRunning = true
        util.create_tick_handler(function()
            --bContactThreadRunning = true
            --while bContactThreadRunning do
                local my_pos = ENTITY.GET_ENTITY_COORDS(players.user_ped())
                for ph = 1, #players_unknown do
                    if ph == players.user() then
                        pluto_continue
                    end
                    local ped_id = PLAYER.GET_PLAYER_PED(ph)
                    local coords = ENTITY.GET_ENTITY_COORDS(ped_id)
                    --util.draw_ar_beacon(coords)
                    local draw_pos = WorldToScreen(coords)
                    local col = {r = 0, g = 255, b = 100, a = 255}
                    
                    if PED.IS_PED_IN_ANY_VEHICLE(ped_id) then
                        if PED.IS_PED_IN_ANY_HELI(ped_id) or PED.IS_PED_IN_ANY_PLANE(ped_id) then
                            col = {r = 255, g = 0, b = 0, a = 255}
                        end
                        directx.draw_text(draw_pos.x + 0.01, draw_pos.y + 0.01, 'S: ' .. tostring(math.floor(ENTITY.GET_ENTITY_SPEED(ped_id))), 0, 0.3, col)
                    else
                        col = {r=0, g=200, b=100, a=255}
                    end
                    directx.draw_texture(txt_contact, 0.005, 0.005, 0.5, 0.5, draw_pos.x, draw_pos.y, 0, col)
                    local dist_str = 'D: ' .. tostring(math.floor(GetDistanceBetweenCoords(my_pos, coords)))
                    
                    directx.draw_text(draw_pos.x + 0.01, draw_pos.y - 0.03, PLAYER.GET_PLAYER_NAME(ph), 0, 0.3, col)
                    directx.draw_text(draw_pos.x + 0.01, draw_pos.y - 0.02, dist_str, 0, 0.3, col)
                    directx.draw_text(draw_pos.x + 0.01, draw_pos.y - 0.01, 'A: ' .. tostring(math.floor(coords.z)), 0, 0.3, col)
                    directx.draw_text(draw_pos.x + 0.01, draw_pos.y, 'H: ' .. GetEntityMapDirection(ped_id), 0, 0.3, col)
                end
                return bContactThreadRunning
                --util.yield(1)
            --end
        end)
    end
end

function StartProjectileRadarThread()
    local blips = {}
    util.create_thread(function(t)
        bProjectileRadarThreadRunning = true

        while bProjectileRadarThreadRunning do
            for i,j in pairs(blips) do
                if HUD.GET_BLIP_INFO_ID_ENTITY_INDEX(j) == 0 then
                    util.remove_blip(j)
                    blips[i] = nil
                end
            end
            bMissileNearby = false
            local game_objects = entities.get_all_objects_as_handles()
            for l,k in pairs(game_objects) do
                if IsHashProjectile(ENTITY.GET_ENTITY_MODEL(k)) then
                    local c1 = ENTITY.GET_ENTITY_COORDS(k)
                    local c2 = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(entities.get_user_vehicle_as_handle(), 0, -300, 0)
                    if (GetDistanceBetweenCoords(c1, c2) < 300 and GetEntityOwner(k) ~= players.user()) then
                        bMissileNearby = true
                    end
                    if HUD.GET_BLIP_FROM_ENTITY(k) == 0 then
                        local prj = HUD.ADD_BLIP_FOR_ENTITY(k)
                        HUD.SET_BLIP_SPRITE(prj, 443)
                        HUD.SET_BLIP_COLOUR(prj, 75)
                        blips[#blips + 1] = prj
                    end
                end
            end
            util.yield(1)
        end
    end)

end

function DoFlightHUD(toggle)
    bFlightHUDEnabled = toggle
    if not bFlightHUDEnabled then
        bContactThreadRunning = false
        bProjectileRadarThreadRunning = false
    else
        StartContactsThread()
        StartProjectileRadarThread()
    end
    util.create_tick_handler(function()
        if PED.IS_PED_IN_ANY_PLANE(players.user_ped()) or PED.IS_PED_IN_ANY_HELI(players.user_ped()) then
            DoDrawCompass()
            DoDrawArtificialHorizon()

            if VEHICLE.GET_LANDING_GEAR_STATE(entities.get_user_vehicle_as_handle()) == 0 then
                directx.draw_text(0.50, 0.40, "LANDING GEAR DOWN", 5, 0.5, {r=255,g=0,b=0,a=255}, false)
            end

            local knts = (ENTITY.GET_ENTITY_SPEED(entities.get_user_vehicle_as_handle()) * 2.236936)*0.868976
            directx.draw_text(0.195, 0.42, tostring(math.ceil(knts)) .. " KNTS", 4, 1.2, {r=0,g=255,b=0,a=255}, false)

            local altitude = ENTITY.GET_ENTITY_HEIGHT_ABOVE_GROUND(entities.get_user_vehicle_as_handle())
            if altitude < 50 and VEHICLE.GET_LANDING_GEAR_STATE(entities.get_user_vehicle_as_handle()) ~= 0 then
                directx.draw_text(0.71, 0.42, "ALT " .. tostring(math.ceil(altitude)), 4, 1, {r=255,g=0,b=0,a=255}, false)
            else
                directx.draw_text(0.71, 0.42, "ALT " .. tostring(math.ceil(altitude)), 4, 1, {r=0,g=255,b=0,a=255}, false)
            end

            local ang = ENTITY.GET_ENTITY_ROTATION(entities.get_user_vehicle_as_handle(), 0)
            directx.draw_text_client(0.71, 0.46, "PITCH " .. tostring(math.ceil(ang.x)), 4, 0.7, {r=0,g=255,b=0,a=255}, false)
            directx.draw_text(0.71, 0.48, "ROLL " .. tostring(math.ceil(ang.y)), 4, 0.7, {r=0,g=255,b=0,a=255}, false)

            local z_coord = ENTITY.GET_ENTITY_COORDS(entities.get_user_vehicle_as_handle()).z
            if z_coord < 50 then
                directx.draw_text(0.71, 0.5, "ASML " .. tostring(math.ceil(z_coord)), 4, 0.7, {r=255,g=0,b=0,a=255}, false)
            else
                directx.draw_text(0.71, 0.5, "ASML " .. tostring(math.ceil(z_coord)), 4, 0.7, {r=0,g=255,b=0,a=255}, false)
            end
        end

        return bFlightHUDEnabled
    end)
end

function MenuFlightHUDSetup(menu_root)
    menu.toggle(menu_root, 'Enable HUD', {}, '', function(toggle) DoFlightHUD(toggle) end)
end