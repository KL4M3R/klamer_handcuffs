ESX = exports["es_extended"]:getSharedObject()




CreateThread(function()
    for k,v in pairs(ESX.GetPlayers()) do
        local xPlayer = ESX.GetPlayerFromId(v)
        if Player(v).state.klamer_PlayerIsCuffed then
            Player(v).state.klamer_PlayerIsCuffed = false
        end
        if Player(v).state.klamer_HaveOpenedInventory then
            Player(v).state.klamer_HaveOpenedInventory = false
        end
        if Player(v).state.klamer_PlayerIsDragged then
            Player(v).state.klamer_PlayerIsDragged = false
        end
        if Player(v).state.klamer_PlayerDraggingSomeone then
            Player(v).state.klamer_PlayerDraggingSomeone = false
        end
    end
end)


RegisterNetEvent("klamer_handcuffs:cuffPlayer", function(target, playerheading, coords, playerlocation)
    local player = source
    local xPlayer = ESX.GetPlayerFromId(player)
    local targetPed = GetPlayerPed(target)

    if not DoesEntityExist(targetPed) then
        TriggerClientEvent('klamer_notify_handcuff',"you can't handcuff")
        return
    end

    local targetCoords = GetEntityCoords(targetPed)
    local localCoords = GetEntityCoords(GetPlayerPed(player))
    local distance = #(targetCoords-localCoords)

    if distance > 3.0 then
        TriggerClientEvent('klamer_notify_handcuff', "you are too far away")
        return
    end

    if Player(player).state.klamer_PlayerIsCuffed then
        TriggerClientEvent('klamer_notify_handcuff', "You can't cuff while cuffed")
        return
    end

    if Player(target).state.klamer_PlayerIsCuffed then
        TriggerClientEvent('klamer_notify_handcuff', "This person is already handcuffed")
        return
    end

    Player(target).state.klamer_PlayerIsCuffed = true

    if playerheading then
        TriggerClientEvent("klamer_handcuffs:cuffMe", target, playerheading, coords, playerlocation)
        TriggerClientEvent("klamer_handcuffs:cuffHim", player, true)
    else
        TriggerClientEvent("klamer_handcuffs:cuffMe", target)
        TriggerClientEvent("klamer_handcuffs:cuffHim", player, false)
    end

    TriggerClientEvent('klamer_notify_handcuff',"You handcuffed ID: ["..target.."]")
    local xTarget = ESX.GetPlayerFromId(target)
    xTarget.showNotification("You have been handcuffed by the ID: ["..player.."]")

    local targetLicense = string.gsub(GetPlayerIdentifier(player,1),"license:","")
end)

RegisterNetEvent("klamer_handcuffs:uncuffPlayer", function(target, playerheading, coords, playerlocation)
    local player = source
    local xPlayer = ESX.GetPlayerFromId(player)

    if Player(player).state.klamer_PlayerIsCuffed then
        TriggerClientEvent('klamer_notify_handcuff',"You can't uncuff while handcuffed.")
        return
    end

    if not Player(target).state.klamer_PlayerIsCuffed then
        TriggerClientEvent('klamer_notify_handcuff',"This person is not handcuffed")
        return
    end

    Player(target).state.klamer_PlayerIsCuffed = false

    TriggerClientEvent("klamer_handcuffs:uncuffMe", target, playerheading, coords, playerlocation)
    TriggerClientEvent("klamer_handcuffs:uncuffHim", player)

    TriggerClientEvent('klamer_notify_handcuff',"you forged handcuffs ID: ["..target.."]")
    local xTarget = ESX.GetPlayerFromId(target)
    xTarget.showNotification("you have been handcuffed: ["..player.."]")

    local targetLicense = string.gsub(GetPlayerIdentifier(player,1),"license:","")
end)

