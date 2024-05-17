local bAimbotEnabled = true
local bTargetPlayers = true
local bTargetNPCs = true
local bTargetFriends = false
local bUseFOV = true

local aIgnoreWeaponList = {
    -1813897027,    -- Grenade
    741814745,      -- StickyBomb
    -1420407917,    -- ProximityMine
    -1600701090,    -- BZGas
    615608432,      -- Molotov
    101631238,      -- FireExtinguisher
    883325847,      -- PetrolCan
    1233104067,     -- Flare
    600439132,      -- Ball
    126349499,      -- Snowball
    -37975472,      -- SmokeGrenade
    -1169823560,    -- Pipebomb
    -1568386805,    -- GrenadeLauncher  
    -1312131151,    -- RPG
    2138347493,     -- Firework
    1672152130,     -- HomingLauncher
    1305664598,     -- GrenadeLauncherSmoke
    125959754       -- CompactLauncher
}

local function DoAimbot(toggle)
    bAimbotEnabled = toggle
    util.create_tick_handler(function()
        if (PED.IS_PED_SHOOTING(players.user_ped())) then
            local max_distance = 10000

            local cam_pos = CAM.GET_GAMEPLAY_CAM_COORD()
            local ofst_pos = GetOffsetFromCam(max_distance)
            local shape_test = StartShapeTest(cam_pos, ofst_pos, 319, 0, 7)
            local data = GetShapeTestResult(shape_test)

            local target = {}
            if (data.bHit) then
                target = GetClosestPedToCoords(data.v3Coords, 20, bUseFOV, bTargetNPCs, false, bTargetFriends, bTargetPlayers)
            else
                target = GetClosestPedToCoords(GetOffsetFromCam(50), 45, bUseFOV, bTargetNPCs, false, bTargetFriends, bTargetPlayers)
                -- If we can't see them, don't target
                -- Only LOS on this backup one as it targets a very wide area
                -- May add LOS to other later on depending how well this works
                if (not ENTITY.HAS_ENTITY_CLEAR_LOS_TO_ENTITY(players.user_ped(), target)) then
                    target.iPedId = -1
                end
            end
            if (target.iPedId ~= -1) then
                local weapon = WEAPON.GET_SELECTED_PED_WEAPON(players.user_ped())
                local dmg = WEAPON.GET_WEAPON_DAMAGE(weapon, 0)
                local shoot = true
                for h = 1, #aIgnoreWeaponList do
                    if (aIgnoreWeaponList[h] == weapon) then
                        shoot = false
                        break
                    end
                end
                if (shoot) then
                    ShootPedInHead(target.iPedId, weapon, dmg)
                end
            end
        end
        return bAimbotEnabled
    end)
end

function MenuSetupSelfAimbot(menu_root)
    menu.toggle(menu_root, 'Enable Aimbot', {}, '', function(toggle) DoAimbot(toggle) end)
    menu.toggle(menu_root, 'Use FOV', {}, '', function(toggle) bUseFOV = toggle end)
    menu.toggle(menu_root, 'Toggle Players', {}, '', function(toggle) bTargetPlayers = toggle end)
    menu.toggle(menu_root, 'Toggle NPCs', {}, '', function(toggle) bTargetNPCs = toggle end)
    menu.toggle(menu_root, 'Toggle Friends', {}, '', function(toggle) bTargetFriends = toggle end)
end