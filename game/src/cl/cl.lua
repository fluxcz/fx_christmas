local spawnedprops = {}
local isspawning = {}
local collectedprops = {}
local isbusy = false
local playerped = PlayerPedId()
local playercoords = GetEntityCoords(playerped)
local snowloaded = false
local lastsnowballpickup = 0

local function updateplayerdata()
    playerped = PlayerPedId()
    playercoords = GetEntityCoords(playerped)
end

Citizen.CreateThread(function()
    Wait(1000)
    
    local success, result = pcall(function()
        return lib.callback.await('fxchristmas:server:getcollected', false)
    end)
    
    if success and result then
        collectedprops = result
    else
        Wait(5000)
        local retrysuccess, retryresult = pcall(function()
            return lib.callback.await('fxchristmas:server:getcollected', false)
        end)
        if retrysuccess and retryresult then
            collectedprops = retryresult
        else
        end
    end
end)

function tablelength(t)
    local count = 0
    if t then
        for _ in pairs(t) do count = count + 1 end
    end
    return count
end

if fx.enablesnow then
    local hasshownsnowballnotify = false
    
    Citizen.CreateThread(function()
        while true do
            SetWeatherTypeNowPersist('XMAS')
            
            Citizen.Wait(500)
            
            if IsNextWeatherType('XMAS') then
                N_0xc54a08c85ae4d410(3.0)
                
                SetForceVehicleTrails(true)
                SetForcePedFootstepsTracks(true)
                
                if not snowloaded then
                    RequestScriptAudioBank("ICE_FOOTSTEPS", false)
                    RequestScriptAudioBank("SNOW_FOOTSTEPS", false)
                    RequestNamedPtfxAsset("core_snow")
                    while not HasNamedPtfxAssetLoaded("core_snow") do
                        Citizen.Wait(500)
                    end
                    UseParticleFxAssetNextCall("core_snow")
                    snowloaded = true
                    
                    if fx.enablesnowballs and not hasshownsnowballnotify then
                        lib.notify({
                            type = 'info',
                            description = 'Press [G] while on foot to pickup snowballs!',
                            duration = 10000
                        })
                        hasshownsnowballnotify = true
                    end
                end
                
                if fx.enablesnowballs then
                    RequestAnimDict('anim@mp_snowball')
                    
                    local currenttime = GetGameTimer()
                    if IsControlJustReleased(0, fx.snowballsettings.pickupkey) and 
                       not IsPedInAnyVehicle(PlayerPedId(), true) and 
                       not IsPlayerFreeAiming(PlayerId()) and 
                       not IsPedSwimming(PlayerPedId()) and 
                       not IsPedSwimmingUnderWater(PlayerPedId()) and 
                       not IsPedRagdoll(PlayerPedId()) and 
                       not IsPedFalling(PlayerPedId()) and 
                       not IsPedRunning(PlayerPedId()) and 
                       not IsPedSprinting(PlayerPedId()) and 
                       GetInteriorFromEntity(PlayerPedId()) == 0 and 
                       not IsPedShooting(PlayerPedId()) and 
                       not IsPedUsingAnyScenario(PlayerPedId()) and 
                       not IsPedInCover(PlayerPedId(), 0) and
                       (currenttime - lastsnowballpickup) >= fx.snowballsettings.pickupcooldown then
                        
                        TaskPlayAnim(PlayerPedId(), 'anim@mp_snowball', 'pickup_snowball', 8.0, -1, -1, 0, 1, 0, 0, 0)
                        lastsnowballpickup = currenttime
                        Citizen.Wait(fx.snowballsettings.pickupcooldown)
                        
                        TriggerServerEvent('fxchristmas:server:pickupsnowball')
                    end
                end
            else
                if snowloaded then 
                    N_0xc54a08c85ae4d410(0.0) 
                    snowloaded = false
                    hasshownsnowballnotify = false
                    RemoveNamedPtfxAsset("core_snow")
                    ReleaseNamedScriptAudioBank("ICE_FOOTSTEPS")
                    ReleaseNamedScriptAudioBank("SNOW_FOOTSTEPS")
                    SetForceVehicleTrails(false)
                    SetForcePedFootstepsTracks(false)
                end
            end
            
            if GetSelectedPedWeapon(PlayerPedId()) == GetHashKey('WEAPON_SNOWBALL') then
                SetPlayerWeaponDamageModifier(PlayerId(), 0.0)
            end
        end
    end)
