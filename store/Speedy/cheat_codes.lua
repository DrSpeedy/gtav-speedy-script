-- DrSpeedy#1852
-- https://github.com/DrSpeedy

local bCheatHandlerEnabled = false
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

function RegisterCheat(sequence_str, callback)
    local f = function ()
        if (CheckInput('[F]SEQ(' .. sequence_str .. ')')) then
            callback()
        end
    end
    tCheatFuncs[#tCheatFuncs+1] = f
end

RegisterCheat('Y,Y,X,B,A', function ()
    menu.trigger_commands('vehiclenigasaki')
end)

RegisterCheat('Y,Y,X,A,A', function ()
    menu.trigger_commands('vehiclekrieger')
end)

RegisterCheat('B,B,X,B,Y', function ()
    menu.trigger_commands('vehiclestuntmolotok')
end)