-- ============================================================
-- PROYECTO: ROCKSTAR VALLE - SISTEMA DE NPCS AUTÓNOMOS
-- COMPONENTE: NÚCLEO Y GENERACIÓN BIO-CONSCIENTE (sv_main.lua)
-- ============================================================

local NPC_Data = {} 

-- 1. GENERADOR DE ITEMS (Bolsillos afectados por Clase)
local function GenerarItemsNPC(job, bio)
    local items = {}
    local multiplier = (bio and bio.adnLevel) or 1
    
    if job == 'executive' then
        items = { {item = 'phone', count = 1}, {item = 'money', count = math.random(500, 1500) * multiplier} }
    elseif job == 'cazador' then
        items = { {item = 'weapon_knife', count = 1}, {item = 'meat', count = math.random(1, 3)} }
    else
        -- Si el jugador cerca es Netrunner, el NPC lleva 'vales' o 'chips'
        if bio and bio.class == "Netrunner" then
            items = { {item = 'money', count = math.random(50, 200)}, {item = 'electronics', count = 1} }
        else
            items = { {item = 'money', count = math.random(20, 150)}, {item = 'sandwich', count = 1} }
        end
    end
    return items
end

-- 2. REGISTRO Y CARGA (Sincronizado con NEO-EVO)
RegisterNetEvent('rv-npc:server:initNPC')
AddEventHandler('rv-npc:server:initNPC', function(npcNetId, modelHash)
    local src = source
    local uniqueID = "NPC_" .. modelHash .. "_" .. npcNetId
    local bio = Utils.GetPlayerBioData(src) -- Obtenemos datos del jugador que lo spawnea

    MySQL.prepare('SELECT * FROM rv_npcs WHERE npc_id = ?', {uniqueID}, function(result)
        if result then
            if result.is_dead == 1 then return end
            TriggerClientEvent('rv-npc:client:setNPCData', src, npcNetId, result)
            NPC_Data[npcNetId] = result
        else
            local name = "Ciudadano_" .. math.random(1000, 9999)
            local job = (modelHash == `a_m_y_business_02`) and 'executive' or 'unemployed'
            
            MySQL.insert('INSERT INTO rv_npcs (npc_id, name, reputation, job) VALUES (?, ?, ?, ?)', 
            {uniqueID, name, 50, job}, function(id)
                NPC_Data[npcNetId] = {npc_id = uniqueID, name = name, reputation = 50, job = job}
            end)
        end
        
        -- Registro de Inventario con Loot Adaptativo
        local stashName = "npc_" .. npcNetId
        exports.ox_inventory:RegisterStash(stashName, "Bolsillos", 5, 2000)
        
        local items = GenerarItemsNPC(NPC_Data[npcNetId].job, bio)
        for _, v in pairs(items) do
            exports.ox_inventory:AddItem(stashName, v.item, v.count)
        end
    end)
end)

-- 3. ALERTA POLICIAL (Dispatch Mejorado)
RegisterNetEvent('rv-npc:server:policeAlert')
AddEventHandler('rv-npc:server:policeAlert', function(coords, motivo)
    local src = source
    local bio = Utils.GetPlayerBioData(src)
    local mensaje = motivo

    -- Si el sospechoso es Ciberpsicópata, la alerta es CRÍTICA
    if bio.isCiberpsicopata then
        mensaje = "^1[CÓDIGO ROJO]^7 " .. motivo .. " - SUJETO ALTAMENTE INESTABLE"
    end

    local players = GetPlayers()
    for _, playerId in ipairs(players) do
        TriggerClientEvent('ox_lib:notify', playerId, {
            title = '911: ALERTA BIO-MÉTRICA',
            description = mensaje,
            type = bio.isCiberpsicopata and 'error' or 'inform',
            icon = 'shield-halved'
        })
    end
end)

-- 4. REGISTRO DE MUERTE (Impacto en Humanidad)
RegisterNetEvent('rv-npc:server:registerDeath')
AddEventHandler('rv-npc:server:registerDeath', function(npcNetId)
    local src = source
    if NPC_Data[npcNetId] then
        MySQL.update('UPDATE rv_npcs SET is_dead = 1 WHERE npc_id = ?', {NPC_Data[npcNetId].npc_id})
        
        -- Notificamos a NEO-EVO que el jugador ha matado (para bajar humanidad)
        local bio = Utils.GetPlayerBioData(src)
        if bio then
            -- Aquí podrías disparar un evento a NEO-EVO para restar puntos
            Utils.Log("Muerte registrada por jugador " .. src .. ". Humanidad actual: " .. bio.humanity)
        end
        
        NPC_Data[npcNetId] = nil
    end
end)

-- 5. LIMPIEZA
AddEventHandler('entityRemoved', function(entity)
    local netId = NetworkGetNetworkIdFromEntity(entity)
    if NPC_Data[netId] then NPC_Data[netId] = nil end
end)
