-- ============================================================
-- PROYECTO: ROCKSTAR VALLE - SISTEMA DE NPCS AUTÓNOMOS
-- COMPONENTE: NÚCLEO DE GENERACIÓN Y AMBIENTE (cl_main.lua)
-- ============================================================

local SpawnedNPCs = {} -- Tabla para controlar cuántos hay vivos

-- 1. FUNCIÓN MAESTRA DE SPAWN (Fade-in + Sentidos)
function CreateRockstarNPC(model, coords, heading)
    local hash = type(model) == 'string' and GetHashKey(model) or model
    
    -- Carga del modelo con protección de seguridad
    RequestModel(hash)
    local timeout = 0
    while not HasModelLoaded(hash) and timeout < 100 do 
        Wait(10) 
        timeout = timeout + 1 
    end

    -- Creación física
    local npc = CreatePed(4, hash, coords.x, coords.y, coords.z - 1.0, heading, true, false)
    
    -- Configuración visual: Aparecer poco a poco (Anti Pop-in)
    SetEntityAlpha(npc, 0, false)
    SetEntityVisible(npc, true)
    
    for alpha = 0, 255, 10 do
        SetEntityAlpha(npc, alpha, false)
        Wait(50)
    end

    -- Configuración de IA (Sentidos de Rockstar Valle)
    SetPedConfigFlag(npc, 17, true) -- Bloquear para que no huyan por nada
    SetPedConfigFlag(npc, 117, true) -- Reportar crímenes al verlos
    
    -- Guardar en nuestra tabla de control
    table.insert(SpawnedNPCs, npc)
    
    -- Aplicar lógica de clima inmediatamente
    AplicarLogicaEntorno(npc)
    
    return npc
end

-- 2. LÓGICA DE ENTORNO (Clima y Objetos)
function AplicarLogicaEntorno(npc)
    local weather = GetPrevailingWeatherType()
    
    -- Si llueve, les damos prisa y paraguas
    if weather == `RAIN` or weather == `THUNDER` then
        SetPedMoveRateOverride(npc, 1.25) -- Caminan más rápido
        
        -- Carga del objeto paraguas
        local propHash = `p_amb_brolly_01`
        RequestModel(propHash)
        while not HasModelLoaded(propHash) do Wait(10) end
        
        local paraguas = CreateObject(propHash, 0, 0, 0, true, true, true)
        AttachEntityToEntity(paraguas, npc, GetPedBoneIndex(npc, 57005), 0.1, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
    end
end

-- 3. HILO PRINCIPAL (Escaneo de puntos de salida)
Citizen.CreateThread(function()
    while true do
        local pCoords = GetEntityCoords(PlayerPedId())
        
        -- Revisar puntos de spawn definidos en Config
        for _, point in pairs(Config.SpawnPoints) do
            local distance = #(pCoords - point.coords)
            
            -- Spawn lógico: entre 20 y 50 metros del jugador
            if distance < 50.0 and distance > 20.0 then
                -- Aquí podrías añadir una lógica para que no spawneen 1000 a la vez
                if #SpawnedNPCs < Config.MaxNPCsPorZona then
                    local nuevoNPC = CreateRockstarNPC(`a_m_y_business_02`, point.coords, point.heading)
                    
                    -- Tarea: Salir de la puerta caminando
                    TaskWanderStandard(nuevoNPC, 10.0, 10)
                end
            end
        end
        
        Wait(5000) -- Optimización: Revisa cada 5 segundos
    end
end)
