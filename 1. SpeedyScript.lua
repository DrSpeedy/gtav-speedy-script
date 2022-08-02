-- Discord: DrSpeedy#1852
-- https://github.com/DrSpeedy
require 'lib/natives-1627063482'

local menuIdTbl = {}
keys = {}
keys['X'] = 193
keys['LB'] = 185
keys['RB'] = 183
keys['LT'] = 207
keys['RT'] = 208
keys['R3'] = 184
keys['L3'] = 28
keys['LEFT_AN_DOWN'] = 196
keys['LEFT_AN_UP'] = 32

require 'store/Speedy/util'
require 'store/Speedy/superflight_options'
require 'store/Speedy/debug_options'

-- Super Run variables
local sr_speed_limit = 120
local sr_base_speed = 10
local sr_accel_mult = 0.77
local sr_brake_mult = 0.66

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

local function DoSuperRun(toggle)
	local is_super_running = false

	-- Our current speed multiplier, this will be increased as the player speeds up
	local speed_mult = sr_base_speed

	util.create_tick_handler(function()
		if (toggle) then
			-- Local variables needed updated each tick
			local player = PLAYER.PLAYER_PED_ID()
			local velocity = ENTITY.GET_ENTITY_VELOCITY(player)
			local direction = ENTITY.GET_ENTITY_FORWARD_VECTOR(player)
			local sprinting = TASK.IS_PED_SPRINTING(player)
			local ragdoll = PED.IS_PED_RAGDOLL(player)
			local falling = PED.IS_PED_FALLING(player)
			local swimming = PED.IS_PED_SWIMMING(player)
			local parastate = PED.GET_PED_PARACHUTE_STATE(player)
			local grounddistance = ENTITY.GET_ENTITY_HEIGHT_ABOVE_GROUND(player)

			if (PAD.IS_CONTROL_PRESSED(2, keys['RB']) and sprinting and not (parastate == 0)) then
				if not (PED.IS_PED_IN_ANY_VEHICLE(player, true) or falling or ragdoll) then
					is_super_running = true

					-- Mimic acceleration by increasing speed_mult by sr_accel_mult each tick
					if (speed_mult <= sr_speed_limit) then
						speed_mult = speed_mult + sr_accel_mult
					end

					-- Set up our velocity vector
					local vx = direction.x * speed_mult
					local vy = direction.y * speed_mult
					local vz = 0

					-- Help player stay on ground (kinda) after hitting bumps
					if (grounddistance > 1 and not swimming) then
						vz = velocity.z - 2
					else
						vz = velocity.z
					end

					-- Set the players running velocity
					ENTITY.SET_ENTITY_VELOCITY(player, vx, vy, vz)
				end
			else
				-- Applies the initial braking force to the player at full run when activation button is let go of
				if (is_super_running and not (falling or ragdoll)) then
					is_super_running = false

					velocity = ENTITY.GET_ENTITY_VELOCITY(player)
					ENTITY.SET_ENTITY_VELOCITY(player, (velocity.x*sr_brake_mult), (velocity.y*sr_brake_mult), velocity.z)
				end

				-- Bring the speed_mult down if the player is not running at all
				if (speed_mult > sr_base_speed) then
					speed_mult = speed_mult - sr_brake_mult
					if (speed_mult < sr_base_speed) then
						speed_mult = sr_base_speed
					end
				end
			end
		end
	end)
end

local function MenuSuperRunSetup(menu_root)
    menu.divider(menu_root, '-------------Speedy\'s Super Run-------------')

    menu.slider(menu_root, 'Speed Limit', {}, '', 0, 200, sr_speed_limit, 1, function(value, prev_value, click_type) 
        sr_speed_limit = value
    end)

    menu.slider_float(menu_root, 'Acceleration Multiplyer', {}, '', 0, 1000, sr_accel_mult * 100, 10, function(value, prev_value, click_type) 
        sr_accel_mult = value / 100
    end)

    menu.slider_float(menu_root, 'Brake Multiplyer', {}, '', 0, 1000, sr_brake_mult * 100, 10, function(value, prev_value, click_type) 
        sr_brake_mult = value / 100
    end)

    menu.divider(menu_root, '---------------------------------------------')

    menu.toggle(menu_root, 'Super Run Enabled', {}, '', function(toggle) DoSuperRun(toggle) end)
end

local function MenuSelfSetup(menu_root)
    -- Self Menu
    menuIdTbl['Super Run'] = menu.list(menu_root, 'Super Run', {}, '')
    menuIdTbl['Super Flight'] = menu.list(menu_root, 'Super Flight', {}, '')
    menu.toggle(menu_root, 'Super Jump', {}, '', function(toggle) DoSuperJump(toggle) end)
end

local function Init()
    -- Main Menu
    menuIdTbl['Self'] = menu.list(menu.my_root(), 'Self', {}, '')
    menuIdTbl['Debug'] = menu.list(menu.my_root(), 'Debug', {}, '')

    MenuSelfSetup(menuIdTbl['Self'])
    MenuSuperRunSetup(menuIdTbl['Super Run'])
    MenuSuperFlightSetup(menuIdTbl['Super Flight'])
    MenuDebugOptionsSetup(menuIdTbl['Debug'])
end

Init()

while true do  
	util.yield()
end