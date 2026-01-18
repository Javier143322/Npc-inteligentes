-- ============================================================
-- PROYECTO: ROCKSTAR VALLE - SISTEMA DE NPCS AUTÓNOMOS
-- AUTHOR: ANDRÉS (PROJECT MANAGER)
-- ============================================================

fx_version 'cerulean'
game 'gta5'

description 'Sistema de NPCs con Memoria, Economía y Fuerza Laboral'
version '1.0.1'

-- Dependencias Críticas (Asegúrate de tenerlas en tu server)
dependencies {
    'oxmysql',
    'ox_lib',
    'ox_inventory'
}

-- Scripts Compartidos (Se cargan en Cliente y Servidor)
shared_scripts {
    'config.lua',
    'utils/sh_utils.lua' -- Nuevo archivo de utilidades
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

-- Archivos de Datos / SQL
files {
    'utils/npcs.sql'
}

-- Metadata del Recurso
provide 'rv-npc-system'
