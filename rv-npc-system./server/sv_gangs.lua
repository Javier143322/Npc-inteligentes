-- ============================================================
-- PROYECTO: ROCKSTAR VALLE - SISTEMA DE NPCS AUTÓNOMOS
-- COMPONENTE: PERSISTENCIA DE BANDAS (sv_gangs.lua)
-- ============================================================

local PlayerGangRep = {} -- Caché: PlayerGangRep[identifier][gangName] = reputación

-- 1. CARGAR REPUTACIÓN AL ENTRAR EL JUGADOR
-- (Adaptar 'identifier' según tu base: license, steam o citizenid)
RegisterNetEvent('rv-npc:server:loadGangRep')
AddEventHandler('rv-npc:server:loadGangRep', function()
    local src = source
    local identifier = GetPlayerIdentifier(src, 0) -- Usamos licencia por defecto

    MySQL.query('SELECT gang_name, reputation FROM player_gangs WHERE identifier = ?', {identifier}, function(results)
        PlayerGangRep[identifier] = {}
        if results then
            for _, row in ipairs(results) do
                PlayerGangRep[identifier][row.gang_name] = row.reputation
            end
        end
        -- Sincronizamos con el cliente para que sepa si le dispararán o no
        TriggerClientEvent('rv-npc:client:syncGangRep', src, PlayerGangRep[identifier])
    end)
end)

-- 2. ACTUALIZAR REPUTACIÓN (EVENTO POR ASESINATO O ACCIÓN)
RegisterNetEvent('rv-npc:server:updateGangRep')
AddEventHandler('rv-npc:server:updateGangRep', function(gangName, amount)
    local src = source
    local identifier = GetPlayerIdentifier(src, 0)
    
    if not PlayerGangRep[identifier] then PlayerGangRep[identifier] = {} end
    
    local currentRep = PlayerGangRep[identifier][gangName] or 50 -- 50 es neutral
    local newRep = currentRep + amount
    
    -- Limitar reputación entre 0 y 100
    if newRep < 0 then newRep = 0 end
    if newRep > 100 then newRep = 100 end

    PlayerGangRep[identifier][gangName] = newRep

    -- Guardar en DB (Upsert)
    MySQL.query('INSERT INTO player_gangs (identifier, gang_name, reputation) VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE reputation = ?', 
    {identifier, gangName, newRep, newRep})

    Utils.Log("Reputación de jugador "..src.." con "..gangName.." actualizada a: "..newRep)
    
    -- Avisar al cliente del cambio
    TriggerClientEvent('rv-npc:client:syncGangRep', src, PlayerGangRep[identifier])
end)

-- 3. SQL NECESARIO (Añadir a utils/npcs.sql si lo deseas)
-- CREATE TABLE IF NOT EXISTS `player_gangs` (
--   `identifier` VARCHAR(100) NOT NULL,
--   `gang_name` VARCHAR(50) NOT NULL,
--   `reputation` INT DEFAULT 50,
--   PRIMARY KEY (`identifier`, `gang_name`)
-- ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
