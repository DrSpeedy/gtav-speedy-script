---@diagnostic disable: undefined-global
-- Discord: DrSpeedy#1852
-- https://github.com/DrSpeedy

SCRIPT_VERSION = '0.1.1'
util.require_natives('1627063482')

menuIdTbl = {}
keys = {}
keys['X'] = 193
keys['LB'] = 185
keys['RB'] = 183
keys['LT'] = 207
keys['RT'] = 208
keys['R3'] = 184
keys['L3'] = 28
keys['LEFT_AN_DOWN'] = 196
keys['LEFT_AN_UP'] = 32
keys['DPAD_DOWN'] = 48
keys['DPAD_UP'] = 42
keys['DPAD_RIGHT'] = 14

VK = {
    ['0'] = 48
}




-- Auto Updater from https://github.com/hexarobi/stand-lua-auto-updater
local status, auto_updater = pcall(require, "auto-updater")
if not status then
    local auto_update_complete = nil util.toast("Installing auto-updater...", TOAST_ALL)
    async_http.init("raw.githubusercontent.com", "/hexarobi/stand-lua-auto-updater/main/auto-updater.lua",
        function(result, headers, status_code)
            local function parse_auto_update_result(result, headers, status_code)
                local error_prefix = "Error downloading auto-updater: "
                if status_code ~= 200 then util.toast(error_prefix..status_code, TOAST_ALL) return false end
                if not result or result == "" then util.toast(error_prefix.."Found empty file.", TOAST_ALL) return false end
                filesystem.mkdir(filesystem.scripts_dir() .. "lib")
                local file = io.open(filesystem.scripts_dir() .. "lib\\auto-updater.lua", "wb")
                if file == nil then util.toast(error_prefix.."Could not open file for writing.", TOAST_ALL) return false end
                file:write(result) file:close() util.toast("Successfully installed auto-updater lib", TOAST_ALL) return true
            end
            auto_update_complete = parse_auto_update_result(result, headers, status_code)
        end, function() util.toast("Error downloading auto-updater lib. Update failed to download.", TOAST_ALL) end)
    async_http.dispatch() local i = 1 while (auto_update_complete == nil and i < 40) do util.yield(250) i = i + 1 end
    if auto_update_complete == nil then error("Error downloading auto-updater lib. HTTP Request timeout") end
    auto_updater = require("auto-updater")
end
if auto_updater == true then error("Invalid auto-updater lib. Please delete your Stand/Lua Scripts/lib/auto-updater.lua and try again") end

function CheckForUpdates(update_interval)
    local repo_url = 'https://raw.githubusercontent.com/DrSpeedy/gtav-speedy-script/master/'
    local rc_d = 'resources/Speedy/'
    local lib_d = 'lib/Speedy/'
    auto_updater.run_auto_update({
        source_url=repo_url .. '1. SpeedyScript.lua',
        script_relpath=SCRIPT_RELPATH,
        verify_file_begins_with='--',
        dependencies={
            {
                name='jet_hud/contact.png',
                source_url=repo_url .. rc_d .. 'contact.png',
                script_relpath=rc_d .. 'contact.png',
                check_interval=update_interval,
                is_required=true
            }
        }
    })
end

------

require 'lib/Speedy/Keys'
require 'store/Speedy/util'
require 'store/Speedy/pad_handler'
require 'store/Speedy/cheat_codes'
-- Self
require 'store/Speedy/superrun_options'
require 'store/Speedy/superflight_options'
require 'store/Speedy/aimbot'
require 'store/Speedy/self_menu_options'
-- Weapons
require 'store/Speedy/weapon_loadout'
-- Online
require 'store/Speedy/online_quick_opts'
-- Misc
require 'store/Speedy/debug_options'
require 'store/Speedy/about'

-- Flight HUD
require 'store/Speedy/flight_hud'

function IsPlayerPointing()
    -- skidded from wiriscript
    return ReadGlobalInt(4521801 + 930) == 3
end

function OnNewSession()
    Notification('New Session Loaded')
    -- Spawn vehicles outside of hanger
    CreateVehicle('infernus', {x=-2040.87,y=3166,z=33.31}, -175.6)
    CreateVehicle('sanchez', {x=-2045.62,y=3167.42,z=33.31}, 148.6)

    util.yield(10000)
    --LoadWeaponsFromFile(players.user_ped(), 'test')
end

function Init()
    CheckForUpdates(604800)
    StartPadHandler()
    StartCheatHandler()

    util.on_transition_finished(function()
        if NETWORK.NETWORK_IS_IN_SESSION() then
            OnNewSession()
        end
    end)

    -- Main Menu
    MenuWeaponLoadoutSetup(menu.my_root())
    --menu.toggle(menu.my_root(), 'Telekinesis', {}, '', function (toggle) DoTelekMode(toggle) end)

    menuIdTbl['Self'] = menu.list(menu.my_root(), 'Self', {}, '')
    menuIdTbl['FlightHUD'] = menu.list(menu.my_root(), 'Flight HUD', {}, '')
    MenuOnlineQuickOptsSetup(menu.my_root())
    menuIdTbl['Debug'] = menu.list(menu.my_root(), 'Debug', {}, '')
    menuIdTbl['Cheats'] = menu.list(menu.my_root(), 'Cheat Codes', {}, 'Cheat code reference')
    menuIdTbl['About'] = menu.list(menu.my_root(), 'About', {}, '')

    -- Self
    MenuSelfSetup(menuIdTbl['Self'])
    MenuSuperRunSetup(menuIdTbl['Self.Super Run'])
    MenuSuperFlightSetup(menuIdTbl['Self.Super Flight'])

    --- Flight Hud
    MenuFlightHUDSetup(menuIdTbl['FlightHUD'])
    MenuCheatSeqSetup(menuIdTbl['Cheats'])
    MenuDebugOptionsSetup(menuIdTbl['Debug'])
    MenuAboutSetup(menuIdTbl['About'])

    -- Updater
    --[[menu.action(menu.my_root(), 'Update Test', {}, '', function()
        CheckForUpdates()
    end)]]
    -- CheckForUpdates()
end

Init()
while true do
    -- Global script yield
	util.yield()
end