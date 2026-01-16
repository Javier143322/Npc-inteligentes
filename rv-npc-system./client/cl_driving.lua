-- ============================================================
-- PROYECTO: ROCKSTAR VALLE - SISTEMA DE NPCS AUTÓNOMOS
-- COMPONENTE: CONDUCCIÓN AVANZADA (cl_driving.lua)
-- ============================================================

-- Configuración de estilos de conducción de GTA V
-- 786603: Estilo que esquiva tráfico, respeta semáforos pero es ágil.
-- 1074528293: Estilo de huida (ignora todo para escapar).
local DrivingStyle = 786603 

-- 1. FUNCIÓN PARA ASIGNAR CONDUCTOR INTELIGENTE
function ConfigurarConducionNPC(npc, vehiculo)
    -- Configuramos la inteligencia del conductor
    SetDriverAbility(npc, 1.0) -- Habilidad máxima al volante
    SetDriverAggressiveness(npc, 0.5) -- Agresividad media (ni miedoso ni asesino)
    
    -- Aplicamos el estilo de conducción avanzado de Rockstar Valle
    SetDriveTaskDrivingStyle(npc, DrivingStyle)
    
    -- Flags para mejorar la reacción
    SetPedConfigFlag(npc, 118, true) -- Capacidad de rebasar otros vehículos
    SetPedConfigFlag(npc, 128, true) -- Capacidad de hacer maniobras evasivas
    
    print("^4[Rockstar Valle]^7 Conductor Inteligente configurado en RedID: " .. NetworkGetNetworkIdFromEntity(npc))
end

-- 2. BUCLE DE MONITOREO DE TRÁFICO (REACCIÓN A BLOQUEOS)
Citizen.CreateThread(function()
    while true do
        local sleep = 2000
        local playerPed = PlayerPedId()
        
        -- Revisamos todos los NPCs que hemos creado nosotros
        for i, data in ipairs(SpawnedNPCs) do
            if DoesEntityExist(data.entity) then
                local veh = GetVehiclePedIsIn(data.entity, false)
                
                if veh ~= 0 and GetPedInVehicleSeat(veh, -1) == data.entity then
                    sleep = 500 -- Aumentamos la frecuencia si hay conductores cerca
                    
                    local coords = GetEntityCoords(veh)
                    local speed = GetEntitySpeed(veh)

                    -- LÓGICA: Detección de atasco o bloqueo
                    if speed < 0.1 and not IsEntityInWater(veh) then
                        -- Si el coche está parado pero el motor encendido, algo lo bloquea
                        -- Esperamos un momento y le ordenamos rebasar
                        Wait(3000) 
                        if GetEntitySpeed(veh) < 0.1 then
                            -- Forzamos al NPC a encontrar una nueva ruta o esquivar
                            TaskVehicleDriveWander(data.entity, veh, 20.0, DrivingStyle)
                            print("^3[Rockstar Valle]^7 NPC rebasando obstáculo...")
                        end
                    end

                    -- LÓGICA: Reacción al Clima en la conducción
                    local weather = GetPrevailingWeatherType()
                    if weather == `RAIN` or weather == `THUNDER` then
                        SetDriveTaskMaxCruiseSpeed(data.entity, 15.0) -- Reduce velocidad por lluvia
                    else
                        SetDriveTaskMaxCruiseSpeed(data.entity, 30.0) -- Velocidad crucero normal
                    end
                end
            end
        end
        Wait(sleep)
    end
end)

-- 3. EXPORT PARA OTROS SCRIPTS
exports('ConfigurarConductor', function(npc, veh)
    ConfigurarConducionNPC(npc, veh)
end)

