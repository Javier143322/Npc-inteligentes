
-- ============================================================
-- PROYECTO: ROCKSTAR VALLE - SISTEMA DE NPCS AUTÓNOMOS
-- COMPONENTE: ECONOMÍA ACTIVA (sv_economy.lua)
-- ============================================================

-- 1. CONFIGURACIÓN DE PRECIOS Y NEGOCIOS
local ConfigEconomia = {
    ComidaRapida = { precio = math.random(25, 50), label = "Burgershot" },
    RestauranteLujo = { precio = math.random(150, 300), label = "Restaurante" },
    PropinaDelivery = { min = 10, max = 35 }
}

-- 2. EVENTO: EL NPC CONSUME EN UN LOCAL
-- Este evento se dispara cuando un NPC llega a un restaurante propiedad de un jugador
RegisterNetEvent('rv-npc:server:payForService')
AddEventHandler('rv-npc:server:payForService', function(tipoNegocio, accountName)
    local src = source
    local precio = 0
    local label = ""

    if ConfigEconomia[tipoNegocio] then
        precio = ConfigEconomia[tipoNegocio].precio
        label = ConfigEconomia[tipoNegocio].label
    else
        precio = math.random(15, 30)
        label = "Comercio"
    end

    -- LÓGICA: Inyectar dinero en la caja del negocio (Management de sociedad)
    -- Asumimos que usas esx_addonaccount o qb-management (ajustar según tu base)
    if accountName then
        -- Ejemplo para QBCore/Management o ESX Sociedad
        -- exports['qb-management']:AddMoney(accountName, precio)
        print("^2[Rockstar Valle]^7 NPC pagó $"..precio.." en el negocio: "..accountName)
    else
        -- Si no hay dueño, el dinero simplemente se "quema" o va a una cuenta del gobierno
        print("^3[Rockstar Valle]^7 NPC consumió $"..precio.." en local sin dueño.")
    end
end)

-- 3. EVENTO: PAGO DE DELIVERY A JUGADOR
-- Se dispara cuando un jugador repartidor entrega un pedido a un NPC
RegisterNetEvent('rv-npc:server:completeDelivery')
AddEventHandler('rv-npc:server:completeDelivery', function(netIdNPC)
    local src = source -- El jugador repartidor
    local propina = math.random(ConfigEconomia.PropinaDelivery.min, ConfigEconomia.PropinaDelivery.max)
    
    -- Usamos ox_inventory para dar dinero físico al jugador
    exports.ox_inventory:AddItem(src, 'money', propina)
    
    TriggerClientEvent('ox_lib:notify', src, {
        title = 'Entrega Completada',
        description = 'El ciudadano te ha dado $'..propina..' de propina.',
        type = 'success'
    })

    -- Subimos reputación del jugador con ese NPC específico (Gratitud)
    TriggerEvent('rv-npc:server:updateReputation', netIdNPC, 2)
end)

-- 4. EVENTO: ROBO AL NPC
-- Se dispara si el jugador logra robar exitosamente al NPC
RegisterNetEvent('rv-npc:server:robNPC')
AddEventHandler('rv-npc:server:robNPC', function(npcNetId)
    local src = source
    local stashName = "npc_" .. npcNetId

    -- El jugador abre el inventario del NPC (que ya creamos en sv_main.lua)
    -- Requiere que el NPC esté con las manos arriba o muerto
    exports.ox_inventory:forceOpenInventory(src, 'stash', stashName)
    
    -- Bajamos reputación drásticamente por robo
    TriggerEvent('rv-npc:server:updateReputation', npcNetId, -20)
    print("^1[Rockstar Valle]^7 El jugador "..src.." está robando al NPC "..npcNetId)
end)
