---@diagnostic disable: undefined-global
-- DrSpeedy#1852
-- https://github.com/DrSpeedy

local bSuperFlightEnabled = false
local bSuperFlightWeaponsEnabled = false
local bSuperFlightWeapAimbotEnabled = false
local aSpeedMults = {70, 110, 160, 300}

local function DoSuperFlight(toggle)
    bSuperFlightEnabled = toggle
    util.create_tick_handler(function()
        if (bSuperFlightEnabled) then
			local player = PLAYER.PLAYER_PED_ID()
			local playerped = PLAYER.GET_PLAYER_PED(player)

			local velocity = ENTITY.GET_ENTITY_VELOCITY(player)
			local direction = ENTITY.GET_ENTITY_FORWARD_VECTOR(player)

			local grounddistance = ENTITY.GET_ENTITY_HEIGHT_ABOVE_GROUND(player)
			local parastate = PED.GET_PED_PARACHUTE_STATE(player)

			local ragdoll = PED.IS_PED_RAGDOLL(player)
			local jumping = PED.IS_PED_JUMPING(player)
			local falling = PED.IS_PED_FALLING(player)
			ENTITY.SET_ENTITY_MAX_SPEED(player,500)
			ENTITY.SET_ENTITY_MAX_SPEED(playerped,500)
			
			if not (CheckInput('[D]LT')) then
				-- Start Skydiving w/ either pressing R3 while ~3m off the ground
				if (parastate ~= 0 and grounddistance > 3) then
					if (jumping or falling or ragdoll) then
						if (CheckInput('[D]R3')) then -- R3
							TASK.TASK_SKY_DIVE(player)
						end
					end
				end

				if (parastate == 0) then
					local vz = velocity.z + 0.275
					local phase = 1

					-- Boost p1
					if (CheckInput('[D]RB')) then
						phase = 2
						vz = direction.z * aSpeedMults[phase]
					end

					-- Boost p2
					if (CheckInput('[D]LB')) then
						phase = 3
						vz = direction.z * aSpeedMults[phase]
					end
CheckInput()
					-- Boost p3
					if (CheckInput('[D]LB:[D]RB')) then
						phase = 4
						vz = direction.z * aSpeedMults[phase]
					end

					local vx = direction.x * aSpeedMults[phase]
					local vy = direction.y * aSpeedMults[phase]

					-- Move player up Z-axis faster while stick in down position
					if (velocity.z < aSpeedMults[phase] and PAD.IS_CONTROL_PRESSED(2, keys['LEFT_AN_DOWN'])) then
						vz = velocity.z + (0.03 * aSpeedMults[phase])
						--[[if (phase == 1) then
							vz = velocity.z + 1.5
						else
							vz = velocity.z + (0.03 * aSpeedMults[phase])
						end]]
					end
					-- Flight
					ENTITY.SET_ENTITY_VELOCITY(player, vx, vy, vz)
				end
			end
		end
		return bSuperFlightEnabled
    end)
end

local function DoMainWeapons(toggle)
	bSuperFlightWeaponsEnabled = toggle
	local fire_mode = 1 -- MG or ROCKETS
	local weapon_tbl = {
		{
			name = 'MG',
			id = 'VEHICLE_WEAPON_DOGFIGHTER_MG',
			speed = 10000
		},
		{
			name = 'CANNON',
			id = 'VEHICLE_WEAPON_PLAYER_LAZER',
			speed = 10000
		}
	}

	util.create_tick_handler(function()
		local player = PLAYER.PLAYER_PED_ID()
		local parastate = PED.GET_PED_PARACHUTE_STATE(player)
		if (parastate == 0) then
			local pcoords = ENTITY.GET_ENTITY_COORDS(player)
			local pfv = ENTITY.GET_ENTITY_FORWARD_VECTOR(player)
			local tcoords = GetOffsetFromCam(100)

			if (CheckInput('[T2]B')) then
				fire_mode = fire_mode + 1
				if (fire_mode > #weapon_tbl) then
					fire_mode = 1
				end
			end
			local hash = LoadWeaponAsset(weapon_tbl[fire_mode])
			util.draw_debug_text('Fire Mode: [' .. weapon_tbl[fire_mode] .. ']')

			if (bSuperFlightWeapAimbotEnabled) then
				local target_ped = GetClosestPedToCoords(tcoords, 200, false, true, false, false, true)
				if (ENTITY.IS_ENTITY_A_PED(target_ped.iPedId)) then
					DrawDebugLine(target_ped.v3Coords, pcoords, {r=255,g=50,b=50,a=255})
					tcoords = target_ped.v3Coords
					local delta = GetAimAheadDelta(player, target_ped.iPedId, 1500)
					if (delta > 0) then
						local tvel = ENTITY.GET_ENTITY_VELOCITY(target_ped.iPedId)
						tvel:mul(delta)
						tcoords:add(tvel)
					end
					util.draw_ar_beacon(tcoords)
				end
			end

			if (CheckInput('[D]RT')) then
				MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(
					pcoords.x+(pfv.x*5), pcoords.y+(pfv.y*5), pcoords.z+(pfv.z*5),
					tcoords.x, tcoords.y, tcoords.z,
					WEAPON.GET_WEAPON_DAMAGE(hash),
					true,
					hash,
					player,
					true, true, 1500
				)
			end
			if not (PED.IS_PED_IN_ANY_VEHICLE(player, true)) then
				PLAYER.DISABLE_PLAYER_FIRING(player, true)
			end

		end
		return bSuperFlightWeaponsEnabled
	end)
end

function MenuSuperFlightSetup(menu_root)
    menu.slider(menu_root, 'Idle Speed', {}, '', 0, 200, aSpeedMults[1], 1, function(value, prev_value, on_click)
        aSpeedMults[1] = value
    end)

    menu.slider(menu_root, 'Phase #1 Speed', {}, '', 0, 200, aSpeedMults[2], 1, function(value, prev_value, on_click)
        aSpeedMults[2] = value
    end)

    menu.slider(menu_root, 'Phase #2 Speed', {}, '', 0, 200, aSpeedMults[3], 1, function(value, prev_value, on_click)
        aSpeedMults[3] = value
    end)

    menu.slider(menu_root, 'Phase #3 Speed', {}, '', 0, 200, aSpeedMults[4], 1, function(value, prev_value, on_click)
        aSpeedMults[4] = value
    end)

    menu.divider(menu_root, '---------------------------------------------')

    menu.toggle(menu_root, 'Super Flight Enabled', {}, '', function(toggle) DoSuperFlight(toggle) end)
	menu.toggle(menu_root, 'Weapons Enabled', {}, '', function(toggle) DoMainWeapons(toggle) end)
	menu.toggle(menu_root, 'Weapons Lock-on Enabled', {}, '', function(toggle) bSuperFlightWeapAimbotEnabled = toggle end)
end