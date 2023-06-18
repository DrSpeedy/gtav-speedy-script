-- DrSpeedy#1852
-- https://github.com/DrSpeedy

function MenuAboutSetup(menu_root)
    menu.readonly(menu_root, 'Version', SCRIPT_VERSION)
    menu.readonly(menu_root, 'Discord', 'Speedy422')
    menu.hyperlink(menu_root, 'GitHub', 'https://github.com/DrSpeedy/gtav-speedy-script')
    -- Manually check for updates with a menu option
    menu.action(menu_root, "Check for Update", {}, "The script will automatically check for updates at most daily, but you can manually check using this option anytime.", function()
        CheckForUpdates(0)
    end)
end