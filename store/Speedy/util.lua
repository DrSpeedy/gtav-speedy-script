---@diagnostic disable: deprecated
-- DrSpeedy#1852
-- https://github.com/DrSpeedy

function Notification(message)
	message = '[Test] ' .. message:gsub('[~]%w[~]', '')
	if not string.match(message, '[%.?]$') then message = message .. '.' end
	util.toast(message, TOAST_ABOVE_MAP)
end

function PointGameplayCamAtCoords(target_coords)
	local cam_pos = CAM.GET_GAMEPLAY_CAM_COORD()

	local dX = cam_pos.x - target_coords.x
	local dY = cam_pos.y - target_coords.y
	local dZ = cam_pos.z - target_coords.z
	local cam_rot = CAM.GET_GAMEPLAY_CAM_ROT(0)
	util.draw_debug_text('' .. cam_rot.x * (math.pi / 180) .. ' ' .. cam_rot.y * (math.pi / 180) .. ' ' .. cam_rot.z * (math.pi / 180))
	local t = v3.toRot(ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID()))
	util.draw_debug_text('' .. t.x .. ' ' .. t.y .. ' ' .. t.z)
	local target_heading = MISC.ATAN2(dY, dX) * (math.pi / 180) - (90 * math.pi/180)
	local target_pitch = -(MISC.ATAN2(dZ, math.sqrt(dX^2 + dY^2)) * (math.pi / 180))
	local target_roll = 0.0
	util.draw_debug_text('Pitch: ' .. target_pitch .. ' Yaw: ' .. target_heading)
	--CAM._SET_GAMEPLAY_CAM_RELATIVE_ROTATION(target_roll, target_pitch, target_heading)

end

-- Script(RAGE) global memory wrappers
function ReadGlobalByte(global)
	local address = memory.script_global(global)
	return address ~= 0 and memory.read_byte(address) or nil
end

function ReadGlobalInt(global)
    local address = memory.script_global(global)
    return address ~= 0 and memory.read_int(address) or nil
end

function ReadGlobalFloat(global)
    local address = memory.script_global(global)
    return address ~= 0 and memory.read_float(address) or nil
end

function ReadGlobalString(global)
    local address = memory.script_global(global)
    return address ~= 0 and memory.read_string(address) or nil
end

function WriteGlobalByte(global, value)
    local address = memory.script_global(global)
    if (address ~= 0) then memory.write_byte(address, value) end
end

function WriteGlobalInt(global, value)
    local address = memory.script_global(global)
    if (address ~= 0) then memory.write_int(address, value) end
end

function RotationToDirection(rotation) --https://forum.cfx.re/t/get-position-where-player-is-aiming/1903886/2
	local adjusted_rotation =
	{
		x = (math.pi / 180) * rotation.x,
		y = (math.pi / 180) * rotation.y,
		z = (math.pi / 180) * rotation.z
	}
	local direction =
	{
		x = -math.sin(adjusted_rotation.z) * math.abs(math.cos(adjusted_rotation.x)),
		y =  math.cos(adjusted_rotation.z) * math.abs(math.cos(adjusted_rotation.x)),
		z =  math.sin(adjusted_rotation.x)
	}
	return direction
end

function GetOffsetFromCam(distance)
	local cam_rot = CAM.GET_GAMEPLAY_CAM_ROT(0)
	local cam_pos = CAM.GET_GAMEPLAY_CAM_COORD()
	local direction = RotationToDirection(cam_rot)
	local destination =
	{
		x = cam_pos.x + direction.x * distance,
		y = cam_pos.y + direction.y * distance,
		z = cam_pos.z + direction.z * distance
	}
	return destination
end

function GetDistanceBetweenCoords(vector1, vector2)
	local v1 = vector1
	local v2 = vector2

	return math.sqrt((v1.x - v2.x)^2 + (v1.y - v2.y)^2 + (v1.z - v2.z)^2)
end

function GetClosestPlayerToCoords(coords, max_distance, ignore_self)
	local player_list = players.list(not ignore_self, true, true)
	local shortest_distance = 10000000
	local shortest_dist_player = -1

    for i = 1, #player_list do
        local player = player_list[i]
		local player_ped = PLAYER.GET_PLAYER_PED(player)
		local player_coords = ENTITY.GET_ENTITY_COORDS(player_ped)
		local dist = GetDistanceBetweenCoords(coords, player_coords)
		GRAPHICS.DRAW_LINE(coords.x, coords.y, coords.z, player_coords.x, player_coords.y, player_coords.z, 255, 255, 0, 255)
		if (shortest_distance > dist and max_distance >= dist) then
			shortest_distance = dist
			shortest_dist_player = player
		end
    end
	return shortest_dist_player
end

