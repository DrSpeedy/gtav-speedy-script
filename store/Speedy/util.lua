---@diagnostic disable: deprecated
-- DrSpeedy#1852
-- https://github.com/DrSpeedy

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