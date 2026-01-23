Config = {}

-- 1. CONFIGURACIÓN DEL NÚCLEO (Mantenemos tus valores)
Config.MaxNPCsPorZona = 12       
Config.DistanceSpawn = 60.0      
Config.DistanceDespawn = 100.0   

-- 2. [NUEVO] INTEGRACIÓN NEO-EVO (Ajustes de Reconocimiento)
-- Estas variables controlan cómo los NPCs leen el ADN
Config.BioScanDistance = 15.0    -- Distancia de escaneo biométrico
Config.PanicHumanity = 20.0      -- Si el jugador tiene menos de 20 de humanidad, los NPCs huyen
Config.RespectADNLevel = 10      -- Nivel necesario para propinas de élite
Config.SoloDetectionRange = 50.0 -- Rango en el que las bandas detectan a un Solo

-- 3. PUNTOS DE SPAWN ORIGINALES (Restaurados y Protegidos)
Config.SpawnPoints = {
    {coords = vector3(-234.5, -980.2, 29.3), heading = 180.0},
    {coords = vector3(-256.4, -1010.5, 28.5), heading = 90.0},
    {coords = vector3(-210.1, -950.8, 30.0), heading = 0.0},
    -- Puedes seguir añadiendo tus coordenadas aquí abajo...
}

-- 4. ECONOMÍA Y TRABAJOS (Variables para sv_economy.lua)
Config.BaseDeliveryPay = {min = 150, max = 350}
Config.CorpoBonus = 150          
Config.NetrunnerLootProb = 45    

-- 5. RELACIONES Y GRUPOS
Config.HatesPlayerGroup = `GANG_PLAYER_HOSTILE`

-- 6. [LOGS]
Config.Debug = true -- Activa para ver los escaneos de ADN en la consola
