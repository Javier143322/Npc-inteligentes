-- ============================================================
-- PROYECTO: ROCKSTAR VALLE - SISTEMA DE NPCS AUTÓNOMOS
-- COMPONENTE: UTILIDADES Y PUENTE NEO-EVO (sh_utils.lua)
-- ============================================================

Utils = {}

-- 1. SISTEMA DE LOGS (Consola)
-- Mantenemos tu lógica original de Rockstar Valle
Utils.Log = function(msg)
    local timestamp = os.date("%H:%M:%S")
    print(string.format("^4[%s]^7 %s", timestamp, msg))
end

-- 2. SISTEMA DE NOTIFICACIONES (Integrado con ox_lib)
-- Mantenemos tu lógica original para cliente y servidor
Utils.Notify = function(target, title, msg, type)
    if IsDuplicityVersion() then -- Lado Servidor
        TriggerClientEvent('ox_lib:notify', target, {
            title = title,
            description = msg,
            type = type or 'inform'
        })
    else -- Lado Cliente
        exports.ox_lib:notify({
            title = title,
            description = msg,
            type = type or 'inform'
        })
    end
end

-- 3. [MEJORA] EL PUENTE: LECTOR DE ADN NEO-EVO
-- Esta función permite que los NPCs de Rockstar Valle te RECONOZCAN
Utils.GetPlayerBioData = function(serverId)
    local data = {
        class = "Desconocido",
        humanity = 100,
        isCiberpsicopata = false,
        adnLevel = 1
    }

    -- Consultamos al export de tu sistema NEO-EVO
    local success, result = pcall(function()
        -- Cambia 'neo_evo' por el nombre exacto de la carpeta de tu otro script si es distinto
        return exports['neo_evo']:GetPlayerData(serverId) 
    end)

    if success and result then
        data.class = result.class or "Civil"
        data.humanity = result.humanity or 100
        data.isCiberpsicopata = (data.humanity < 20)
        data.adnLevel = result.level or 1
    end

    return data
end

-- 4. VALIDACIÓN DE DISTANCIA (Optimizada)
Utils.IsClose = function(coords1, coords2, dist)
    return #(coords1 - coords2) < dist
end
