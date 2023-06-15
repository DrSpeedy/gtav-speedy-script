-- DrSpeedy#1852
-- https://github.com/DrSpeedy

---Toast Notification
---@param message string
function Notification(message)
	message = '[SpeedyScript] ' .. message:gsub('[~]%w[~]', '')
	if not string.match(message, '[%.?]$') then message = message .. '.' end
	util.toast(message, TOAST_ABOVE_MAP)
end

-- Script(RAGE) global memory wrappers

---Read script global as byte
---@param global integer address
---@return integer|nil pointer or nil
function ReadGlobalByte(global)
	local address = memory.script_global(global)
	return address ~= 0 and memory.read_byte(address) or nil
end

---Read script global as int
---@param global integer address
---@return integer|nil pointer or nil
function ReadGlobalInt(global)
    local address = memory.script_global(global)
    return address ~= 0 and memory.read_int(address) or nil
end

---Read script global as float
---@param global integer address
---@return integer|nil pointer or nil
function ReadGlobalFloat(global)
    local address = memory.script_global(global)
    return address ~= 0 and memory.read_float(address) or nil
end

---Read script global as string
---@param global integer address
---@return string|nil pointer or nil
function ReadGlobalString(global)
    local address = memory.script_global(global)
    return address ~= 0 and memory.read_string(address) or nil
end

---Write byte to script global
---@param global integer address
---@param value any byte
function WriteGlobalByte(global, value)
    local address = memory.script_global(global)
    if (address ~= 0) then memory.write_byte(address, value) end
end

---Write int to script global
---@param global integer address
---@param value integer int
function WriteGlobalInt(global, value)
    local address = memory.script_global(global)
    if (address ~= 0) then memory.write_int(address, value) end
end

---Rotation vector to direction vector
---https://forum.cfx.re/t/get-position-where-player-is-aiming/1903886/2
---@param rotation userdata vector3
---@return userdata vector3 direction
function RotationToDirection(--[[v3]] rotation)
	local adjusted_rotation =
	{
		x = (math.pi / 180) * rotation.x,
		y = (math.pi / 180) * rotation.y,
		z = (math.pi / 180) * rotation.z
	}
	local direction = v3.new(
		-math.sin(adjusted_rotation.z) * math.abs(math.cos(adjusted_rotation.x)),
		math.cos(adjusted_rotation.z) * math.abs(math.cos(adjusted_rotation.x)),
		math.sin(adjusted_rotation.x)
	)
	return direction
end

---Get coordinate vector for position X distance out from the camera
---@param distance number distance
---@return userdata vector3 coordinates
function GetOffsetFromCam(--[[int]] distance)
	local cam_rot = CAM.GET_GAMEPLAY_CAM_ROT(0)
	local cam_pos = CAM.GET_GAMEPLAY_CAM_COORD()
	local direction = RotationToDirection(cam_rot)
	local destination = v3.new(
		cam_pos.x + direction.x * distance,
		cam_pos.y + direction.y * distance,
		cam_pos.z + direction.z * distance
	)
	return destination
end

---Distance between two coordinate vectors
---@param vector1 userdata source vector3
---@param vector2 userdata target vector3
---@return number
function GetDistanceBetweenCoords(--[[v3]] vector1,--[[v3]] vector2)
	local v1 = vector1
	local v2 = vector2
	return math.sqrt((v1.x - v2.x)^2 + (v1.y - v2.y)^2 + (v1.z - v2.z)^2)
end

---Deprecated use GetClosestPedToCoords() instead
---@param coords userdata vector3
---@param max_distance number search radius
---@param ignore_self boolean ignore self in search
---@return integer integer player id closest to coordinates or -1
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

---Get closest Ped entity to a set of coordinates and return a table of data about them
---@param coords userdata coordinate vector3
---@param radius number search radius
---@param use_fov boolean require ped to be within FOV
---@param include_peds boolean include AI pedestrians in search
---@param include_self boolean include self in search
---@param include_friends boolean include friends in search
---@param include_players boolean include players/strangers in search
---@return table table Returns table with target's Ped handle, Network ID, Network Name, Coord V3, Forward V3
function GetClosestPedToCoords(coords, radius, use_fov, include_peds, include_self, include_friends, include_players)
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
		if (use_fov and not PED.IS_PED_FACING_PED(players.user_ped(), ped, 45)) then
			continue
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

---Wrapper function for SHAPETEST.START_EXPENSIVE_SYNCHRONOUS_SHAPE_TEST_LOS_PROBE
---@param start_v3 userdata vector3 coordinates
---@param end_v3 userdata vector3 coordinates
---@param flags integer shapetest flags
---@param entity_to_ignore integer entity handle
---@param p8 integer p8
---@return integer integer shapetest handle
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

---Get results of StartShapeTest()
---@param shapetest_id integer shapetest handle
---@return table table Returns bHit, v3Coords, v3SurfaceNormal and Entity handle
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

---Load weapon asset from id string
---@param weapon_id string weapon id
---@return integer integer joaat hash
function LoadWeaponAsset(weapon_id)
	local hash = util.joaat(weapon_id)
	while not (WEAPON.HAS_WEAPON_ASSET_LOADED(hash)) do
		WEAPON.REQUEST_WEAPON_ASSET(hash, 31, 26)
		while not (WEAPON.HAS_WEAPON_ASSET_LOADED(hash)) do
			util.yield()
		end
	end
	return hash
end

