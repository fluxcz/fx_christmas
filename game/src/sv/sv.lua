local ox_inventory = exports.ox_inventory
local lastcollectionattempt = {}
local lastsnowballpickup = {}
local collection_cooldown = 2000
local snowball_cooldown = 2000
local version = '1.0'

local function checkversion()
    CreateThread(function()
        PerformHttpRequest('https://api.github.com/repos/fluxcz/fx_christmas/releases/latest', function(err, text, headers)
            if err ~= 200 then
                print('^1[FX_CHRISTMAS] Could not check for new version.^7')
                return
            end

            local data = json.decode(text)
            if data.tag_name == version then
                print('^6[FX_CHRISTMAS] You are running the latest version.^7')
            else
                print('^1-------------------------------------------------')
                print('^6New Version Released for fx_christmas\n')
                print('^1Your Version: ^7'..version)
                print('^6Newsest Version: ^7'..data.tag_name..'\n')
                print('^6Changelog:^7')
                print(data.body..'\n')
                print('Get the updated version: https://github.com/fluxcz/fx_christmas/archive/refs/tags/'..data.tag_name..'.zip')
                print('^1-------------------------------------------------^7')
            end
        end, 'GET')
    end)
end

MySQL.ready(function()
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS `fx_christmas` (
            `identifier` varchar(64) NOT NULL,
            `prop_index` int(11) NOT NULL,
            PRIMARY KEY (`identifier`, `prop_index`)
        )
    ]])
end)

local function getplayeridentifier(source)
    local identifier = GetPlayerIdentifierByType(source, 'license')
    if not identifier then
        identifier = GetPlayerIdentifierByType(source, 'steam')
    end
    if not identifier then
        identifier = GetPlayerIdentifierByType(source, 'discord')
    end
    return identifier
end

local function isplayervalid(source)
    return source and GetPlayerPed(source) and GetPlayerPed(source) > 0
end

lib.callback.register('fxchristmas:server:getcollected', function(source)
    if not isplayervalid(source) then
        return {}
    end

    local identifier = getplayeridentifier(source)
    if not identifier then 
        return {} 
    end

    local success, result = pcall(function()
        return MySQL.query.await('SELECT prop_index FROM fx_christmas WHERE identifier = ?', {identifier})
    end)

    if not success then
        return {}
    end

    local collected = {}
    if result and type(result) == 'table' then
        for _, row in ipairs(result) do
            if row.prop_index then
                collected[row.prop_index] = true
            end
        end
    end
    
    return collected
end)

RegisterNetEvent('fxchristmas:server:collect', function(index)
    local src = source
    
    if not isplayervalid(src) then
        return
    end

    local currenttime = GetGameTimer()
    if lastcollectionattempt[src] and (currenttime - lastcollectionattempt[src]) < collection_cooldown then
        return
    end
    lastcollectionattempt[src] = currenttime

    if type(index) ~= 'number' then
        return
    end

    if not fx.locations[index] then
        return
    end

    local identifier = getplayeridentifier(src)
    if not identifier then
        TriggerClientEvent('ox_lib:notify', src, {type = 'error', description = 'Authentication error'})
        return
    end

    local playerped = GetPlayerPed(src)
    if not playerped or playerped == 0 then
        return
    end

    local playercoords = GetEntityCoords(playerped)
    if not playercoords then
        return
    end

    local proploc = fx.locations[index].coords
    if not proploc then
        return
    end

    local propcoords = vector3(proploc.x, proploc.y, proploc.z)
    local distance = #(playercoords - propcoords)
    
    if distance > 10.0 then
        return
    end

    local success, count = pcall(function()
        return MySQL.scalar.await('SELECT COUNT(*) FROM fx_christmas WHERE identifier = ? AND prop_index = ?', {identifier, index})
    end)

    if not success then
        TriggerClientEvent('ox_lib:notify', src, {type = 'error', description = 'Database error, try again'})
        return
    end

    if count and count > 0 then
        TriggerClientEvent('ox_lib:notify', src, {type = 'error', description = 'You have already collected this gift!'})
        return
    end

    local rewardid = fx.locations[index].reward
    if not rewardid or type(rewardid) ~= 'number' then
        return
    end

    local reward = fx.rewards[rewardid]
    if not reward then
        return
    end

    local rewardsgiven = {}

    if reward.money and type(reward.money) == 'table' and reward.money.max > 0 then
        local amount = math.random(reward.money.min, reward.money.max)
        
        local successmoney, responsemoney = pcall(function()
            return ox_inventory:AddItem(src, 'money', amount)
        end)
        
        if successmoney and responsemoney then
            table.insert(rewardsgiven, ('$%s'):format(amount))
        else
            TriggerClientEvent('ox_lib:notify', src, {type = 'error', description = 'Failed to receive money reward'})
            return
        end
    end

    if reward.items and type(reward.items) == 'table' and #reward.items > 0 then
        for _, item in ipairs(reward.items) do
            if type(item) == 'table' and item.name and item.count then
                local successitem, responseitem = pcall(function()
                    return ox_inventory:AddItem(src, item.name, item.count)
                end)
                
                if successitem and responseitem then
                    table.insert(rewardsgiven, ('%sx %s'):format(item.count, item.name))
                else
                    TriggerClientEvent('ox_lib:notify', src, {type = 'error', description = 'Inventory full or item error!'})
                    return
                end
            end
        end
    end

    if #rewardsgiven == 0 then
        TriggerClientEvent('ox_lib:notify', src, {type = 'error', description = 'No rewards available'})
        return
    end

    local successdb, resultdb = pcall(function()
        return MySQL.insert.await('INSERT INTO fx_christmas (identifier, prop_index) VALUES (?, ?)', {identifier, index})
    end)

    TriggerClientEvent('ox_lib:notify', src, {
        type = 'success', 
        description = ('You received: %s'):format(table.concat(rewardsgiven, ', '))
    })
    
    TriggerClientEvent('fxchristmas:client:markcollected', src, index)

        GetPlayerName(src), identifier, index, table.concat(rewardsgiven, ', ')
    ))
end)

RegisterNetEvent('fxchristmas:server:pickupsnowball', function()
    local src = source
    
    if not isplayervalid(src) then
        return
    end

    local currenttime = GetGameTimer()
    if lastsnowballpickup[src] and (currenttime - lastsnowballpickup[src]) < snowball_cooldown then
        return
    end
    lastsnowballpickup[src] = currenttime

    local successsnowball, responsesnowball = pcall(function()
        return ox_inventory:AddItem(src, fx.snowballsettings.weaponname, fx.snowballsettings.snowballsperpickup)
    end)

    if successsnowball and responsesnowball then
        if fx.snowballsettings.notifyonpickup then
            TriggerClientEvent('ox_lib:notify', src, {
                type = 'info',
                description = ('Picked up %sx snowballs'):format(fx.snowballsettings.snowballsperpickup)
            })
        end
    else
        TriggerClientEvent('ox_lib:notify', src, {
            type = 'error',
            description = 'Inventory full!'
        })
    end
end)

AddEventHandler('playerDropped', function()
    local src = source
    if lastcollectionattempt[src] then
        lastcollectionattempt[src] = nil
    end
    if lastsnowballpickup[src] then
        lastsnowballpickup[src] = nil
    end
end)
