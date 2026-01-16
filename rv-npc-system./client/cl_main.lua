-- ============================================================
-- PROYECTO: ROCKSTAR VALLE - SISTEMA DE NPCS AUTÓNOMOS
-- COMPONENTE: NÚCLEO Y SENTIDOS (cl_main.lua)
-- ============================================================

local SpawnedNPCs = {}
local isInteracting = false

-- 1. FUNCIÓN MAESTRA DE CREACIÓN (FADE-IN + REGISTRO)
function CreateRockstarNPC(model, coords, heading)
    local hash = type(model) == 'string' and GetHashKey(model) or model
    
    RequestModel(hash)
    local timeout = 0
    while not HasModelLoaded(hash) and timeout < 100 do 
        Wait(10) 
        timeout = timeout + 1 
    end

    local npc = CreatePed(4, hash, coords.x, coords.y, coords.z - 1.0, heading, true, false)
    
    -- Anti Pop-in
    SetEntityAlpha(npc, 0, false)
    SetEntityVisible(npc, true)
    for alpha = 0, 255, 10 do
        SetEntityAlpha(npc, alpha, false)
        Wait(50)
    end

    -- Sentidos y Flags de IA
    SetPedConfigFlag(npc, 17, true) -- Bloquear huida aleatoria
    SetPedConfigFlag(npc, 117, true) -- Reportar crímenes
    SetEntityAsMissionEntity(npc, true, true) -- Evitar que el motor de GTA lo borre agresivamente

    -- PUENTE CON EL SERVIDOR: Registrar en DB y Crear Inventario
    local netId = NetworkGetNetworkIdFromEntity(npc)
    TriggerServerEvent('rv-npc:server:initNPC', netId, hash)
    
    table.insert(SpawnedNPCs, {entity = npc, netId = netId})
    AplicarLogicaEntorno(npc)
    
    return npc
end

-- 2. LÓGICA DE ENTORNO (CLIMA)
function AplicarLogicaEntorno(npc)
    local weather = GetPrevailingWeatherType()
    if weather == `RAIN` or weather == `THUNDER` then
        SetPedMoveRateOverride(npc, 1.25)
        local propHash = `p_amb_brolly_01`
        RequestModel(propHash)
        while not HasModelLoaded(propHash) do Wait(10) end
        local paraguas = CreateObject(propHash, 0, 0, 0, true, true, true)
        AttachEntityToEntity(paraguas, npc, GetPedBoneIndex(npc, 57005), 0.1, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
    end
end

-- 3. BUCLE DE SENTIDOS Y REACCIÓN (DAÑO Y APUNTADO)
Citizen.CreateThread(function()
    while true do
        local sleep = 1000
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)

        for i, data in ipairs(SpawnedNPCs) do
            if DoesEntityExist(data.entity) then
                sleep = 500
                -- Detectar si el jugador le apunta con un arma
                if IsPlayerFreeAimingAtEntity(PlayerId(), data.entity) then
                    if not IsEntityDead(data.entity) then
                        -- Reacción de miedo: Manos arriba o huida
                        TaskHandsUp(data.entity, 5000, playerPed, -1, false)
                        -- Bajamos reputación por amenaza
                        TriggerServerEvent('rv-npc:server:updateReputation', data.netId, -1)
                        sleep = 0
                    end
                end

                -- Detectar si el NPC ha muerto para registrar el CK
                if IsEntityDead(data.entity) then
                    TriggerServerEvent('rv-npc:server:registerDeath', data.netId)
                    table.remove(SpawnedNPCs, i)
                end
            end
        end
        Wait(sleep)
    end
end)

-- 4. ESCANEO DE PUNTOS DE SPAWN (PUERTAS)
Citizen.CreateThread(function()
    while true do
        local pCoords = GetEntityCoords(PlayerPedId())
        for _, point in pairs(Config.SpawnPoints) do
            local distance = #(pCoords - point.coords)
            if distance < 50.0 and distance > 20.0 then
                if #SpawnedNPCs < Config.MaxNPCsPorZona then
                    CreateRockstarNPC(`a_m_y_business_02`, point.coords, point.heading)
                end
            end
        end
        Wait(5000)
    end
end)
