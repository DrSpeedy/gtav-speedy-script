local bFlightHUDEnabled = false

function GetEntityHeadingSigned(entity)
    local u_h = -ENTITY.GET_ENTITY_ROTATION(entity).z
    local h = u_h
    if u_h < 0 then
        h = 360 + u_h
    end
    return h
end

function GetEntityMapDirection(entity)
    local str = ''
    local h = GetEntityHeadingSigned(entity)

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
    local h = GetEntityHeadingSigned(player_veh)

    local compass_col = {r=255,g=0,b=0,a=255}
    directx.draw_text(0.5, 0, "HDG: " .. tostring(math.floor(h)) .. "° " .. GetEntityMapDirection(player_veh), 1, 0.5, compass_col, true)
    directx.draw_rect(0.3, f_draw_y, 0.4, 3 / 1000, compass_col)
    directx.draw_rect(0.5, f_draw_y + 0.015, 3 / 1000, 0.03, compass_col)

    local a = ((h % 10) + (h - math.floor(h))) / 10
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
    local f_draw_y = ENTITY.GET_ENTITY_ROTATION(player_veh).y

    local v2_screen_coords = WorldToScreen(v3.add(player_veh_coords, v3.mul(player_veh_fv, 100)))
    local a = -(v2_screen_coords.y / 0.5)
    local b = v2_screen_coords.x / 0.5


end

function DoFlightHUD(toggle)
    bFlightHUDEnabled = toggle
    util.create_tick_handler(function()
        if PED.IS_PED_IN_ANY_PLANE(players.user_ped()) or PED.IS_PED_IN_ANY_HELI(players.user_ped()) then
            DoDrawCompass()
        end

        return bFlightHUDEnabled
    end)
end

function MenuFlightHUDSetup(menu_root)
    menu.toggle(menu_root, 'Enable HUD', {}, '', function(toggle) DoFlightHUD(toggle) end)
end