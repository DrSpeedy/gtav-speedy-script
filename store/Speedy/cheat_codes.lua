-- DrSpeedy#1852
-- https://github.com/DrSpeedy

local bCheatHandlerEnabled = false
local tCheatMenuOpts = {}
local tCheatFuncs = {}

function StartCheatHandler()
    bCheatHandlerEnabled = true
    util.create_tick_handler(function()
        for i = 1, #tCheatFuncs do
            tCheatFuncs[i]()
        end
        return bCheatHandlerEnabled
    end)
end

function StopCheatHandler()
    bCheatHandlerEnabled = false
end

--- TODO Refactor this with RegisterCheat
function RegisterKeybind(sequence_str, description, callback)
    local f = function ()
        if (CheckInput(sequence_str)) then
            Notification(description)
            callback()
        end
    end
    tCheatFuncs[#tCheatFuncs+1] = f
end

function RegisterCheat(sequence_str, description, callback)
    tCheatMenuOpts[sequence_str] = description
    local f = function ()
        if (CheckInput('[F]SEQ(' .. sequence_str .. ')')) then
            Notification('Cheat Code Activated.')
            callback()
        end
    end
    tCheatFuncs[#tCheatFuncs+1] = f
end

function MenuCheatSeqSetup(menu_root)
    for s,d in pairs(tCheatMenuOpts) do
        menu.readonly(menu_root, d, s)
    end
end

--RegisterKeybind('[T1]VK(45)', 'Load weapons', function ()
--    LoadWeaponsFromFile(players.user_ped(), 'test')
--end)

RegisterCheat('Y,Y,X,B,A', 'Nigasaki', function ()
    menu.trigger_commands('vehiclenigasaki')
end)

RegisterCheat('Y,Y,X,A,A', 'Krieger', function ()
    menu.trigger_commands('vehiclekrieger')
end)

RegisterCheat('B,B,X,B,Y', 'Molotok', function ()
    menu.trigger_commands('vehiclestuntmolotok')
end)

RegisterCheat('X,X,B,X,A', 'F-166', function ()
    menu.trigger_commands('vehiclef166')
end)

RegisterCheat('X,X,B,X,Y', 'Buzzard', function()
    menu.trigger_commands('vehiclebuzzard')
end)

