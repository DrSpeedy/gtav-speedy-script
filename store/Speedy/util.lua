---@diagnostic disable: deprecated
-- DrSpeedy#1852
-- https://github.com/DrSpeedy

function Notification(message)
	message = '[Test] ' .. message:gsub('[~]%w[~]', '')
	if not string.match(message, '[%.?]$') then message = message .. '.' end
	util.toast(message, TOAST_ABOVE_MAP)
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

function GetClosestPlayerToCoords(coords, max_distance)
	local player_list = players.list(true, true, true)
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