-- Función para spawnear NPC con efecto suave
function SpawnNPCFluido(modelo, coordenadas, heading)
    RequestModel(modelo)
    while not HasModelLoaded(modelo) do Wait(1) end

    local npc = CreatePed(4, modelo, coordenadas.x, coordenadas.y, coordenadas.z - 1.0, heading, true, false)
    
    -- Lo hacemos invisible al inicio
    SetEntityAlpha(npc, 0, false)
    SetEntityVisible(npc, true)
    
    -- Efecto de aparición (Fade-in)
    for i = 0, 255, 5 do
        SetEntityAlpha(npc, i, false)
        Wait(50) -- Velocidad de la aparición
    end

    -- Le damos una tarea inicial para que no se quede quieto
    TaskWanderStandard(npc, 10.0, 10)
    
    return npc
end
Citizen.CreateThread(function()
    while true do
        local playerCoords = GetEntityCoords(PlayerPedId())
        
        for _, point in pairs(Config.SpawnPoints) do
            local dist = #(playerCoords - point.coords)
            
            -- Solo spawnea si el jugador está cerca (ej. 50m) pero no mirando la puerta directamente
            if dist < 50.0 and dist > 15.0 then
                if CanSpawnNPC(point.coords) then -- Función para chequear límite de población
                    local npc = SpawnNPCFluido(`a_m_y_business_02`, point.coords, point.heading)
                    
                    -- Tarea: Salir caminando del edificio
                    local forwardCoords = GetAnimInitialOffsetPosition(point.coords.x, point.coords.y, point.coords.z, 0.0, 0.0, point.heading, 5.0, 0.0, 0, 2)
                    TaskGoStraightToCoord(npc, forwardCoords.x, forwardCoords.y, forwardCoords.z, 1.0, 8000, point.heading, 0.0)
                end
            end
        end
        Wait(5000) -- Revisamos cada 5 segundos para ahorrar recursos
    end
end)