function GetClosestPedToCoords(coords, radius, include_peds, include_self, include_friends, include_players)
	local ped_list = entities.get_all_peds_as_handles()
	local shortest_distance = 10000000
	local shortest_dist_ped = -1
	local player_id = -1
	local player_name = ''
	local session_players = players.list(include_self, include_friends, include_players)

    for i = 1, #ped_list do
        local ped = ped_list[i]
		player_id = -1
		player_name = ''

		if (ENTITY.IS_ENTITY_DEAD(ped)) then
			continue
		end
		if (not PED.IS_PED_A_PLAYER(ped) and not include_peds) then
			continue
		end
		if (PED.IS_PED_A_PLAYER(ped)) then
			local player_on_list = false
			for j = 1, #session_players do
				if (ped == PLAYER.GET_PLAYER_PED(session_players[j])) then
					player_on_list = true
					break
				end
			end
			if (not player_on_list) then
				continue
			end
		end
		if (ped == players.user_ped() and not include_self) then
			continue
		end

		if (ped ~= -1) then
			local ped_coords = ENTITY.GET_ENTITY_COORDS(ped)
			local dist = GetDistanceBetweenCoords(ped_coords, coords)

			if (shortest_distance > dist and radius >= dist) then
				shortest_distance = dist
				shortest_dist_ped = ped
			end
		end
    end
	return {
		iPedId = shortest_dist_ped,
		iPlayerId = player_id,
		sPlayerName = player_name,
		v3Coords = ENTITY.GET_ENTITY_COORDS(shortest_dist_ped),
		v3FVec = ENTITY.GET_ENTITY_FORWARD_VECTOR(shortest_dist_ped)
	}
end

function StartShapeTest(start_v3, end_v3, flags, entity_to_ignore, p8)
	return SHAPETEST.START_EXPENSIVE_SYNCHRONOUS_SHAPE_TEST_LOS_PROBE(
		start_v3.x,
		start_v3.y,
		start_v3.z,
		end_v3.x,
		end_v3.y,
		end_v3.z,
		flags,
		entity_to_ignore,
		p8
	)
end

function GetShapeTestResult(shapetest_id)
	local ptr_hit = memory.alloc(1) 		-- BOOL
	local ptr_v3 = memory.alloc(24) 		-- Vector3
	local ptr_v3_surface = memory.alloc(24) -- Vector3
	local ptr_entity = memory.alloc(4) 		-- INT

	local result = 1
	while result == 1 do
		result = SHAPETEST.GET_SHAPE_TEST_RESULT(shapetest_id, ptr_hit, ptr_v3, ptr_v3_surface, ptr_entity)
	end

	local data = {
		bHit = memory.read_byte(ptr_hit) == 1,
		v3Coords = memory.read_vector3(ptr_v3),
		v3SurfaceNormal = memory.read_vector3(ptr_v3_surface),
		Entity = memory.read_int(ptr_entity)
	}
	return data
end

function ShootPedInHead(ped, weapon_hash, damage)
	local hash = util.joaat(weapon_hash)
	-- Wait while assets load
	if not (WEAPON.HAS_WEAPON_ASSET_LOADED(hash)) then
		WEAPON.REQUEST_WEAPON_ASSET(hash, 31, 26)
		while not (WEAPON.HAS_WEAPON_ASSET_LOADED(hash)) do
			util.yield()
		end
	end

	local t1 = PED.GET_PED_BONE_COORDS(ped, 31086, 0.01, 0, 0)
	local t2 = PED.GET_PED_BONE_COORDS(ped, 31086, -0.01, 0, 0)
	local pveh = PED.GET_VEHICLE_PED_IS_IN(players.user_ped(), false)
	MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS_IGNORE_ENTITY(t1.x, t1.y, t1.z, t2.x, t2.y, t2.z, damage, true, hash, players.user_ped(), true, true, 10000, pveh)
end

function TeleportPed(ped, coords, rotation, with_vehicle)
	local entity = 0

	if (with_vehicle and PED.IS_PED_IN_ANY_VEHICLE(ped, true)) then
		entity = PED.GET_VEHICLE_PED_IS_IN(ped, false)
	end

	if (not ENTITY.IS_ENTITY_A_VEHICLE(entity)) then
		entity = ped
	end

	ENTITY.SET_ENTITY_COORDS(entity, coords)
	if (rotation ~= nil) then
		ENTITY.SET_ENTITY_ROTATION(entity, rotation.x, rotation.y, rotation.z, 0, true)
	end
end

function DrawDebugLine(pos1, pos2, rgba)
	GRAPHICS.DRAW_LINE(pos1.x, pos1.y, pos1.z, pos2.x, pos2.y, pos2.z, rgba.r, rgba.g, rgba.b, rgba.a)
end