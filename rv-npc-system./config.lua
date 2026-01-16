-- ============================================================
-- PROYECTO: ROCKSTAR VALLE - SISTEMA DE NPCS AUTÓNOMOS
-- COMPONENTE: CONFIGURACIÓN GLOBAL (config.lua)
-- ============================================================

Config = {}

-- 1. CONFIGURACIÓN GENERAL
Config.Debug = true -- Muestra mensajes en consola (poner en false al terminar)
Config.MaxNPCsPorZona = 8 -- Máximo de NPCs creados por este script cerca del jugador
Config.DistanceSpawn = 50.0 -- Distancia a la que empiezan a aparecer
Config.DistanceDespawn = 70.0 -- Distancia a la que se eliminan para ahorrar RAM

-- 2. PUNTOS DE GENERACIÓN LÓGICA (Salida de edificios)
-- coords: dónde aparecen | heading: hacia dónde miran | label: nombre del sitio
Config.SpawnPoints = {
    -- Zona Centro / Legion Square
    {coords = vector3(145.2, -1035.8, 29.3), heading = 160.0, label = "Apartamento Plaza"},
    {coords = vector3(-42.1, -1100.5, 26.4), heading = 25.0, label = "Tienda de Electrónica"},
    
    -- Zona Norte / Paleto Bay
    {coords = vector3(-123.4, 6450.2, 31.4), heading = 45.0, label = "Supermercado Paleto"},
    
    -- Zona Sandy Shores
    {coords = vector3(1889.2, 3690.5, 33.5), heading = 210.0, label = "Licorería Sandy"}
}

-- 3. ECONOMÍA Y CONSUMO
Config.Negocios = {
    ['burgershot'] = {
        label = "Burger Shot",
        cuentaSociedad = "society_burgershot", -- Nombre en tu base de datos (ESX/QB)
        precioConsumo = {min = 15, max = 45}
    },
    ['up_n_atom'] = {
        label = "Up-n-Atom",
        cuentaSociedad = "society_upnatom",
        precioConsumo = {min = 20, max = 55}
    }
}

-- 4. TRABAJOS DE NPCS (Para el sistema de inventario)
-- Define qué items lleva cada tipo de ciudadano
Config.NPCTypes = {
    ['business'] = { model = `a_m_y_business_02`, job = 'executive' },
    ['worker'] = { model = `s_m_y_construct_01`, job = 'worker' },
    ['hiker'] = { model = `a_m_y_hiker_01`, job = 'cazador' }
}

-- 5. RECOMPENSAS Y PROPINAS
Config.Propinas = {
    DeliveryMin = 10,
    DeliveryMax = 45,
    ProbabilidadPropinaExtra = 15 -- 15% de probabilidad de recibir un item extra
}
