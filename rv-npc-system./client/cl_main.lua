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

