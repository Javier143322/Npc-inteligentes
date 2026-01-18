-- ============================================================
-- PROYECTO: ROCKSTAR VALLE - SISTEMA DE NPCS AUTÓNOMOS
-- COMPONENTE: TRABAJOS Y ANIMACIONES (cl_jobs.lua)
-- ============================================================

local TrabajosNPC = {
    ['MINERO'] = {
        coords = vector3(2953.5, 2787.2, 41.5), -- Ejemplo: Mina
        animDict = "amb@world_human_hammering@male@base",
        animName = "base",
        escenario = "WORLD_HUMAN_HAMMERING",
        prop = `prop_tool_pickaxe`
    },
    ['OBRERO'] = {
        coords = vector3(-156.4, -1045.9, 27.2), -- Ejemplo: Obra en el centro
        animDict = "amb@world_human_const_drill@male@drill@base",
        animName = "base",
        escenario = "WORLD_HUMAN_CONST_DRILL",
        prop = `prop_tool_drill`
    },
    ['LIMPIEZA'] = {
        coords = vector3(-585.1, -236.2, 36.0), -- Ejemplo: Ayuntamiento
        animDict = "amb@world_human_janitor@male@base",
        animName = "base",
        escenario = "WORLD_HUMAN_JANITOR",
        prop = `prop_tool_broom`
    }
}

-- 1. FUNCIÓN PARA ASIGNAR RUTINA LABORAL
function AsignarRutinaTrabajo(npc, tipoTrabajo)
    local trabajo = TrabajosNPC[tipoTrabajo]
    if not trabajo then return end

    -- El NPC camina hacia el punto de trabajo
    TaskGoStraightToCoord(npc, trabajo.coords.x, trabajo.coords.y, trabajo.coords.z, 1.0, 20000, 0.0, 0.0)
    
    Citizen.CreateThread(function()
        local enDestino = false
        while not enDestino and DoesEntityExist(npc) do
            local npcCoords = GetEntityCoords(npc)
            if #(npcCoords - trabajo.coords) < 2.0 then
                enDestino = true
                IniciarAnimacionTrabajo(npc, trabajo)
            end
            Wait(1000)
        end
    end)
end

-- 2. LÓGICA DE ANIMACIONES Y PROPS
function IniciarAnimacionTrabajo(npc, data)
    -- Usar escenario nativo si existe (es más optimizado)
    if data.escenario then
        TaskStartScenarioInPlace(npc, data.escenario, 0, true)
    else
        -- Carga de diccionarios de animación
        RequestAnimDict(data.animDict)
        while not HasAnimDictLoaded(data.animDict) do Wait(10) end
        
        TaskPlayAnim(npc, data.animDict, data.animName, 8.0, -8.0, -1, 49, 0, false, false, false)
        
        -- Añadir herramienta visual si tiene prop definido
        if data.prop then
            local obj = CreateObject(data.prop, 0, 0, 0, true, true, true)
            AttachEntityToEntity(obj, npc, GetPedBoneIndex(npc, 57005), 0.1, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
        end
    end
    
    print("^2[Rockstar Valle]^7 NPC ha comenzado su jornada laboral.")
end

-- 3. BUCLE DE CONTROL DE JORNADA
Citizen.CreateThread(function()
    while true do
        local hora = GetClockHours()
        
        -- Solo trabajan de 08:00 a 18:00
        if hora >= 8 and hora <= 18 then
            for _, data in ipairs(SpawnedNPCs) do
                if DoesEntityExist(data.entity) then
                    -- Si el NPC no tiene tarea actual, le asignamos una aleatoria de la lista
                    if not GetIsTaskActive(data.entity, 1) then -- 1 es el ID de TaskWander o similar
                        local trabajosKeys = {"MINERO", "OBRERO", "LIMPIEZA"}
                        local randomJob = trabajosKeys[math.random(1, #trabajosKeys)]
                        AsignarRutinaTrabajo(data.entity, randomJob)
                    end
                end
            end
        else
            -- Si es fuera de horario, los mandamos a deambular o a "casa"
            for _, data in ipairs(SpawnedNPCs) do
                if DoesEntityExist(data.entity) then
                    ClearPedTasks(data.entity)
                    TaskWanderStandard(data.entity, 10.0, 10)
                end
            end
        end
        Wait(30000) -- Revisamos la jornada cada 30 segundos para optimizar Windows
    end
end)