end

Citizen.CreateThread(function()
    while true do
        updateplayerdata()
        Wait(500)
    end
end)

Citizen.CreateThread(function()
    while true do
        local sleep = 1000
        local nearbyprops = false

        for index, location in ipairs(fx.locations) do
            if not collectedprops[index] then
                local locationvec = location.coords
                if locationvec then
                    local locationpos = vector3(locationvec.x, locationvec.y, locationvec.z)
                    local distance = #(playercoords - locationpos)

                    if distance < fx.viewdistance then
                        nearbyprops = true
                        
                        if not isspawning[index] and (not spawnedprops[index] or not DoesEntityExist(spawnedprops[index])) then
                            spawnprop(index, locationvec)
                        end
                        
                        if distance < 2.0 and not isbusy then
                            if fx.interactiontype == 'text' then
                                sleep = 0
                                drawtext3d(locationvec.x, locationvec.y, locationvec.z + 1.0, "[E] Collect Gift")
                                if IsControlJustReleased(0, 38) then
                                    collectgift(index)
                                end
                            end
                        end
                    else
                        if spawnedprops[index] and DoesEntityExist(spawnedprops[index]) then
                            if fx.interactiontype == 'target' then
                                pcall(function()
                                    exports.ox_target:removeLocalEntity(spawnedprops[index], 'vzitdarek')
                                end)
                            end
                            DeleteEntity(spawnedprops[index])
                            spawnedprops[index] = nil
                        end
                    end
                end
            else
                if spawnedprops[index] and DoesEntityExist(spawnedprops[index]) then
                    if fx.interactiontype == 'target' then
                        pcall(function()
                            exports.ox_target:removeLocalEntity(spawnedprops[index], 'vzitdarek')
                        end)
                    end
                    DeleteEntity(spawnedprops[index])
                    spawnedprops[index] = nil
                end
            end
        end

        if not nearbyprops then
            sleep = 2000
        end

        Wait(sleep)
    end
end)

function spawnprop(index, locationvec)
    if not locationvec or not locationvec.x or not locationvec.y or not locationvec.z then
        return
    end

    isspawning[index] = true
    
    Citizen.CreateThread(function()
        local modelhash = GetHashKey(fx.propname)
        
        if not IsModelInCdimage(modelhash) then
            isspawning[index] = false
            return
        end

        RequestModel(modelhash)
        local timeout = 0
        while not HasModelLoaded(modelhash) do
            Wait(10)
            timeout = timeout + 10
            if timeout > 5000 then
                isspawning[index] = false
                return
            end
        end

        updateplayerdata()
        local locationpos = vector3(locationvec.x, locationvec.y, locationvec.z)
        if #(playercoords - locationpos) > fx.viewdistance then
             isspawning[index] = false
             SetModelAsNoLongerNeeded(modelhash)
             return
        end

        local obj = CreateObject(modelhash, locationvec.x, locationvec.y, locationvec.z, false, false, false)
        
        if not obj or obj == 0 then
            isspawning[index] = false
            SetModelAsNoLongerNeeded(modelhash)
            return
        end

        local objtimeout = 0
        while not DoesEntityExist(obj) and objtimeout < 1000 do
            Wait(10)
            objtimeout = objtimeout + 10
        end

        if not DoesEntityExist(obj) then
            isspawning[index] = false
            SetModelAsNoLongerNeeded(modelhash)
            return
        end
        
        PlaceObjectOnGroundProperly(obj)
        SetEntityHeading(obj, locationvec.w or 0.0)
        FreezeEntityPosition(obj, true)
        
        spawnedprops[index] = obj
        isspawning[index] = false
        
        if fx.interactiontype == 'target' then
            pcall(function()
                exports.ox_target:addLocalEntity(obj, {
                    {
                        name = 'vzitdarek_' .. index,
                        label = 'Collect Gift',
                        icon = 'fa-solid fa-gift',
                        onSelect = function()
                            collectgift(index)
                        end,
                        canInteract = function(entity, distance, coords, name, bone)
                            return not collectedprops[index]
                        end
                    }
                })
            end)
        end
        
        SetModelAsNoLongerNeeded(modelhash)
    end)
