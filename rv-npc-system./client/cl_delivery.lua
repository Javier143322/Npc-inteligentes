-- ============================================================
-- PROYECTO: ROCKSTAR VALLE - SISTEMA DE NPCS AUTÓNOMOS
-- COMPONENTE: PEDIDOS Y RECONOCIMIENTO SOCIAL (cl_delivery.lua)
-- ============================================================

local PedidoActivo = false

-- 1. LÓGICA DE GENERACIÓN DE NECESIDAD (Afectada por NEO-EVO)
Citizen.CreateThread(function()
    while true do
        local sleep = 60000 
        
        if not PedidoActivo and #SpawnedNPCs > 0 then
            -- Si el jugador tiene mucho carisma (Temple), los NPCs piden más comida
            local bio = Utils.GetPlayerBioData(GetPlayerServerId(PlayerId()))
            local prob = (bio.class == "Corpo" or bio.adnLevel > 5) and 20 or 10

            if math.random(1, 100) <= prob then
                local randomIndex = math.random(1, #SpawnedNPCs)
                local npcData = SpawnedNPCs[randomIndex]
                
                if DoesEntityExist(npcData.entity) and not IsEntityDead(npcData.entity) then
                    SolicitarPedido(npcData)
                end
            end
        end
        Wait(sleep)
    end
end)

-- 2. SOLICITUD DEL PEDIDO (Mantenemos tu animación de teléfono)
function SolicitarPedido(npcData)
    PedidoActivo = true
    local coords = GetEntityCoords(npcData.entity)
    local zona = GetLabelText(GetNameOfZone(coords.x, coords.y, coords.z))
    
    TaskStartScenarioInPlace(npcData.entity, "WORLD_HUMAN_STAND_MOBILE", 0, true)
    
    Utils.Log("NPC " .. npcData.netId .. " ha solicitado un pedido en " .. zona)
    TriggerServerEvent('rv-npc:server:crearPedidoDelivery', npcData.netId, coords, zona)
    
    SetTimeout(600000, function()
        if PedidoActivo then
            PedidoActivo = false
            ClearPedTasks(npcData.entity)
            Utils.Log("Pedido cancelado por exceso de tiempo.")
        end
    end)
end

-- 3. FINALIZACIÓN Y RECONOCIMIENTO (Entrega)
RegisterNetEvent('rv-npc:client:entregarPedido')
AddEventHandler('rv-npc:client:entregarPedido', function(netId)
    for _, data in ipairs(SpawnedNPCs) do
        if data.netId == netId then
            PedidoActivo = false
            local bio = Utils.GetPlayerBioData(GetPlayerServerId(PlayerId()))

            -- Animación de recibir
            RequestAnimDict("anim@heists@box_transfer@")
            while not HasAnimDictLoaded("anim@heists@box_transfer@") do Wait(10) end
            TaskPlayAnim(data.entity, "anim@heists@box_transfer@", "terminal_dual_receive_box", 8.0, -8.0, 3000, 49, 0, false, false, false)
            
            -- LÓGICA DE REACCIÓN BIO
            if bio.isCiberpsicopata then
                -- El NPC se asusta y huye tras recibir el paquete (paga lo mínimo)
                Utils.Notify(nil, "DELIVERY", "El cliente está aterrado por tu aspecto...", "error")
                TaskSmartFleePed(data.entity, PlayerPedId(), 50.0, -1, true, true)
            elseif bio.adnLevel > 10 then
                -- El NPC te reconoce como alguien importante
                Utils.Notify(nil, "DELIVERY", "El cliente te reconoce y te da una propina generosa", "success")
            end

            -- El pago se procesa en el servidor enviando los datos bio para el cálculo de propina
            TriggerServerEvent('rv-npc:server:completeDelivery', netId, bio)
            break
        end
    end
end)
