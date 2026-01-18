-- ============================================================
-- PROYECTO: ROCKSTAR VALLE - SISTEMA DE NPCS AUTÓNOMOS
-- AUTHOR: ANDRÉS (GPROJECT MANAGER)
-- ============================================================

fx_version 'cerulean'
game 'gta5'

description 'Sistema de NPCs con Memoria, Economía y Fuerza Laboral'
version '1.0.0'

-- Dependencias Críticas
dependencies {
    'oxmysql',
    'ox_inventory',
    'ox_lib'
}

-- Configuración Global
shared_scripts {
    'config.lua'
}

-- Scripts del Cliente
client_scripts {
    'client/cl_main.lua',
    'client/cl_driving.lua',
    'client/cl_jobs.lua',
    'client/cl_delivery.lua'
}

-- Scripts del Servidor
server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/sv_main.lua',
    'server/sv_economy.lua'
}

-- Archivos de Datos
files {
    'npcs.sql'
}

-- Capacidades del recurso
provide 'rv-npc-system'
