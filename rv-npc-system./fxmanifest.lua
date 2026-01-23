fx_version 'cerulean'
game 'gta5'

description 'Rockstar Valle - Sistema de NPCs Autónomos (Conciencia Bio)'
version '2.0.0'

-- IMPORTANTE: sh_utils debe ir primero para que el puente exista
shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
    'utils/sh_utils.lua' 
}

client_scripts {
    'client/cl_main.lua',
    'client/cl_driving.lua',
    'client/cl_jobs.lua',
    'client/cl_delivery.lua',
    'client/cl_gangs.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/sv_main.lua',
    'server/sv_economy.lua'
}

dependencies {
    'ox_lib',
    'ox_inventory',
    'neo_evo' -- Añadimos esto para asegurar que el ADN cargue antes
}
