-- DrSpeedy#1852
-- https://github.com/DrSpeedy

local function DoSuperJump(toggle)
    util.create_tick_handler(function()
        if (toggle) then
            local player = PLAYER.PLAYER_PED_ID()
            local jumping = PED.IS_PED_JUMPING(player)
            local velocity = ENTITY.GET_ENTITY_VELOCITY(player)
            local direction = ENTITY.GET_ENTITY_FORWARD_VECTOR(player)

            if(jumping) then
                if(PAD.IS_CONTROL_PRESSED(2,keys['X'])) then  -- X
                    ENTITY.SET_ENTITY_VELOCITY(player, velocity.x+(direction.x*1.1), velocity.y+(direction.y*1.1), velocity.z)
                    if(velocity.z > 0.3)then
                        ENTITY.SET_ENTITY_VELOCITY(player, velocity.x+(direction.x*1.1), velocity.y+(direction.y*1.1), velocity.z+3)
                    end
                end
            end
        end
    end)
end

function MenuSelfSetup(menu_root)
    -- Self Menu
    menuIdTbl['Self.Super Run'] = menu.list(menu_root, 'Super Run', {}, '')
    menuIdTbl['Self.Super Flight'] = menu.list(menu_root, 'Super Flight', {}, '')
    menu.toggle(menu_root, 'Super Jump', {}, '', function(toggle) DoSuperJump(toggle) end)
end