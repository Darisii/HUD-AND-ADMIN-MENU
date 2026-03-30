-- Admin Menu & HUD System
-- Created by D

fx_version 'cerulean'
game 'gta5'

author 'D'
description 'Advanced Admin Menu & HUD System'
version '1.0.0'

-- Client scripts
client_script 'client/hud.lua'
client_script 'client/admin.lua'
client_script 'client/main.lua'

-- NUI files
ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
    'html/admin.html',
    'html/admin.js'
}

-- Exports
exports {
    'GetHUDData',
    'IsAdminMenuOpen',
    'ToggleHUD',
    'OpenAdminMenu'
}

lua54 'yes'
