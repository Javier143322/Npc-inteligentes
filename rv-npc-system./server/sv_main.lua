-- ============================================================
-- PROYECTO: ROCKSTAR VALLE - SISTEMA DE NPCS AUTÓNOMOS
-- COMPONENTE: SERVIDOR FINAL (sv_main.lua)
-- ============================================================

local NPC_Data = {} 

-- Generador de Items (Bolsillos)
local function GenerarItemsNPC(job)
    local items = {}
    if job == 'executive' then
        items = { {item = 'phone', count = 1}, {item = 'money', count = math.random(500, 1500)} }
    elseif job == 'cazador' then
        items = { {item = 'weapon_knife', count = 1}, {item = 'water', count = 2}, {item = 'meat', count = math.random(1, 3)} }
    else
        items = { {item = 'money', count = math.random(20, 150)}, {item = 'sandwich', count = 1} }
    end
    return items
end

-- Registro y Carga de NPC
RegisterNetEvent('rv-npc:server:initNPC')
AddEventHandler('rv-npc:server:initNPC', function(npcNetId, modelHash)
    local src = source
    local uniqueID = "NPC_" .. modelHash .. "_" .. npcNetId

    MySQL.prepare('SELECT * FROM rv_npcs WHERE npc_id = ?', {uniqueID}, function(result)
        if result then
            if result.is_dead == 1 then return end -- Si tiene CK, no lo cargamos
            TriggerClientEvent('rv-npc:client:setNPCData', src, npcNetId, result)
            NPC_Data[npcNetId] = result
        else
            local name = "Ciudadano_" .. math.random(1000, 9999)
            local job = 'unemployed'
            MySQL.insert('INSERT INTO rv_npcs (npc_id, name, reputation, job) VALUES (?, ?, ?, ?)', 
            {uniqueID, name, 50, job}, function(id)
                NPC_Data[npcNetId] = {npc_id = uniqueID, name = name, reputation = 50, job = job}
            end)
        end
        
        -- Registro de Inventario
        local stashName = "npc_" .. npcNetId
        local jobType = (NPC_Data[npcNetId] and NPC_Data[npcNetId].job) or 'unemployed'
        exports.ox_inventory:RegisterStash(stashName, "Bolsillos", 5, 2000)
        
        local items = GenerarItemsNPC(jobType)
        for _, v in pairs(items) do
            exports.ox_inventory:AddItem(stashName, v.item, v.count)
        end
    end)
end)

-- Alerta Policial (Dispatch)
RegisterNetEvent('rv-npc:server:policeAlert')
AddEventHandler('rv-npc:server:policeAlert', function(coords, motivo)
    local players = GetPlayers()
    for _, playerId in ipairs(players) do
        -- Notificación para policías
        TriggerClientEvent('ox_lib:notify', playerId, {
            title = '911: ALERTA DE TESTIGO',
            description = motivo,
            type = 'inform',
            icon = 'shield-halved'
        })
    end
end)

-- Guardado de Reputación y CK
RegisterNetEvent('rv-npc:server:updateReputation')
AddEventHandler('rv-npc:server:updateReputation', function(npcNetId, amount)
    if NPC_Data[npcNetId] then
        MySQL.update('UPDATE rv_npcs SET reputation = reputation + ? WHERE npc_id = ?', {amount, NPC_Data[npcNetId].npc_id})
    end
end)

RegisterNetEvent('rv-npc:server:registerDeath')
AddEventHandler('rv-npc:server:registerDeath', function(npcNetId)
    if NPC_Data[npcNetId] then
        MySQL.update('UPDATE rv_npcs SET is_dead = 1 WHERE npc_id = ?', {NPC_Data[npcNetId].npc_id})
        NPC_Data[npcNetId] = nil
    end
end)

-- Limpieza Automática de Entidades
AddEventHandler('entityRemoved', function(entity)
    local netId = NetworkGetNetworkIdFromEntity(entity)
    if NPC_Data[netId] then NPC_Data[netId] = nil end
end)