end

function collectgift(index)
    if isbusy then return end
    
    if not index or type(index) ~= 'number' then
        return
    end
    
    if collectedprops[index] then
        lib.notify({type = 'error', description = 'Already collected!'})
        return
    end
    
    isbusy = true

    if fx.collectionanim and fx.collectionanim.dict then
        RequestAnimDict(fx.collectionanim.dict)
        local animtimeout = 0
        while not HasAnimDictLoaded(fx.collectionanim.dict) and animtimeout < 2000 do
            Wait(10)
            animtimeout = animtimeout + 10
        end
    end

    local progresssuccess = lib.progressBar({
        duration = fx.collectionanim.duration,
        label = fx.collectionanim.label,
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
            move = true,
            combat = true
        },
        anim = {
            dict = fx.collectionanim.dict,
            clip = fx.collectionanim.anim
        }
    })

    if progresssuccess then
        TriggerServerEvent('fxchristmas:server:collect', index)
    else
        lib.notify({type = 'error', description = 'Cancelled'})
    end

    isbusy = false
end

RegisterNetEvent('fxchristmas:client:markcollected', function(index)
    if not index or type(index) ~= 'number' then
        return
    end
    
    collectedprops[index] = true
    
    if spawnedprops[index] and DoesEntityExist(spawnedprops[index]) then
        if fx.interactiontype == 'target' then
            pcall(function()
                exports.ox_target:removeLocalEntity(spawnedprops[index], 'vzitdarek')
            end)
        end
        DeleteEntity(spawnedprops[index])
        spawnedprops[index] = nil
    end
end)

function drawtext3d(x, y, z, text)
    local onscreen, _x, _y = World3dToScreen2d(x, y, z)
    
    if onscreen then
        SetTextScale(0.35, 0.35)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextEntry("STRING")
        SetTextCentre(true)
        AddTextComponentString(text)
        SetDrawOrigin(x, y, z, 0)
        DrawText(0.0, 0.0)
        local factor = (string.len(text)) / 370
        DrawRect(0.0, 0.0 + 0.0125, 0.017 + factor, 0.03, 0, 0, 0, 75)
        ClearDrawOrigin()
    end
end

AddEventHandler('onResourceStop', function(resourcename)
    if GetCurrentResourceName() ~= resourcename then return end
    
    for k, v in pairs(spawnedprops) do
        if DoesEntityExist(v) then
            if fx.interactiontype == 'target' then
                pcall(function()
                    exports.ox_target:removeLocalEntity(v, 'vzitdarek')
                end)
            end
            DeleteEntity(v)
        end
    end
    
    if fx.enablesnow and snowloaded then
        ClearOverrideWeather()
        ClearWeatherTypePersist()
        N_0xc54a08c85ae4d410(0.0)
        RemoveNamedPtfxAsset("core_snow")
        ReleaseNamedScriptAudioBank("ICE_FOOTSTEPS")
        ReleaseNamedScriptAudioBank("SNOW_FOOTSTEPS")
        SetForceVehicleTrails(false)
        SetForcePedFootstepsTracks(false)
    end
end)
