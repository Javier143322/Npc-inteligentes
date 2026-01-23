-- ============================================================
-- PROYECTO: ROCKSTAR VALLE - SISTEMA DE NPCS AUTÓNOMOS
-- COMPONENTE: CONDUCCIÓN Y PERCEPCIÓN DE AMENAZA (cl_driving.lua)
-- ============================================================

local DrivingStyle = 786603 -- Estilo ágil original

-- 1. CONFIGURAR CONDUCTOR (Mejorado con datos Bio)
function ConfigurarConducionNPC(npc, vehiculo)
    local playerId = GetPlayerServerId(PlayerId())
    local bio = Utils.GetPlayerBioData(playerId)

    SetDriverAbility(npc, 1.0)
    SetDriverAggressiveness(npc, 0.5)
    
    -- Si el jugador es una amenaza (Ciberpsicosis), el NPC conduce con MIEDO (estilo más cauteloso)
    local actualStyle = bio.isCiberpsicopata and 1074528293 or DrivingStyle
    SetDriveTaskDrivingStyle(npc, actualStyle)
    
    SetPedConfigFlag(npc, 118, true) -- Rebasar
    SetPedConfigFlag(npc, 128, true) -- Maniobras evasivas
    
    Utils.Log("Conductor configurado. Reacción ante clase: " .. bio.class)
end

-- 2. BUCLE DE MONITOREO (Reacción al ADN del jugador)
Citizen.CreateThread(function()
    while true do
        local sleep = 2000
        local playerPed = PlayerPedId()
        local playerId = GetPlayerServerId(PlayerId())
        local pCoords = GetEntityCoords(playerPed)
        
        for i, data in ipairs(SpawnedNPCs) do
            if DoesEntityExist(data.entity) then
                local veh = GetVehiclePedIsIn(data.entity, false)
                
                if veh ~= 0 and GetPedInVehicleSeat(veh, -1) == data.entity then
                    sleep = 500
                    local dist = #(pCoords - GetEntityCoords(veh))
                    
                    -- Si el jugador está cerca, el NPC "escanea" quién viene
                    if dist < 20.0 then
                        local bio = Utils.GetPlayerBioData(playerId)
                        
                        -- LÓGICA: Si eres Ciberpsicópata, los coches se apartan
                        if bio.isCiberpsicopata then
                            TaskVehicleTempAction(data.entity, veh, 6, 2000) -- Frenar y apartarse
                        end
                    end

                    -- LÓGICA ORIGINAL: Bloqueos y Clima
                    local speed = GetEntitySpeed(veh)
                    if speed < 0.1 and not IsEntityInWater(veh) then
                        Wait(3000) 
                        if GetEntitySpeed(veh) < 0.1 then
                            TaskVehicleDriveWander(data.entity, veh, 20.0, DrivingStyle)
                        end
                    end

                    local weather = GetPrevailingWeatherType()
                    if weather == `RAIN` or weather == `THUNDER` then
                        SetDriveTaskMaxCruiseSpeed(data.entity, 15.0)
                    else
                        SetDriveTaskMaxCruiseSpeed(data.entity, 30.0)
                    end
                end
            end
        end
        Wait(sleep)
    end
end)

-- 3. EXPORT
exports('ConfigurarConductor', function(npc, veh)
    ConfigurarConducionNPC(npc, veh)
end)
