local timer = 0
local setInVehicle = false

ESX = exports["es_extended"]:getSharedObject()


function klamer_notify(title,text,time,type)
    if not text then text = '' end
    if not time then time = 2500 end
    if not type then type = 'info' end
    if Config.Notify == 'okokNotify' then
        exports['okokNotify']:Alert(title, text, time, type)
    elseif Config.Notify == 'ox_lib' then
        lib.notify({title = title,description = text,type = type})    
    else
            --Here you can paste your custom notification
    end
end






RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    PlayerData = xPlayer
end)



RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    ESX.PlayerData.job = job
end)
local hand_up = false
local can_use = true
if Config.HandsUp then
    RegisterCommand('_handsup',function()
        if can_use then
            if hand_up == false then
                can_use = false
                local dict = 'random@mugging3'
                RequestAnimDict(dict)
                while not HasAnimDictLoaded(dict) do
                    Citizen.Wait(10)
                end
                TaskPlayAnim(PlayerPedId(), dict, 'handsup_standing_base', 8.0, -8, .01, 49, 0, 0, 0, 0)
                hand_up = true
                Citizen.Wait(1000)
                can_use = true
            else
                can_use = false
                hand_up = false
                ClearPedTasks(PlayerPedId())
                Citizen.Wait(1000)
                can_use = true
            end
        end
    end)

    RegisterKeyMapping("_handsup", "raise your hand", "keyboard",Config.HandsUp_key)
end



local function drawTxt(text,x,y,scale,r,g,b,a)
    SetTextFont(0)
    SetTextProportional(1)
    SetTextScale(0.0, scale)
    SetTextColour(r,g,b,a)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextCentre(true)
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x,y)
end


RegisterNetEvent("esx:setJob", function(PlayerJob)
    PlayerData.job.name = PlayerJob.name
    PlayerData.job.grade = PlayerJob.grade
end)



