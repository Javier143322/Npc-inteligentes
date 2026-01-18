-- ============================================================
-- PROYECTO: ROCKSTAR VALLE - SISTEMA DE NPCS AUTÓNOMOS
-- COMPONENTE: SISTEMA DE PEDIDOS A DOMICILIO (cl_delivery.lua)
-- ============================================================

local PedidoActivo = false

-- 1. LÓGICA DE GENERACIÓN DE NECESIDAD (HAMBRE)
Citizen.CreateThread(function()
    while true do
        local sleep = 60000 -- Revisar cada minuto
        
        if not PedidoActivo and #SpawnedNPCs > 0 then
            -- Probabilidad del 10% cada minuto de que un NPC pida comida
            if math.random(1, 100) <= 10 then
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

-- 2. SOLICITUD DEL PEDIDO AL SERVIDOR
function SolicitarPedido(npcData)
    PedidoActivo = true
    local coords = GetEntityCoords(npcData.entity)
    local zona = GetLabelText(GetNameOfZone(coords.x, coords.y, coords.z))
    
    -- Animación de usar el teléfono para pedir
    TaskStartScenarioInPlace(npcData.entity, "WORLD_HUMAN_STAND_MOBILE", 0, true)
    
    print("^2[Rockstar Valle]^7 NPC " .. npcData.netId .. " ha solicitado un pedido en " .. zona)
    
    -- Enviamos la alerta al servidor para los repartidores
    TriggerServerEvent('rv-npc:server:crearPedidoDelivery', npcData.netId, coords, zona)
    
    -- El NPC esperará en el sitio hasta 10 minutos
    SetTimeout(600000, function()
        if PedidoActivo then
            PedidoActivo = false
            ClearPedTasks(npcData.entity)
            print("^1[Rockstar Valle]^7 Pedido cancelado por exceso de tiempo.")
        end
    end)
end

-- 3. FINALIZACIÓN DEL PEDIDO (EVENTO DESDE EL SERVIDOR)
RegisterNetEvent('rv-npc:client:entregarPedido')
AddEventHandler('rv-npc:client:entregarPedido', function(netId)
    for _, data in ipairs(SpawnedNPCs) do
        if data.netId == netId then
            PedidoActivo = false
            -- Animación de recibir paquete
            RequestAnimDict("anim@heists@box_transfer@")
            while not HasAnimDictLoaded("anim@heists@box_transfer@") do Wait(10) end
            
            TaskPlayAnim(data.entity, "anim@heists@box_transfer@", "terminal_dual_receive_box", 8.0, -8.0, 3000, 49, 0, false, false, false)
            
            -- El NPC paga y da reputación (vía sv_economy que ya hicimos)
            TriggerServerEvent('rv-npc:server:completeDelivery', netId)
            break
        end
    end
end)
