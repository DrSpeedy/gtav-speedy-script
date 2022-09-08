-- DrSpeedy#1852
-- https://github.com/DrSpeedy

local sSelectedPlayer = ''
local tPlayerData = {}

local function HandlePlayerOptAction(player_id, key)
    if (players.exists(player_id)) then
        if (key == 'Online.Toast') then
            Notification('Test: ' .. PLAYER.GET_PLAYER_NAME(player_id))
        end
        if (key == 'Online.GiveLoadout') then
            LoadWeaponsFromFile(PLAYER.GET_PLAYER_PED(player_id), 'test')
            menu.trigger_commands('ammo' .. players.get_name(player_id):lower())
            Notification('Giving weapons to ' .. players.get_name(player_id))
        end
        if (key == 'Online.Kick') then
            menu.trigger_commands('kick' .. players.get_name(player_id):lower())
        end
    else
        Notification('Player no longer in session')
    end
end

local function HandleAllPlayerOptAction(key)
    local player_list = players.list(true, true, true)
    for i = 1, #player_list do
        HandlePlayerOptAction(player_list[i], key)
    end
end

local function BuildPlayerList(key)
    local player_list = players.list(true, true, true)
    tPlayerData[1] = menu.action(menuIdTbl[key], 'All Players', {}, '', function() HandleAllPlayerOptAction(key) end)
    for i = 1, #player_list do
        local j = i + 1
        tPlayerData[j] = menu.action(menuIdTbl[key], players.get_name_with_tags(player_list[i]), {}, '', function() HandlePlayerOptAction(player_list[i], key) end)
    end
    return tPlayerData
end

local function CleanPlayerList()
    menu.delete(tPlayerData[1]) -- All players
    for i = 2, #tPlayerData do
        menu.delete(tPlayerData[i])
    end
end

local function AddQuickAction(title, command_table, help_text, key)
    menuIdTbl[key] = menu.list(menuIdTbl['Online'], title, command_table, help_text, function() BuildPlayerList(key) end, function() CleanPlayerList() end)
end

function MenuOnlineQuickOptsSetup(menu_root)
    menuIdTbl['Online'] = menu.list(menu_root, 'Online Player Quick Actions', {}, '')
    AddQuickAction('Toast test', {}, '', 'Online.Toast')
    AddQuickAction('Give Loadout', {}, '', 'Online.GiveLoadout')
    AddQuickAction('Kick', {}, '', 'Online.Kick')
end