local text_loop = false
exports['qtarget']:Player({
    options = {
        {
            icon = "fa-solid fa-handcuffs",
            label = "cuff",
            item = Config.req_items['handcuff'],
            event = 'zakajdankuj',
            canInteract = function(entity)
                if IsPedAPlayer(entity) then
                    local target = GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity))
                    local isDead = Player(GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity))).state.klamer_isDead
                    if Player(GetPlayerServerId(NetworkGetPlayerIndexFromPed(PlayerPedId()))).state.klamer_PlayerIsCuffed then
                        return false
                    end
                    if not Player(target).state.klamer_PlayerIsCuffed then
                        return true
                    else
                        return false
                    end
                end
            end
        },
        {
            icon = "fa-solid fa-handcuffs",
            label = "uncuff",
            item = Config.req_items['handcuff'],
            action = function(entity)
                local playerPed = PlayerPedId()
                local isDead = Player(GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity))).state.klamer_isDead
                if IsEntityPlayingAnim(entity, "mp_arresting", "idle", 3) or isDead then
                    local playerheading = GetEntityHeading(playerPed)
                    local playerlocation = GetEntityForwardVector(playerPed)
                    local coords = GetEntityCoords(playerPed)
                    TriggerServerEvent("klamer_handcuffs:uncuffPlayer", GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity)), playerheading, coords, playerlocation)
                else
                    klamer_notify("This player is not handcuffed")
                end
            end,
            canInteract = function(entity)
                if IsPedAPlayer(entity) then
                    local target = GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity))
                    local isDead = Player(GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity))).state.klamer_isDead
                    if Player(GetPlayerServerId(NetworkGetPlayerIndexFromPed(PlayerPedId()))).state.klamer_PlayerIsCuffed or isDead then
                        return false
                    end
                    if Player(target).state.klamer_PlayerIsCuffed then
                        return true
                    else
                        return false
                    end
                end
            end
        },
       
        {
            icon = "fa-solid fa-people-robbery",
            label = "Search",
            item = Config.req_items['handcuff'],
            action = function(entity)
                local playerPed = PlayerPedId()
                local target = Player(GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity))).state.klamer_PlayerIsCuffed
                if target then
                    TriggerServerEvent("klamer_handcuffs:searchInventory", GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity)))
                else
                    klamer_notify("you can only search a player when he is handcuffed or dead")
                end
            end,
            canInteract = function(entity)
                if IsPedAPlayer(entity) then
                    if Player(GetPlayerServerId(NetworkGetPlayerIndexFromPed(PlayerPedId()))).state.klamer_PlayerIsCuffed then
                        return false
                    end
                    local target = Player(GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity))).state.klamer_PlayerIsCuffed
                    if target then
                        return true
                    else
                        return false
                    end
                end
            end
        },
        {
            icon = "fa-solid fa-person-walking",
            label = "Move",
           -- item = "handcuffs",
            action = function(entity)
                local playerPed = PlayerPedId()

                local entityIsDragged = Player(GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity))).state.klamer_PlayerIsDragged
                local entityDraggingSomeone = Player(GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity))).state.klamer_PlayerDraggingSomeone
                local playerDraggingSomeone = LocalPlayer.state.klamer_PlayerDraggingSomeone
                if (not entityIsDragged and not entityDraggingSomeone and not playerDraggingSomeone and not target) then
                    TriggerServerEvent("klamer_handcuffs:dragPlayer", GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity)))
                    text_loop = true
                    move_3D_text_loop()
                else
                    klamer_notify("you can't move a player!")
                end
                
            end,
            canInteract = function(entity)
                if IsPedAPlayer(entity) then
                    local target = Player(GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity))).state.klamer_PlayerIsCuffed

                    local entityIsDragged = Player(GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity))).state.klamer_PlayerIsDragged
                    local entityDraggingSomeone = Player(GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity))).state.klamer_PlayerDraggingSomeone
                    local playerDraggingSomeone = LocalPlayer.state.klamer_PlayerDraggingSomeone
                    if (target and not entityIsDragged and not entityDraggingSomeone and not playerDraggingSomeone) then
                        return true
                    else
                        return false
                    end
                end
            end
        },
        {
            icon = "fa-solid fa-person-walking",
            label = "put the player away",
            action = function(entity)
                local playerPed = PlayerPedId()
                text_loop = false
                if ESX.PlayerData.job.name == "police" then
                    TriggerServerEvent("klamer_handcuffs:unDragPlayer", GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity)))
                else
                    klamer_notify("You can't let go of a player!")
                end
            end,
            canInteract = function(entity)
                if IsPedAPlayer(entity) then
                    local target = Player(GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity))).state.klamer_PlayerIsDragged
                    local playerState = Player(GetPlayerServerId(NetworkGetPlayerIndexFromPed(PlayerPedId()))).state.klamer_PlayerDraggingSomeone
                    if target and playerState then
                        return true
                    else
                        return false
                    end
                end
            end
        },
        {
            icon = "fa-solid fa-handcuffs",
            label = "uncuff (lockpick)",
            item = Config.req_items['lockpick'],
            action = function(entity)
                local playerPed = PlayerPedId()
                local target = Player(GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity))).state.klamer_PlayerIsDragged
                local isCuffed = Player(GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity))).state.klamer_PlayerIsCuffed
                local playerState = Player(GetPlayerServerId(NetworkGetPlayerIndexFromPed(PlayerPedId()))).state.klamer_PlayerDraggingSomeone
                local isCuffed2 = Player(GetPlayerServerId(NetworkGetPlayerIndexFromPed(PlayerPedId()))).state.klamer_PlayerIsCuffed
                if not playerState and not target and isCuffed and not isCuffed2 then
                    local success = lib.skillCheck({'medium', 'medium', 'hard'}, {'w', 'a', 's', 'd'})

                    if success then
                        local playerheading = GetEntityHeading(playerPed)
                        local playerlocation = GetEntityForwardVector(playerPed)
                        local coords = GetEntityCoords(playerPed)
                        TriggerServerEvent("klamer_handcuffs:uncuffPlayer", GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity)), playerheading, coords, playerlocation)
                    else
                        local ___klamer = math.random(1,2)
                        if ___klamer == 1 then
                            klamer_notify("You broke the lockpick")
                            TriggerServerEvent("klamer_handcuffs:lockpickDelete")
                        end
                    end
                else
                    klamer_notify("you can't break the handcuffs")
                end
            end,
            canInteract = function(entity)
                if IsPedAPlayer(entity) then
                    local target = Player(GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity))).state.klamer_PlayerIsDragged
                    local isCuffed = Player(GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity))).state.klamer_PlayerIsCuffed
                    local playerState = Player(GetPlayerServerId(NetworkGetPlayerIndexFromPed(PlayerPedId()))).state.klamer_PlayerDraggingSomeone
                    local isCuffed2 = Player(GetPlayerServerId(NetworkGetPlayerIndexFromPed(PlayerPedId()))).state.klamer_PlayerIsCuffed
                    if not playerState and not target and isCuffed and not isCuffed2 then
                        return true
                    else
                        return false
                    end
                end
            end
        },
        {
            icon = "fa-solid fa-car-rear",
            label = "Put in the vehicle",
            action = function(entity)
                local playerPed = PlayerPedId()
                local target = Player(GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity))).state.klamer_PlayerIsDragged
                local playerState = Player(GetPlayerServerId(NetworkGetPlayerIndexFromPed(PlayerPedId()))).state.klamer_PlayerDraggingSomeone
                local cuffed = Player(GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity))).state.klamer_PlayerIsCuffed
                local isDead = Player(GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity))).state.klamer_isDead

                if (cuffed or isDead) and not target and not playerState then
                    local vehicle, distance = ESX.Game.GetClosestVehicle(GetEntityCoords(PlayerPedId()))

                    if GetVehicleDoorLockStatus(vehicle) == 4 then
                        klamer_notify("This vehicle is closed!")
                        return
                    end

                    if not DoesEntityExist(vehicle) then
                        klamer_notify("There is no vehicle")
                        return
                    end

                    if distance > 6.0 then
                        klamer_notify("The vehicle is too far away")
                        return
                    end

                    if not AreAnyVehicleSeatsFree(vehicle) then
                        klamer_notify("There is no room in this vehicle")
                        return
                    end

                    local seats = GetVehicleModelNumberOfSeats(GetEntityModel(vehicle)) -- 4 sedan// 2 normalnie
                    
                    if seats == 4 then
                        for i = 1,2 do
                            if IsVehicleSeatFree(vehicle,i) then
                                TriggerServerEvent("klamer_handcuffs:setPedIntoVehicle",GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity)),tostring(vehicle),i)
                                return
                            end
                        end
                    else
                        if IsVehicleSeatFree(vehicle,0) then
                            TriggerServerEvent("klamer_handcuffs:setPedIntoVehicle",GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity)),tostring(vehicle),0)
                            return
                        end
                    end
                else
                    klamer_notify("You cannot put a player in a vehicle")
                end
            end,
            canInteract = function(entity)
                if IsPedAPlayer(entity) then
                    local target = Player(GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity))).state.klamer_PlayerIsDragged
                    local playerState = Player(GetPlayerServerId(NetworkGetPlayerIndexFromPed(PlayerPedId()))).state.klamer_PlayerDraggingSomeone
                    local cuffed = Player(GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity))).state.klamer_PlayerIsCuffed
                    if not target and not playerState and cuffed then
                        return true
                    else
                        return false
                    end
                end
            end
        },
    },
    distance = 4.0
})


