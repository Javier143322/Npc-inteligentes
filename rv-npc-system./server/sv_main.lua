-- ============================================================
-- PROYECTO: ROCKSTAR VALLE - SISTEMA DE NPCS AUTÓNOMOS
-- COMPONENTE: SERVIDOR - MEMORIA, SQL, INVENTARIO Y ALERTAS
-- ============================================================

local NPC_Data = {} -- Caché temporal para no saturar la DB

-- 1. FUNCIÓN: GENERADOR DE ITEMS (Bolsillos)
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

-- 2. REGISTRO Y CARGA DE NPC (SQL)
RegisterNetEvent('rv-npc:server:initNPC')
AddEventHandler('rv-npc:server:initNPC', function(npcNetId, modelHash)
    local src = source
    local uniqueID = "NPC_" .. modelHash .. "_" .. npcNetId

    MySQL.prepare('SELECT * FROM rv_npcs WHERE npc_id = ?', {uniqueID}, function(result)
        if result then
            TriggerClientEvent('rv-npc:client:setNPCData', src, npcNetId, result)
            NPC_Data[npcNetId] = result
            print("^4[Rockstar Valle]^7 NPC Reconocido: " .. uniqueID)
        else
            local name = "Ciudadano_" .. math.random(1000, 9999)
            local job = 'unemployed'
            
            MySQL.insert('INSERT INTO rv_npcs (npc_id, name, reputation, job) VALUES (?, ?, ?, ?)', 
            {uniqueID, name, 50, job}, function(id)
                NPC_Data[npcNetId] = {npc_id = uniqueID, name = name, reputation = 50, job = job}
                print("^2[Rockstar Valle]^7 Nuevo registro: " .. name)
            end)
        end
        
        -- Generar Inventario Físico (ox_inventory)
        local stashName = "npc_" .. npcNetId
        local jobType = (NPC_Data[npcNetId] and NPC_Data[npcNetId].job) or 'unemployed'
        local itemsParaDar = GenerarItemsNPC(jobType)

        exports.ox_inventory:RegisterStash(stashName, "Bolsillos del Ciudadano", 5, 2000)
        for _, v in pairs(itemsParaDar) do
            exports.ox_inventory:AddItem(stashName, v.item, v.count)
        end
    end)
end)

-- 3. SISTEMA DE ALERTAS POLICIALES (TESTIGOS)
RegisterNetEvent('rv-npc:server:policeAlert')
AddEventHandler('rv-npc:server:policeAlert', function(coords, motivo)
    local src = source
    local players = GetPlayers()

    print("^1[Rockstar Valle]^7 Alerta Policial: " .. motivo .. " en Coords: " .. tostring(coords))

    for _, playerId in ipairs(players) do
        -- VALIDACIÓN DE TRABAJO: Ajusta 'police' según tu framework (QB o ESX)
        -- Ejemplo para ESX: if xPlayer.job.name == 'police' then
        -- Ejemplo para QBCore: if Player.PlayerData.job.name == 'police' then
        
        -- Enviamos la notificación y el blip (punto en el mapa) a los oficiales
        TriggerClientEvent('ox_lib:notify', playerId, {
            title = 'CENTRAL 911: TESTIGO',
            description = motivo .. ' informado por un ciudadano.',
            type = 'inform',
            duration = 10000
        })
        
        -- Aquí podrías disparar un evento de tu dispatch habitual (cd_dispatch, ps-dispatch, etc.)
        -- TriggerClientEvent('ps-dispatch:client:npcAlert', playerId, coords, motivo)
    end
end)

-- 4. ACTUALIZACIÓN DE REPUTACIÓN Y MUERTE
RegisterNetEvent('rv-npc:server:updateReputation')
AddEventHandler('rv-npc:server:updateReputation', function(npcNetId, amount)
    if NPC_Data[npcNetId] then
        local uniqueID = NPC_Data[npcNetId].npc_id
        MySQL.update('UPDATE rv_npcs SET reputation = reputation + ? WHERE npc_id = ?', {amount, uniqueID})
    end
end)

RegisterNetEvent('rv-npc:server:registerDeath')
AddEventHandler('rv-npc:server:registerDeath', function(npcNetId)
    if NPC_Data[npcNetId] then
        local uniqueID = NPC_Data[npcNetId].npc_id
        MySQL.update('UPDATE rv_npcs SET is_dead = 1 WHERE npc_id = ?', {uniqueID})
        print("^1[Rockstar Valle]^7 CK registrado: " .. uniqueID)
    end
end)

-- 5. LIMPIEZA DE MEMORIA
AddEventHandler('entityRemoved', function(entity)
    local netId = NetworkGetNetworkIdFromEntity(entity)
    if NPC_Data[netId] then NPC_Data[netId] = nil end
end)
