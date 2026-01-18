
-- ============================================================
-- PROYECTO: ROCKSTAR VALLE - UTILIDADES COMPARTIDAS
-- ============================================================

Utils = {}

-- Función de Notificación Universal (Adaptada a ox_lib)
Utils.Notify = function(target, title, msg, type)
    if IsDuplicityVersion() then -- Si se ejecuta en el Servidor
        TriggerClientEvent('ox_lib:notify', target, {
            title = title,
            description = msg,
            type = type or 'inform'
        })
    else -- Si se ejecuta en el Cliente
        exports.lib:notify({
            title = title,
            description = msg,
            type = type or 'inform'
        })
    end
end

-- Función para Debug de Rockstar Valle (Solo sale en consola si Config.Debug es true)
Utils.Log = function(msg)
    if Config.Debug then
        local prefix = IsDuplicityVersion() and "^4[SERVER]^7" or "^2[CLIENT]^7"
        print(prefix .. " ^5[Rockstar Valle]^7 " .. msg)
    end
end

-- Exportamos la tabla para que otros archivos la vean
exports('GetUtils', function()
    return Utils
end)