exports['qtarget']:Vehicle({
    options = {
        {
            icon = "fa-solid fa-car-rear",
            label = "get the player out of the car",
            action = function(vehicle)
                local getPed = 0
                if (GetVehicleDoorLockStatus(vehicle) == 4) then
                    return
                end
                local seats = GetVehicleModelNumberOfSeats(GetEntityModel(vehicle)) -- 4 sedan// 2 normalnie
                for i = -1,seats do
                    local ped = GetPedInVehicleSeat(vehicle,i)
                    if ped ~= 0 then
                        if IsPedAPlayer(ped) then
                            local target = Player(GetPlayerServerId(NetworkGetPlayerIndexFromPed(ped))).state.klamer_PlayerIsCuffed
                            if target then
                                TriggerServerEvent("klamer_handcuffs:getPedFromVehicle", GetPlayerServerId(NetworkGetPlayerIndexFromPed(ped)))
                                return
                            end
                        end
                    end
                end
            end,
            canInteract = function(vehicle)
                if DoesEntityExist(vehicle) then
                    if (GetVehicleDoorLockStatus(vehicle) == 4) then
                        return false
                    end
                    local seats = GetVehicleModelNumberOfSeats(GetEntityModel(vehicle)) -- 4 sedan// 2 normalnie
                    for i = -1,seats do
                        local ped = GetPedInVehicleSeat(vehicle,i)
                        if ped ~= 0 then
                            if IsPedAPlayer(ped) then
                                local target = Player(GetPlayerServerId(NetworkGetPlayerIndexFromPed(ped))).state.klamer_PlayerIsCuffed
                                if target then
                                    return true
                                end
                            end
                        end
                    end
                    return false
                end
            end
        }
    }
})

