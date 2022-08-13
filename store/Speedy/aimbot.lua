local bAimbotEnabled = false
local bAimbotDebug = true

local function DoAimbot(toggle)
    bAimbotEnabled = toggle
    util.create_tick_handler(function()
        if (PED.IS_PED_SHOOTING(players.user_ped())) then
            local max_distance = 10000

            local cam_pos = CAM.GET_GAMEPLAY_CAM_COORD()
            local ofst_pos = GetOffsetFromCam(max_distance)
            local player = players.user_ped()
            local player_coords = ENTITY.GET_ENTITY_COORDS(player)
            local ray_test = StartShapeTest(cam_pos, ofst_pos, 319, 0, 7)
            local data = GetShapeTestResult(ray_test)

            GRAPHICS.DRAW_LINE(player_coords.x, player_coords.y, player_coords.z, ofst_pos.x, ofst_pos.y, ofst_pos.z, 255, 0, 0, 255)

            if (data.bHit) then
                util.draw_ar_beacon(data.v3Coords)
                local target = GetClosestPedToCoords(data.v3Coords, 20, true, false, false, false)
                Notification('' .. target.iPedId .. ' Name: ' .. target.sPlayerName)
                if (target.iPedId ~= -1) then
                    util.draw_box(target.v3Coords, v3.new(0,0,0), v3.new(1,1,2), 255, 255, 255, 255)
                    ShootPedInHead(target.iPedId, 'VEHICLE_WEAPON_DOGFIGHTER_MG', 500)
                end
            end
        end
        return bAimbotEnabled
    end)
end

function MenuSetupSelfAimbot(menu_root)
    menu.toggle(menu_root, 'Aimbot Test', {}, '', function(toggle) DoAimbot(toggle) end)
end