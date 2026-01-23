Config = {}

-- 1. CONFIGURACIÓN DEL NÚCLEO
Config.MaxNPCsPorZona = 12       -- Ajustado para no saturar el servidor con los escaneos bio
Config.DistanceSpawn = 60.0      -- Distancia a la que empiezan a aparecer
Config.DistanceDespawn = 100.0   -- Distancia de limpieza

-- 2. PARÁMETROS NEO-EVO (NUEVO)
Config.BioScanDistance = 15.0    -- ¿A qué distancia el NPC detecta tu ADN?
Config.PanicHumanity = 20.0      -- Umbral de Humanidad para causar pánico (Ciberpsicosis)
Config.RespectADNLevel = 10      -- Nivel de ADN para que te den mejores propinas
Config.SoloDetectionRange = 50.0 -- Los Solos son detectados desde más lejos por las bandas

-- 3. PUNTOS DE SPAWN (PUERTAS DE LA CIUDAD)
Config.SpawnPoints = {
    {coords = vector3(-234.5, -980.2, 29.3), heading = 180.0, zona = "Centro"},
    {coords = vector3(120.4, -1920.8, 20.5), heading = 45.0, zona = "Territorio Ballas"},
    {coords = vector3(-150.8, -1540.2, 30.1), heading = 270.0, zona = "Territorio Families"},
}

-- 4. ECONOMÍA DINÁMICA
Config.BaseDeliveryPay = {min = 150, max = 350}
Config.CorpoBonus = 150          -- Dinero extra si eres clase Corpo
Config.NetrunnerLootProb = 45    -- Probabilidad de encontrar items electrónicos al robar

-- 5. RELACIONES
Config.HatesPlayerGroup = `GANG_PLAYER_HOSTILE`