local function loadAnimationDictonary(dictname)
	if not HasAnimDictLoaded(dictname) then
		RequestAnimDict(dictname) 
		while not HasAnimDictLoaded(dictname) do 
			Citizen.Wait(1)
		end
	end
end
local zakajdankowany = false

RegisterNetEvent("klamer_handcuffs:cuffMe", function(playerheading, playercoords, playerlocation, rope)
    local playerPed = PlayerPedId()

    if playerheading then
        local x,y,z = table.unpack(playercoords + playerlocation * 1.0)
        SetEntityCoords(playerPed, x, y, z)
        SetEntityHeading(playerPed, playerheading)
        Citizen.Wait(250)
        loadAnimationDictonary('mp_arrest_paired')
        TaskPlayAnim(playerPed, 'mp_arrest_paired', 'crook_p2_back_right', 8.0, -8, 3750 , 2, 0, 0, 0, 0)
        Citizen.Wait(3360)
        loadAnimationDictonary('mp_arresting')
        TaskPlayAnim(playerPed, 'mp_arresting', 'idle', 8.0, -8, -1, 49, 0.0, false, false, false)

        loadAnimationDictonary('mp_arresting')

        if not IsEntityPlayingAnim(playerPed, 'mp_arresting', 'idle', 3) then
            TaskPlayAnim(playerPed, 'mp_arresting', 'idle', 8.0, 1.0, -1, 49, 0.0, 0, 0, 0)
        end
        
        ESX.UI.Menu.CloseAll()

        SetCurrentPedWeapon(playerPed, 'WEAPON_UNARMED', true)
        DisablePlayerFiring(playerPed, true)
        SetEnableHandcuffs(playerPed, true)
        SetPedCanPlayGestureAnims(playerPed, false)
        zakajdankowany = true
        main_loop_handcuffs()
    else
        loadAnimationDictonary('mp_arresting')
        if not IsEntityPlayingAnim(playerPed, 'mp_arresting', 'idle', 3) then
            TaskPlayAnim(playerPed, 'mp_arresting', 'idle', 8.0, 1.0, -1, 49, 0.0, 0, 0, 0)
        end
        ESX.UI.Menu.CloseAll()
        SetCurrentPedWeapon(playerPed, 'WEAPON_UNARMED', true)
        DisablePlayerFiring(playerPed, true)
        SetEnableHandcuffs(playerPed, true)
        zakajdankowany = true
        main_loop_handcuffs()
        SetPedCanPlayGestureAnims(playerPed, false)
    end
    if rope then
        timer = 900
    end
end)





