-- ============================================================
-- PROYECTO: ROCKSTAR VALLE - SISTEMA DE NPCS AUTÓNOMOS
-- COMPONENTE: SERVIDOR - MEMORIA, SQL E INVENTARIO
-- ============================================================

-- 1. CONFIGURACIÓN INTERNA DEL SERVIDOR
local NPC_Data = {} -- Caché temporal para no saturar la DB

-- Función para generar ítems aleatorios según el perfil del NPC
local function GenerarItemsNPC(job)
    local items = {}
    if job == 'executive' then
        items = { {item = 'phone', count = 1}, {item = 'money', count = math.random(500, 1500)} }
    elseif job == 'cazador' then
        items = { {item = 'weapon_knife', count = 1}, {item = 'water', count = 2}, {item = 'meat', count = math.random(1, 3)} }
    else
        -- Ciudadano común
        items = { {item = 'money', count = math.random(20, 150)}, {item = 'sandwich', count = 1} }
    end
    return items
end

-- 2. REGISTRO O CARGA DE NPC (PUENTE CON EL CLIENTE)
RegisterNetEvent('rv-npc:server:initNPC')
AddEventHandler('rv-npc:server:initNPC', function(npcNetId, modelHash)
    local src = source
    local uniqueID = "NPC_" .. modelHash .. "_" .. npcNetId

    -- Consultar base de datos
    MySQL.prepare('SELECT * FROM rv_npcs WHERE npc_id = ?', {uniqueID}, function(result)
        if result then
            -- NPC conocido: Enviamos datos al cliente
            TriggerClientEvent('rv-npc:client:setNPCData', src, npcNetId, result)
            NPC_Data[npcNetId] = result
            print("^4[Rockstar Valle]^7 NPC Reconocido: " .. uniqueID)
        else
            -- Nuevo ciudadano: Registrar en MySQL
            local name = "Ciudadano_" .. math.random(1000, 9999)
            local job = 'unemployed' -- Aquí podrías randomizar el trabajo
            
            MySQL.insert('INSERT INTO rv_npcs (npc_id, name, reputation, job) VALUES (?, ?, ?, ?)', 
            {uniqueID, name, 50, job}, function(id)
                NPC_Data[npcNetId] = {npc_id = uniqueID, name = name, reputation = 50, job = job}
                print("^2[Rockstar Valle]^7 Nuevo registro: " .. name)
            end)
        end
        
        -- Generar su inventario físico en ox_inventory
        local stashName = "npc_" .. npcNetId
        local jobType = (NPC_Data[npcNetId] and NPC_Data[npcNetId].job) or 'unemployed'
        local itemsParaDar = GenerarItemsNPC(jobType)

        exports.ox_inventory:RegisterStash(stashName, "Bolsillos del Ciudadano", 5, 2000)
        
        for _, v in pairs(itemsParaDar) do
            exports.ox_inventory:AddItem(stashName, v.item, v.count)
        end
    end)
end)

-- 3. ACTUALIZACIÓN DE REPUTACIÓN (RENCOR / GRATITUD)
RegisterNetEvent('rv-npc:server:updateReputation')
AddEventHandler('rv-npc:server:updateReputation', function(npcUniqueID, amount)
    MySQL.update('UPDATE rv_npcs SET reputation = reputation + ? WHERE npc_id = ?', {amount, npcUniqueID})
    print("^4[Rockstar Valle]^7 Reputación actualizada para " .. npcUniqueID .. " en " .. amount)
end)

-- 4. REGISTRO DE MUERTE (CK NPC)
RegisterNetEvent('rv-npc:server:registerDeath')
AddEventHandler('rv-npc:server:registerDeath', function(npcUniqueID)
    MySQL.update('UPDATE rv_npcs SET is_dead = 1 WHERE npc_id = ?', {npcUniqueID})
    print("^1[Rockstar Valle]^7 Registro de fallecimiento (CK): " .. npcUniqueID)
end)

-- Limpieza de caché cuando el NPC se elimina (Despawn)
AddEventHandler('entityRemoved', function(entity)
    local netId = NetworkGetNetworkIdFromEntity(entity)
    if NPC_Data[netId] then
        NPC_Data[netId] = nil
    end
end)