RegisterNetEvent("klamer_handcuffs:searchInventory", function(target)
    local player = source
    local xPlayer = ESX.GetPlayerFromId(player)
    local targetLicense = string.gsub(GetPlayerIdentifier(player,1),"license:","")
    if Player(player).state.klamer_PlayerIsCuffed then
        TriggerClientEvent('klamer_notify_handcuff',"You can't search while you're handcuffed")
        return
    end

    local targetCoords = GetEntityCoords(GetPlayerPed(target))
    local localCoords = GetEntityCoords(GetPlayerPed(player))
    local distance = #(targetCoords-localCoords)

    if distance > 6.0 then
        TriggerClientEvent('klamer_notify_handcuff',"This person is too far away!")
        return
    end

    --if Player(target).state.klamer_HaveOpenedInventory then
    --    TriggerClientEvent('klamer_notify_handcuff',("Juz ktoś przeszukuje tą osobę")
    --    return
    --end

    Player(target).state.klamer_HaveOpenedInventory = true
    Player(source).state.klamer_IsPlayerSearchingInventory = target
    TriggerClientEvent("klamer_handcuffs:getInventory", player, target)

    TriggerClientEvent('klamer_notify_handcuff',"You search ID: ["..target.."]")
    local xTarget = ESX.GetPlayerFromId(target)
    xTarget.showNotification("You have been searched by ID: ["..player.."]")
end)

RegisterNetEvent("klamer_handcuffs:uncuffed", function()
    local player = source
    local xPlayer = ESX.GetPlayerFromId(player)

    if Player(player).state.klamer_PlayerIsCuffed then
        Player(player).state.klamer_PlayerIsCuffed = false
        return
    end
end)

RegisterNetEvent("klamer_handcuffs:dragPlayer", function(target)
    local player = source
    local xPlayer = ESX.GetPlayerFromId(player)

    if not target then
        return
    end

    local targetCoords = GetEntityCoords(GetPlayerPed(target))
    if not targetCoords then
        return
    end
    local localCoords = GetEntityCoords(GetPlayerPed(player))
    local dist = #(targetCoords-localCoords)

    if dist > 10.0 then
        TriggerClientEvent('klamer_notify_handcuff',"You are too far away!")
    
        return
    end
    
    if Player(target).state.klamer_PlayerIsDragged then
        TriggerClientEvent('klamer_notify_handcuff',"The player is already being transferred!")
        return
    end

    Player(target).state.klamer_PlayerIsDragged = true
    Player(player).state.klamer_PlayerDraggingSomeone = true

    TriggerClientEvent("klamer_handcuffs:dragMe", target, player)
end)

RegisterNetEvent("klamer_handcuffs:unDragPlayer", function(target)
    local player = source
    local xPlayer = ESX.GetPlayerFromId(player)

    if not target then
        if Player(player).state.klamer_PlayerDraggingSomeone then
            Player(player).state.klamer_PlayerDraggingSomeone = false
        end
        return
    end

    local targetCoords = GetEntityCoords(GetPlayerPed(target))
    if not targetCoords then
        return
    end
    local localCoords = GetEntityCoords(GetPlayerPed(player))
    local dist = #(targetCoords-localCoords)

    if dist > 10.0 then
        TriggerClientEvent('klamer_notify_handcuff',"You are too far away!")
        return
    end
    
    if not Player(target).state.klamer_PlayerIsDragged then
        TriggerClientEvent('klamer_notify_handcuff',"The player is not transferred")
        return
    end

    Player(target).state.klamer_PlayerIsDragged = false
    Player(player).state.klamer_PlayerDraggingSomeone = false

    TriggerClientEvent("klamer_handcuffs:unDrag", target)
end)

RegisterNetEvent("klamer_handcuffs:closeInventory", function()
    local player = source
    local xPlayer = ESX.GetPlayerFromId(player)

    if not Player(player).state.klamer_IsPlayerSearchingInventory then
        return
    end

    if Player(player).state.klamer_IsPlayerSearchingInventory ~= 0 then
        local target = Player(player).state.klamer_IsPlayerSearchingInventory
        Player(target).state.klamer_HaveOpenedInventory = false
        Player(player).state.klamer_IsPlayerSearchingInventory = 0
    end
end)

RegisterNetEvent("klamer_handcuffs:setPedIntoVehicle", function(target,vehicle,seat)
    local player = source
    local xPlayer = ESX.GetPlayerFromId(player)
    local coords = GetEntityCoords(GetPlayerPed(player))

    local targetPed = GetPlayerPed(target)
    local targetCoords = GetEntityCoords(targetPed)

    local dist = #(coords - targetCoords)

    if dist > 10.0 then
        TriggerClientEvent('klamer_notify_handcuff',"The player is too far away")
    
        return
    end

    TriggerClientEvent("klamer_handcuffs:setMeInVehicle",target,vehicle,seat)
end)

RegisterNetEvent("klamer_handcuffs:lockpickDelete", function()
    local player = source
    local xPlayer = ESX.GetPlayerFromId(player)
    local item = xPlayer.getInventoryItem(Config.req_items['lockpick'])
    if item.count > 0 then
        TriggerClientEvent('klamer_notify_handcuff',"You broke the lockpick")
        xPlayer.removeInventoryItem(Config.req_items['lockpick'],1)
    end
end)

RegisterNetEvent("klamer_handcuffs:getPedFromVehicle", function(target)
    local player = source
    local xPlayer = ESX.GetPlayerFromId(player)
    local coords = GetEntityCoords(GetPlayerPed(player))

    local targetPed = GetPlayerPed(target)
    local targetCoords = GetEntityCoords(targetPed)

    local dist = #(coords - targetCoords)

    if dist > 10.0 then
        TriggerClientEvent('klamer_notify_handcuff',"The player is too far away")
        return
    end

    TriggerClientEvent("klamer_handcuffs:leaveVehicle",target)
end)