RegisterNetEvent("klamer_handcuffs:cuffHim", function(fastCuff)
    local playerPed = PlayerPedId()

    if fastCuff then
        Wait(250)
        loadAnimationDictonary('mp_arrest_paired')
	    TaskPlayAnim(playerPed, 'mp_arrest_paired', 'cop_p2_back_right', 8.0, -8,3750, 2, 0, 0, 0, 0)
    else
        local animationDictonary = "mp_arresting"
        local animationString = "a_uncuff"
        if (DoesEntityExist(playerPed) and not IsEntityDead(playerPed)) then
            loadAnimationDictonary(animationDictonary)
            if (IsEntityPlayingAnim(playerPed, animationDictonary, animationString, 8)) then
                TaskPlayAnim(playerPed, animationDictonary, "exit", 8.0, 3.0, 2000, 26, 1, 0, 0, 0)
            else
                TaskPlayAnim(playerPed, animationDictonary, animationString, 8.0, 3.0, 2000, 26, 1, 0, 0, 0)
            end
        end
    end
end)

RegisterNetEvent("klamer_handcuffs:uncuffMe", function(playerheading, playercoords, playerlocation)
    local playerPed = PlayerPedId()
    if not playerheading then
        ClearPedTasks(playerPed)
        ClearPedTasksImmediately(playerPed)
        SetEnableHandcuffs(playerPed, false)
        DisablePlayerFiring(playerPed, false)
        SetPedCanPlayGestureAnims(playerPed, true)
        FreezeEntityPosition(playerPed, false)
        timer = 0
        zakajdankowany = false
    else
        local x,y,z = table.unpack(playercoords + playerlocation * 1.0)
        SetEntityCoords(playerPed, x, y, z)
        SetEntityHeading(playerPed, playerheading)
        loadAnimationDictonary('mp_arresting')
        Citizen.Wait(250)
        TaskPlayAnim(playerPed, 'mp_arresting', 'b_uncuff', 8.0, -8,-1, 2, 0, 0, 0, 0)
        Citizen.Wait(2500)
        ClearPedTasks(playerPed)
        ClearPedTasksImmediately(playerPed)
        SetEnableHandcuffs(playerPed, false)
        DisablePlayerFiring(playerPed, false)
        SetPedCanPlayGestureAnims(playerPed, true)
        FreezeEntityPosition(playerPed, false)
        timer = 0
        zakajdankowany = false
    end
end)

RegisterNetEvent("klamer_handcuffs:uncuffMeAfterRevive", function()
    local playerPed = PlayerPedId()
    ClearPedTasks(playerPed)
    ClearPedTasksImmediately(playerPed)
    SetEnableHandcuffs(playerPed, false)
    DisablePlayerFiring(playerPed, false)
    SetPedCanPlayGestureAnims(playerPed, true)
    FreezeEntityPosition(playerPed, false)
    TriggerServerEvent("klamer_handcuffs:uncuffed")
end)

RegisterNetEvent("klamer_handcuffs:uncuffHim", function()
    local ped = PlayerPedId()
    loadAnimationDictonary('mp_arresting')
    Wait(250)
	TaskPlayAnim(ped, 'mp_arresting', 'a_uncuff', 8.0, -8,-1, 2, 0, 0, 0, 0)
	Wait(2500)
	ClearPedTasks(ped)
end)

