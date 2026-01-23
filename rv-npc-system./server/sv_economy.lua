-- ============================================================
-- PROYECTO: ROCKSTAR VALLE - SISTEMA DE NPCS AUTÓNOMOS
-- COMPONENTE: ECONOMÍA DINÁMICA Y RECONOCIMIENTO (sv_economy.lua)
-- ============================================================

-- 1. PAGO POR ENTREGA (Afectado por ADN/Temple)
RegisterNetEvent('rv-npc:server:completeDelivery')
AddEventHandler('rv-npc:server:completeDelivery', function(npcNetId, bioData)
    local src = source
    local basePay = math.random(150, 300)
    local propina = 0

    -- [NUEVO] LÓGICA NEO-EVO EN EL PAGO
    if bioData then
        if bioData.isCiberpsicopata then
            propina = 0 -- Nadie da propina a un maníaco
            Utils.Log("Pago mínimo entregado a Ciberpsicópata: " .. src)
        else
            -- Propinas basadas en el nivel de ADN (Temple)
            propina = math.floor(basePay * (bioData.adnLevel * 0.05))
        end
        
        -- Bonus por Clase (Ej: El Corpo recibe más por 'contactos')
        if bioData.class == "Corpo" then
            propina = propina + 100
        end
    end

    local total = basePay + propina
    exports.ox_inventory:AddItem(src, 'money', total)
    
    Utils.Notify(src, "ECONOMÍA", "Has recibido $"..total.." (Propina: $"..propina..")", "success")
    TriggerEvent('rv-npc:server:updateReputation', npcNetId, 2)
end)

-- 2. SISTEMA DE ROBO A NPC (Mejorado para Netrunners)
RegisterNetEvent('rv-npc:server:robNPC')
AddEventHandler('rv-npc:server:robNPC', function(npcNetId)
    local src = source
    -- Obtenemos bioData desde el servidor para seguridad
    local bio = Utils.GetPlayerBioData(src) 
    
    local moneyAmount = math.random(50, 200)
    
    -- Si el ladrón es Netrunner, encuentra "cripto" o datos extra
    if bio.class == "Netrunner" then
        local extra = math.random(100, 300)
        exports.ox_inventory:AddItem(src, 'money', moneyAmount + extra)
        Utils.Notify(src, "HACKEO", "Has extraído datos bancarios adicionales.", "success")
    else
        exports.ox_inventory:AddItem(src, 'money', moneyAmount)
    end

    -- El robo baja la reputación del NPC afectado
    TriggerEvent('rv-npc:server:updateReputation', npcNetId, -10)
    
    -- Si es Ciberpsicópata, la policía recibe alerta inmediata (Dispatch)
    if bio.isCiberpsicopata then
        local coords = GetEntityCoords(GetPlayerPed(src))
        TriggerEvent('rv-npc:server:policeAlert', coords, "¡ATENCIÓN! Ciberpsicópata violento asaltando civiles.")
    end
end)

-- 3. PROPINAS POR INTERACCIÓN SOCIAL
-- (Mantenemos tu lógica pero añadimos el filtro bio)
RegisterNetEvent('rv-npc:server:darPropina')
AddEventHandler('rv-npc:server:darPropina', function(amount)
    local src = source
    local bio = Utils.GetPlayerBioData(src)
    
    -- Un jugador con alta humanidad/temple recibe mejores tratos
    local finalAmount = (bio.humanity > 80) and (amount * 1.2) or amount
    
    exports.ox_inventory:AddItem(src, 'money', math.floor(finalAmount))
end)
