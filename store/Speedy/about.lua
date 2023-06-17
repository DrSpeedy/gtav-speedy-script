--DrSpeedy#1852
-- https://github.com/DrSpeedy

function MenuAboutSetup(menu_root)
    menu.action(menu_root, 'Discord: DrSpeedy#1852', {}, '')
    menu.action(menu_root, 'Version: ' .. ScriptVersion, {}, '')
    menu.hyperlink(menu_root, 'GitHub', 'https://github.com/DrSpeedy')
end