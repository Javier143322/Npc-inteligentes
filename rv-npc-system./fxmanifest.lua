fx_version 'cerulean'
game 'gta5'

author 'Andres - Rockstar Valle'
description 'Sistema de NPCs Autónomos con Memoria y Economía'

-- Importante: Declaramos oxmysql para la persistencia
dependencies {
    'oxmysql',
    'ox_inventory' -- O el inventario que uses
}

client_scripts {
    'config.lua',
    'client/cl_main.lua',
    'client/cl_driving.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/sv_main.lua'
}

