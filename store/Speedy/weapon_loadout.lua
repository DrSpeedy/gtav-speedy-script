-- DrSpeedy#1852
-- https://github.com/DrSpeedy

function LoadWeaponsFromFile(ped, profile)
    local path = 'Speedy/Loadouts/' .. profile
    if (filesystem.exists(filesystem.store_dir() .. path .. '.lua')) then
        local weapons = require('store/' .. path)
        WEAPON.REMOVE_ALL_PED_WEAPONS(ped, false)
        WEAPON._SET_CAN_PED_EQUIP_ALL_WEAPONS(ped, true)
        for weapon, attachments in pairs(weapons) do
            WEAPON.GIVE_WEAPON_TO_PED(ped, weapon, 10, false, true)
            for i, attachment in pairs(attachments) do
                if (i ~= 'tint') then
                    WEAPON.GIVE_WEAPON_COMPONENT_TO_PED(ped, weapon, attachment)
                else
                    WEAPON.SET_PED_WEAPON_TINT_INDEX(ped, weapon, attachment)
                end
                util.yield(10)
            end
            local ptr_ammo_max = memory.alloc_int()
            WEAPON.GET_MAX_AMMO(ped, weapon, ptr_ammo_max)
            local ammo_max = memory.read_int(ptr_ammo_max)
            WEAPON.SET_PED_AMMO(ped, weapon, ammo_max)
        end
        package.loaded['store/' .. path] = nil
    else
        Notification('file not found')
    end
end

function MenuWeaponLoadoutSetup(menu_root)
    menu.action(menu_root, 'Test Load Loadout', {}, '', function() LoadWeaponsFromFile(players.user_ped(), 'test') end)
end