RegisterNetEvent("klamer_handcuffs:dragMe", function(cop)
    local playerPed = PlayerPedId()
    FreezeEntityPosition(playerPed, true)
    AttachEntityToEntity(playerPed, GetPlayerPed(GetPlayerFromServerId(cop)), 11816, 0.54, 0.54, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
end)

RegisterNetEvent("klamer_handcuffs:unDrag", function()
    local playerPed = PlayerPedId()
    DetachEntity(playerPed, true, false)
    FreezeEntityPosition(playerPed, false)
end)

RegisterNetEvent("klamer_handcuffs:setMeInVehicle", function(vehicle,seatIndex)
    local ped = PlayerPedId()
    local vehicle, distance = ESX.Game.GetClosestVehicle(GetEntityCoords(ped))
    if not DoesEntityExist(tonumber(vehicle)) then
        return
    end
    if distance > 10.0 then
        return
    end
    setInVehicle = true
    ClearPedTasksImmediately(ped)
    ClearPedTasksImmediately(ped)
    ClearPedTasksImmediately(ped)
    Wait(150)
    TaskEnterVehicle(ped,tonumber(vehicle),0,seatIndex,100,16,0)
    TaskWarpPedIntoVehicle(ped,tonumber(vehicle),seatIndex)
    Wait(500)
    setInVehicle = false
end)

RegisterNetEvent("klamer_handcuffs:leaveVehicle", function()
    local playerPed = PlayerPedId()
    if IsPedSittingInAnyVehicle(playerPed) then
        local vehicle = GetVehiclePedIsIn(playerPed, false)
        TaskLeaveVehicle(playerPed, vehicle, 16)
        ClearPedTasksImmediately(playerPed)
    end
end)

RegisterNetEvent("klamer_handcuffs:getInventory", function(target)
    exports["ox_inventory"]:openInventory("player", target)
end)

AddEventHandler("klamer_handcuffs:closeInventoryHook", function()
    local source = GetPlayerServerId(NetworkGetPlayerIndexFromPed(PlayerPedId()))
    if not Player(source).state.klamer_IsPlayerSearchingInventory then
        return
    end
    if Player(source).state.klamer_IsPlayerSearchingInventory ~= 0 then
        TriggerServerEvent("klamer_handcuffs:closeInventory")
    end
end)

RegisterNetEvent('klamer_notify_handcuff',function(text)
    klamer_notify(text)
end)




function move_3D_text_loop()
    while text_loop do
        Citizen.Wait(0)
        drawTxt("Press [E] to release the person",0.50,0.80,0.4,255,255,255,180)
        if IsControlJustPressed(0,38) then
            local attachedPed, dist = ESX.Game.GetClosestPlayer(GetEntityCoords(PlayerPedId()))
            attachedPed = GetPlayerPed(attachedPed)
            if attachedPed ~= 0 then
                DetachEntity(attachedPed, true, true)
                TriggerServerEvent("klamer_handcuffs:unDragPlayer", GetPlayerServerId(NetworkGetPlayerIndexFromPed(attachedPed)))
                text_loop=false
                break
            else
                TriggerServerEvent("klamer_handcuffs:unDragPlayer")
                text_loop=false
                break
            end
        end
    end
end

function main_loop_handcuffs()
    while zakajdankowany do
        if Config.disable_vehicle then
            DisableControlAction(0,23,true)
            DisableControlAction(0,75,true)
        end
        DisableControlAction(0,24,true)
        DisableControlAction(0,140,true)
        DisableControlAction(0,25,true)
        if not IsEntityPlayingAnim(PlayerPedId(), "mp_arresting", "idle", 3) and not setInVehicle then
            TaskPlayAnim(PlayerPedId(), 'mp_arresting', 'idle', 8.0, -8, -1, 49, 0.0, false, false, false)
        end
        if LocalPlayer.state.klamer_PlayerIsCuffed then
        else
            zakajdankowany = false
            break
        end
        Citizen.Wait(0)
    end
end
AddEventHandler("zakajdankuj", function(entity)
    local playerPed = PlayerPedId()
    local entity = entity.entity
    local isDead = Player(GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity))).state.klamer_isDead
    if (IsEntityPlayingAnim(entity, "random@mugging3", "handsup_standing_base", 3) or isDead) then
        local playerheading = GetEntityHeading(playerPed)
        local playerlocation = GetEntityForwardVector(playerPed)
        local coords = GetEntityCoords(playerPed)
        TriggerServerEvent("klamer_handcuffs:cuffPlayer", GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity)), playerheading, coords, playerlocation)
    else
        klamer_notify('The person must raise their hands!')
    end
end)