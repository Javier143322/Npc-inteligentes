-- ============================================================
-- PROYECTO: ROCKSTAR VALLE - SISTEMA DE NPCS AUTÓNOMOS
-- COMPONENTE: NÚCLEO, SENTIDOS Y ESCANEO BIO (cl_main.lua)
-- ============================================================

SpawnedNPCs = {} -- Tabla global para que otros scripts la vean
local isInteracting = false

-- 1. FUNCIÓN MAESTRA DE CREACIÓN (Mantenemos tu Fade-in)
function CreateRockstarNPC(model, coords, heading)
    local hash = type(model) == 'string' and GetHashKey(model) or model
    RequestModel(hash)
    local timeout = 0
    while not HasModelLoaded(hash) and timeout < 100 do Wait(10); timeout = timeout + 1 end

    local npc = CreatePed(4, hash, coords.x, coords.y, coords.z - 1.0, heading, true, false)
    
    SetEntityAlpha(npc, 0, false)
    SetEntityVisible(npc, true)
    for alpha = 0, 255, 10 do SetEntityAlpha(npc, alpha, false); Wait(50) end

    SetPedConfigFlag(npc, 17, true) 
    SetPedConfigFlag(npc, 117, true) -- Reportar crímenes
    SetEntityAsMissionEntity(npc, true, true)

    local netId = NetworkGetNetworkIdFromEntity(npc)
    TriggerServerEvent('rv-npc:server:initNPC', netId, hash)
    
    table.insert(SpawnedNPCs, {entity = npc, netId = netId, hasReported = false, lastScan = 0})
    AplicarLogicaEntorno(npc)
    return npc
end

-- 2. LÓGICA DE ENTORNO (Mantenemos paraguas y clima)
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

-- 3. BUCLE DE SENTIDOS Y RECONOCIMIENTO NEO-EVO
Citizen.CreateThread(function()
    while true do
        local sleep = 1000
        local playerPed = PlayerPedId()
        local pCoords = GetEntityCoords(playerPed)
        local playerId = GetPlayerServerId(PlayerId())

        for i, data in ipairs(SpawnedNPCs) do
            if DoesEntityExist(data.entity) then
                local npcCoords = GetEntityCoords(data.entity)
                local dist = #(pCoords - npcCoords)

                if dist < 30.0 then
                    sleep = 500
                    
                    -- [NUEVO] ESCANEO DE RECONOCIMIENTO DE PERSONA (Cada 5 seg)
                    if GetGameTimer() - data.lastScan > 5000 and dist < 10.0 then
                        data.lastScan = GetGameTimer()
                        local bio = Utils.GetPlayerBioData(playerId)
                        
                        -- Reacción a la Ciberpsicosis (Humanidad < 20)
                        if bio.isCiberpsicopata then
                            TaskSmartFleePed(data.entity, playerPed, 50.0, -1, true, true)
                            Utils.Log("NPC asustado por Ciberpsicópata cercano.")
                        end
                    end

                    -- A. REACCIÓN AL APUNTADO (Tu lógica original)
                    if IsPlayerFreeAimingAtEntity(PlayerId(), data.entity) then
                        if not IsEntityDead(data.entity) then
                            TaskHandsUp(data.entity, 5000, playerPed, -1, false)
                            TriggerServerEvent('rv-npc:server:updateReputation', data.netId, -1)
                        end
                    end

                    -- B. LÓGICA DE TESTIGO (Disparos)
                    if IsPedShooting(playerPed) and not data.hasReported then
                        if HasEntityClearLosToEntity(data.entity, playerPed, 17) then
                            data.hasReported = true
                            ReportarCrimen(data.entity, "Sujeto armado detectado")
                        end
                    end

                    -- C. REGISTRO DE MUERTE
                    if IsEntityDead(data.entity) then
                        TriggerServerEvent('rv-npc:server:registerDeath', data.netId)
                        table.remove(SpawnedNPCs, i)
                    end
                end
            end
        end
        Wait(sleep)
    end
end)

-- 4. FUNCIÓN DE REPORTE (911 con teléfono)
function ReportarCrimen(npc, motivo)
    RequestAnimDict("cellphone@")
    while not HasAnimDictLoaded("cellphone@") do Wait(10) end
    TaskPlayAnim(npc, "cellphone@", "cellphone_call_listen_base", 8.0, -8.0, -1, 49, 0, false, false, false)
    
    local phone = CreateObject(`prop_npc_phone_02`, 0, 0, 0, true, true, true)
    AttachEntityToEntity(phone, npc, GetPedBoneIndex(npc, 28422), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 1, true)

    Wait(5000)
    local coords = GetEntityCoords(npc)
    TriggerServerEvent('rv-npc:server:policeAlert', coords, motivo)

    DeleteObject(phone)
    StopAnimTask(npc, "cellphone@", "cellphone_call_listen_base", 1.0)
    TaskSmartFleePed(npc, PlayerPedId(), 100.0, -1, true, true)
end

-- 5. ESCANEO DE SPAWN (Basado en tu Config)
Citizen.CreateThread(function()
    while true do
        local pCoords = GetEntityCoords(PlayerPedId())
        for _, point in pairs(Config.SpawnPoints) do
            local distance = #(pCoords - point.coords)
            if distance < Config.DistanceSpawn and distance > 15.0 then
                if #SpawnedNPCs < Config.MaxNPCsPorZona then
                    -- Generamos un modelo de los que ya tenías configurados
                    CreateRockstarNPC(`a_m_y_business_02`, point.coords, point.heading)
                end
            end
        end
        Wait(5000)
    end
end)
