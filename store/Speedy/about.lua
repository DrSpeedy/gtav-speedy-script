-- DrSpeedy#1852
-- https://github.com/DrSpeedy

--[[
function CheckForUpdates()
    local api_url = 'https://api.github.com/repos/DrSpeedy/gtav-speedy-script/releases/latest'
    local function on_success(body, headers, status_code)
        Notification('Test Update Request')
    end
    local function on_fail()
        Notification('Failed to check for update!')
    end
    if async_http.have_access() then
        async_http.init(api_url, on_success, on_fail)
        async_http.dispatch()
    end
end
]]

function MenuAboutSetup(menu_root)
    menu.readonly(menu_root, 'Version', ScriptVersion)
    menu.readonly(menu_root, 'Discord', 'Speedy422')
    menu.hyperlink(menu_root, 'GitHub', 'https://github.com/DrSpeedy')
end