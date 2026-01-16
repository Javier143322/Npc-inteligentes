-- ============================================================
-- PROYECTO: ROCKSTAR VALLE - SISTEMA DE NPCS AUTÓNOMOS
-- COMPONENTE: MEMORIA Y PERSISTENCIA (sv_main.lua)
-- ============================================================

-- 1. REGISTRO O CARGA DE NPC
-- Este evento se dispara cuando un NPC nace en el cliente
RegisterNetEvent('rv-npc:server:initNPC')
AddEventHandler('rv-npc:server:initNPC', function(npcNetworkId, modelHash)
    local src = source
    -- Generamos un ID único basado en su red y modelo para esta sesión
    local uniqueID = "NPC_" .. modelHash .. "_" .. npcNetworkId

    -- Consultamos si este NPC ya existe en la base de datos
    MySQL.query('SELECT * FROM rv_npcs WHERE npc_id = ?', {uniqueID}, function(result)
        if result and result[1] then
            -- El NPC ya es conocido, enviamos sus datos al cliente (Reputación, si está muerto, etc.)
            TriggerClientEvent('rv-npc:client:setNPCData', src, npcNetworkId, result[1])
            print("[Rockstar Valle] NPC reconocido: " .. uniqueID .. " - Rep: " .. result[1].reputation)
        else
            -- Es un ciudadano nuevo, lo registramos
            local name = "Ciudadano_" .. math.random(1000, 9999)
            MySQL.insert('INSERT INTO rv_npcs (npc_id, name, reputation) VALUES (?, ?, ?)', 
            {uniqueID, name, 50}, function(id)
                print("[Rockstar Valle] Nuevo ciudadano registrado: " .. name)
            end)
        end
    end)
end)

-- 2. ACTUALIZACIÓN DE REPUTACIÓN (Rencor/Perdón)
RegisterNetEvent('rv-npc:server:updateReputation')
AddEventHandler('rv-npc:server:updateReputation', function(npcID, amount)
    -- amount puede ser negativo (si le pegas) o positivo (si le ayudas)
    MySQL.update('UPDATE rv_npcs SET reputation = reputation + ? WHERE npc_id = ?', {amount, npcID})
end)

-- 3. SISTEMA DE MUERTE (CK NPC)
RegisterNetEvent('rv-npc:server:registerDeath')
AddEventHandler('rv-npc:server:registerDeath', function(npcID)
    MySQL.update('UPDATE rv_npcs SET is_dead = 1 WHERE npc_id = ?', {npcID})
    print("[Rockstar Valle] CK registrado para: " .. npcID)
end)

