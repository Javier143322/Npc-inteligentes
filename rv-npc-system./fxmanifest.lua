-- ============================================================
-- PROYECTO: ROCKSTAR VALLE - SISTEMA DE NPCS AUTÓNOMOS
-- AUTHOR: ANDRÉS (PROJECT MANAGER)
-- VERSIÓN: 1.1.0 (Final Release)
-- ============================================================

fx_version 'cerulean'
game 'gta5'

description 'Sistema Integral de NPCs: IA, Economía y Reputación de Bandas'
version '1.1.0'

-- Dependencias Críticas
dependencies {
    'oxmysql',
    'ox_lib',
    'ox_inventory'
}

-- Scripts Compartidos
shared_scripts {
    'config.lua',
    'utils/sh_utils.lua'
}

-- Scripts del Cliente
client_scripts {
    'client/cl_main.lua',
    'client/cl_driving.lua',
    'client/cl_jobs.lua',
    'client/cl_delivery.lua',
    'client/cl_gangs.lua'
}

-- Scripts del Servidor
server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/sv_main.lua',
    'server/sv_economy.lua',
    'server/sv_gangs.lua' -- Nuevo módulo de persistencia de bandas
}

-- Archivos de Datos / SQL
files {
    'utils/npcs.sql'
}

provide 'rv-npc-system'
