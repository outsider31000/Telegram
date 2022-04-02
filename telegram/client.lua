---------------------------------------------------------------------------------------------------
---------------------------------- CLIENT ---------------------------------------------------------
-- EDIT BY OUTSIDER
-- AUTHOR ?? scf telegram ??

local telegrams = {}
local index = 1
local menu = false
local prompts = GetRandomIntInRange(0, 0xffffff)


local locations = Config.Locations --GET LOCATION

--PROPMT
Citizen.CreateThread(function()
    Citizen.Wait(5000)
    local str = Config.Press
	openTelegram = PromptRegisterBegin()
	PromptSetControlAction(openTelegram,  Config.keys.G) 
	str = CreateVarString(10, 'LITERAL_STRING', str)
	PromptSetText(openTelegram, str)
	PromptSetEnabled(openTelegram, 1)
	PromptSetVisible(openTelegram, 1)
	PromptSetStandardMode(openTelegram,1)
    PromptSetHoldMode(openTelegram, 1)
	PromptSetGroup(openTelegram, prompts)
	Citizen.InvokeNative(0xC5F428EE08FA7F2C,openTelegram,true)
	PromptRegisterEnd(openTelegram)
end)


RegisterNetEvent("Telegram:ReturnMessages")
AddEventHandler("Telegram:ReturnMessages", function(data)
    index = 1
    telegrams = data

    if next(telegrams) == nil then
        SetNuiFocus(true, true)
        SendNUIMessage({ message = "No telegrams to display." })
    else
        SetNuiFocus(true, true)
        SendNUIMessage({ sender = telegrams[index].sender, message = telegrams[index].message })
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)

        for key, value in pairs(locations) do
           if IsPlayerNearCoords(value.x, value.y, value.z) then
                if not menu then
                   
                    local label  = CreateVarString(10, 'LITERAL_STRING', Config.Post) -- TRANSLATE HERE
                    PromptSetActiveGroupThisFrame(prompts, label)

                    if Citizen.InvokeNative(0xC92AC953F0A982AE,openTelegram) then
                   
                        menu = true
                        TriggerServerEvent("Telegram:GetMessages")
                    end
                end
            end
        end
    end
end)

function IsPlayerNearCoords(x, y, z)
    local playerx, playery, playerz = table.unpack(GetEntityCoords(PlayerPedId(), 0))
    local distance = Vdist2(playerx, playery, playerz, x, y, z, true) -- USE VDIST

    if distance < 1 then
        return true
    end
end


function CloseTelegram()
    index = 1
    menu = false
    SetNuiFocus(false, false)
    SendNUIMessage({})
end

RegisterNUICallback('back', function()
    if index > 1 then
        index = index - 1
        SendNUIMessage(
            { 
                sender = telegrams[index].sender, 
                message = telegrams[index].message 
            }
        )
    end
end)

RegisterNUICallback('next', function()
    if index < #telegrams then
        index = index + 1
        SendNUIMessage(
            { 
                sender = telegrams[index].sender,
                message = telegrams[index].message 
            }
        )
    end
end)

RegisterNUICallback('close', function() --CLOSE NUI
    CloseTelegram()
end)

RegisterNUICallback('new', function() -- NEW TELEGRAM
    CloseTelegram()
    GetFirstname()
end)

RegisterNUICallback('delete', function() -- DELETE TELEGRAM
    TriggerServerEvent("Telegram:DeleteMessage", telegrams[index].id)
end)

function GetFirstname()
    AddTextEntry("FMMC_KEY_TIP8", Config.firstname) -- INPUT
    DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP8", "", "", "", "", "", 30)

    while (UpdateOnscreenKeyboard() == 0) do
        Wait(0);
    end

    while (UpdateOnscreenKeyboard() == 2) do
        Wait(0);
        break
    end

    while (UpdateOnscreenKeyboard() == 1) do
        Wait(0)
        if (GetOnscreenKeyboardResult()) then
            local firstname = GetOnscreenKeyboardResult()

            GetLastname(firstname)

            break
        end
    end
end

function GetLastname(firstname) -- INPUT
    AddTextEntry("FMMC_KEY_TIP8", Config.Lastname)
    DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP8", "", "", "", "", "", 30)

    while (UpdateOnscreenKeyboard() == 0) do
        Wait(0);
    end

    while (UpdateOnscreenKeyboard() == 2) do
        Wait(0);
        break
    end

    while (UpdateOnscreenKeyboard() == 1) do
        Wait(0)
        if (GetOnscreenKeyboardResult()) then
            local lastname = GetOnscreenKeyboardResult()

            GetMessage(firstname, lastname)

            break
        end
    end
end

function GetMessage(firstname, lastname) --INPUT
  
    AddTextEntry("message", Config.message)
	DisplayOnscreenKeyboard(0, "message", "", "", "", "", "", 175)

    while (UpdateOnscreenKeyboard() == 0) do
        Wait(0);
    end

    while (UpdateOnscreenKeyboard() == 2) do
        Wait(0);
        break
    end

    while (UpdateOnscreenKeyboard() == 1) do
        Wait(0)
        if (GetOnscreenKeyboardResult()) then
            local message = GetOnscreenKeyboardResult()

            print(firstname, lastname, message)
            
            TriggerServerEvent("Telegram:SendMessage", firstname, lastname, message, GetPlayerServerIds())
           
            break
        end
    end
end

function GetPlayerServerIds()
    local players = {}
    for i = 0, 31 do
        if NetworkIsPlayerActive(i) then
            table.insert(players, GetPlayerServerId(i))
        end
    end

    return players
end


local blips = Config.blips --BLIPS

Citizen.CreateThread(function()
	for _, info in pairs(blips) do
        local blip = N_0x554d9d53f696d002(1664425300, info.x, info.y, info.z)
        SetBlipSprite(blip, info.sprite, 1)
		SetBlipScale(blip, 0.2)
		Citizen.InvokeNative(0x9CB1A1623062F402, blip, info.name)
    end  
end)