---To get offset at where a projectile will hit a moving target:
---target_coords_v3 + (target_velocity_v3 * delta)
---https://www.gamedeveloper.com/programming/shooting-a-moving-target
---@param source_entity integer source entity handle
---@param target_entity integer target entity handle
---@param proj_speed number projectile speed
---@return number delta multiplier needed for aim ahead calculation
function GetAimAheadDelta(source_entity, target_entity, proj_speed)
	local spos = ENTITY.GET_ENTITY_COORDS(source_entity)
	local svel = ENTITY.GET_ENTITY_VELOCITY(source_entity)
	local tvel = ENTITY.GET_ENTITY_VELOCITY(target_entity)
	local tpos = ENTITY.GET_ENTITY_COORDS(target_entity)

	local delta = tpos
	delta:sub(spos)
	local vr = tvel
	vr:sub(svel)

	local a = v3.dot(vr, vr) - proj_speed^2
	local b = 2*v3.dot(vr, delta)
	local c = v3.dot(delta, delta)

	local desc = b^2 - 4*a*c

	if (desc > 0) then
		return 2*c / (math.sqrt(desc) - b)
	else
		return -1
	end
end

---Fire bullet into the back of a ped's head
---@param ped integer ped handle
---@param weapon_hash integer weapon joaat hash
---@param damage number weapon damage
function ShootPedInHead(ped, weapon_hash, damage)
	local t1 = PED.GET_PED_BONE_COORDS(ped, 31086, 0, -0.1, 0)
	local t2 = PED.GET_PED_BONE_COORDS(ped, 31086, 0, 0.1, 0)
	local pveh = PED.GET_VEHICLE_PED_IS_IN(players.user_ped(), false)
	MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS_IGNORE_ENTITY(t1.x, t1.y, t1.z, t2.x, t2.y, t2.z, damage, true, weapon_hash, players.user_ped(), false, true, 10000, pveh)
end

---More generic function than ShootPedInHead() can target vehicles/peds/any entity
---@param entity integer entity handle
---@param weapon_hash integer weapon joaat hash
---@param damage number weapon damage
function ShootAtEntity(entity, weapon_hash, damage)
	local t2 = ENTITY.GET_ENTITY_COORDS(entity)
	local t1 = t2
	t1.z = t1.z + 0.1
	MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(t1.x, t1.y, t1.z, t2.x, t2.y, t2.z, damage, true, weapon_hash, players.user_ped(), true, false, 10000)
end

---Teleport pedestrian with or without their vehicle
---@param ped integer ped handle
---@param coords userdata vector3
---@param rotation userdata vector3
---@param with_vehicle boolean boolean
function TeleportPed(ped, coords, rotation, with_vehicle)
	local keep_velocity = true
	local entity = 0
	local speed = 0
	local vel = v3.new()

	if (with_vehicle and PED.IS_PED_IN_ANY_VEHICLE(ped, true)) then
		entity = PED.GET_VEHICLE_PED_IS_IN(ped, false)
	end

	if (not ENTITY.IS_ENTITY_A_VEHICLE(entity)) then
		entity = ped
	end

	if (keep_velocity) then
		if (ENTITY.IS_ENTITY_A_VEHICLE(entity)) then
			speed = ENTITY.GET_ENTITY_SPEED(entity)
		else
			vel = ENTITY.GET_ENTITY_VELOCITY(entity)
		end
	end

	ENTITY.SET_ENTITY_COORDS(entity, coords.x, coords.y, coords.z)
	if (rotation ~= nil) then
		ENTITY.SET_ENTITY_ROTATION(entity, rotation.x, rotation.y, rotation.z, 0, true)
	end

	if (keep_velocity) then
		if (ENTITY.IS_ENTITY_A_VEHICLE(entity)) then
			VEHICLE.SET_VEHICLE_FORWARD_SPEED(entity, speed)
		else
			local boost = ENTITY.GET_ENTITY_FORWARD_VECTOR(entity)
			boost:mul(10)
			ENTITY.SET_ENTITY_VELOCITY(entity, vel.x + boost.x, vel.y + boost.y, vel.z + boost.z)
		end
	end
end

---Wrapper function for GRAPHICS.DRAW_LINE()
---@param pos1 userdata vector3
---@param pos2 userdata vector3
---@param rgba table RGBA table
function DrawDebugLine(pos1, pos2, rgba)
	GRAPHICS.DRAW_LINE(pos1.x, pos1.y, pos1.z, pos2.x, pos2.y, pos2.z, rgba.r, rgba.g, rgba.b, rgba.a)
end

---Request control over network entity
---@param entity integer
---@return boolean
function RequestControlOfNetworkEntity(entity)
	if (not NETWORK.NETWORK_IS_IN_SESSION()) then
		return true
	end
	local id = NETWORK.NETWORK_GET_NETWORK_ID_FROM_ENTITY(entity)
	NETWORK.SET_NETWORK_ID_CAN_MIGRATE(id, true)
	return NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(entity)
end

---In game coordinates to 2D screen coordinates
---@param coords userdata vector3
---@return table vector2 screen coordinates
function WorldToScreen(coords)
	local x_ptr = memory.alloc(8)
	local y_ptr = memory.alloc(8)
	GRAPHICS.GET_SCREEN_COORD_FROM_WORLD_COORD(coords.x, coords.y, coords.z, x_ptr, y_ptr)
	return {
		x = memory.read_float(x_ptr),
		y = memory.read_float(y_ptr)
	}
end