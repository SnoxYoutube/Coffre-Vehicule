ESX = nil
Player = {}
Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent(Config.ESX..'esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end

    ESX.PlayerData = ESX.GetPlayerData()
	Player.WeaponData = ESX.GetWeaponList()

    while ESX.PlayerData == nil do 
		print("player data nil")
		Wait(1)
	end

    for i = 1, #Player.WeaponData, 1 do
		if Player.WeaponData[i].name == 'WEAPON_UNARMED' then
			Player.WeaponData[i] = nil
		else
			Player.WeaponData[i].hash = GetHashKey(Player.WeaponData[i].name)
		end
    end

end)


local function KeyboardInput(entryTitle, textEntry, inputText, maxLength)
    AddTextEntry(entryTitle, textEntry)
    DisplayOnscreenKeyboard(1, entryTitle, "", inputText, "", "", "", maxLength)

    while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
        Wait(0)
    end
    if UpdateOnscreenKeyboard() ~= 2 then
        local result = GetOnscreenKeyboardResult()
        Wait(500)
        return result
    else
        Wait(500)
        return nil
    end
end

local function CheckQuantity(number)
    number = tonumber(number)
    if type(number) == "number" then
        number = ESX.Math.Round(number)

        if number > 0 then
            return true, number
        end
    end
    return false, number
end

CoffreVeh = {
    Item = true, 
    Weapon = false, 
    Money = false,

    ItemR = true, 
    WeaponR = false, 
    MoneyR = false,
    IndexDeposit = 1,
    IndexRemove = 1
}

Data = {}

OpenCoffreVeh = function(CorrdVeh, plate, model, class)
    Data["items"] = nil 
    Data["weapons"] = nil 
    Data["accounts"] = nil
    local maincoffre = RageUI.CreateMenu("Coffre du véhicule", "Voici le coffre du véhicule")
    local depositincoffre = RageUI.CreateSubMenu(maincoffre, "Déposer", "Voici les actions disponibles")
    local retirerincoffre = RageUI.CreateSubMenu(maincoffre, "Retirer", "Voici les objets disponibles")
    TriggerServerEvent("snox:recievecoffrevehserverside", plate)
    RageUI.Visible(maincoffre, not RageUI.Visible(maincoffre))
    Info = {
        weight = nil
    }

    while maincoffre do 
        Wait(0)
        if #(GetEntityCoords(PlayerPedId()) - CorrdVeh) > 5 then 
            ESX.ShowNotification("~r~Information\n~s~Tu t'éloigne trop !")
            RageUI.CloseAll()
        end
        RageUI.IsVisible(maincoffre, function()
            RageUI.Button("> Déposer du stock", "Vous permet de déposer de la marchandise dans le coffre", {RightLabel = "→→→"}, true, {}, depositincoffre)
            RageUI.Button("> Accéder au stock", "Vous permet d'accéder au stock du véhicule", {RightLabel = "→→→"}, true, {}, retirerincoffre)
        end, function()
        end)

        RageUI.IsVisible(depositincoffre, function()
            ESX.PlayerData = ESX.GetPlayerData()

            if Info.weight ~= nil then 
                RageUI.Separator("Contenu du coffre: ~b~"..ESX.Math.Round(Info.weight, 1).."kg / "..Info.maxweight.."kg ")
            else
                RageUI.Separator("Contenu du coffre: ~b~ 0 kg / "..tostring(WeightWeh[class]).."kg ")
            end

            for i = 1, #ESX.PlayerData.accounts, 1 do
                if ESX.PlayerData.accounts[i].name == Config.Money.cash  then
                    RageUI.Separator('Argent cash: ~g~'..ESX.PlayerData.accounts[i].money.."$")
                end
            end
            for i = 1, #ESX.PlayerData.accounts, 1 do
                if ESX.PlayerData.accounts[i].name == Config.Money.argentsale  then
                    RageUI.Separator('Argent non déclaré: ~r~'..ESX.PlayerData.accounts[i].money.."$")
                end
            end


            RageUI.List("> Filtre", {"Items", "Armes", "Argent"}, CoffreVeh.IndexDeposit, nil, {}, true, {
                onListChange = function(index)
                    CoffreVeh.IndexDeposit = index
                    if index == 1 then 
                        CoffreVeh.Item, CoffreVeh.Weapon, CoffreVeh.Money = true, false, false 
                    elseif index == 2 then 
                        CoffreVeh.Item, CoffreVeh.Weapon, CoffreVeh.Money = false, true, false 
                    elseif index == 3 then 
                        CoffreVeh.Item, CoffreVeh.Weapon, CoffreVeh.Money = false, false, true 
                    end
                end
            })

            if CoffreVeh.Item then 
                RageUI.Separator("↓ Items ↓")
                for k, v in pairs(ESX.PlayerData.inventory) do 
                    if v.count > 0 then 
                        RageUI.Button("> "..v.label..' [x'..v.count.."]", nil, {RightLabel = "~g~Déposer"}, true, {
                            onSelected = function()
                                local check, count = CheckQuantity(KeyboardInput("Combien voulez vous deposer ?","Combien voulez vous deposer ?", "", 15))
                                if check then 
                                    if v.count >= count then 
                                        TriggerServerEvent("snox:actionsitemveh", plate, class, "deposit", count, v.name)
                                    else
                                        ESX.ShowNotification("Vous ne disposez pas d'assser de ~r~"..v.label.." ~s~pour faire cela")
                                    end
                                else
                                    ESX.ShowNotification("Veuillez entrez des chiffres")
                                end
                            end
                        })
                    end
                end
            end

            if CoffreVeh.Weapon then 
                if #Player.WeaponData > 0 then 
                    RageUI.Separator("↓ Armes ↓")
                    for i = 1, #Player.WeaponData, 1 do
                        if HasPedGotWeapon(PlayerPedId(), Player.WeaponData[i].hash, false) then
                            local ammo = GetAmmoInPedWeapon(PlayerPedId(), Player.WeaponData[i].hash)
                            RageUI.Button("> "..Player.WeaponData[i].label, nil, { RightLabel = "Munition(s) : ~r~x"..ammo }, true, {
                                onSelected = function()
                                    TriggerServerEvent("snox:actionsweaponsveh", plate, class, "deposit", Player.WeaponData[i].name, ammo, Player.WeaponData[i].label)
                                end
                            })
                        end
                    end
                else
                    RageUI.Separator("~r~Aucune Armes")
                end
            end

            if CoffreVeh.Money then 
                RageUI.Button("> Déposer de l'argent cash", nil, {RightLabel = "→→→"}, true, {
                    onSelected = function()
                        local check, count = CheckQuantity(KeyboardInput("Combien voulez vous deposer ?","Combien voulez vous deposer ?", "", 15))
                        if check then 
                            TriggerServerEvent("snox:actionsargentveh", plate, class, "deposit", count, Config.Money.cash)
                        else
                            ESX.ShowNotification("Veuillez entrez des chiffres")
                        end
                    end
                })

                RageUI.Button("> Déposer de l'argent sale", nil, {RightLabel = "→→→"}, true, {
                    onSelected = function()
                        local check, count = CheckQuantity(KeyboardInput("Combien voulez vous deposer ?","Combien voulez vous deposer ?", "", 15))
                        if check then 
                            TriggerServerEvent("snox:actionsargentveh", plate, class, "deposit", count, Config.Money.argentsale)
                        else
                            ESX.ShowNotification("Veuillez entrez des chiffres")
                        end
                    end
                })
            end

        end, function()
        end)

        RageUI.IsVisible(retirerincoffre, function()      

            if Info.weight ~= nil then 
                RageUI.Separator("Contenu du coffre: ~b~"..ESX.Math.Round(Info.weight, 1).."kg / "..Info.maxweight.."kg ")
            else 
                RageUI.Separator("Contenu du coffre: ~b~ 0 kg / "..tostring(WeightWeh[class]).."kg ")
            end 

            RageUI.List("> Filtre", {"Items", "Armes", "Argent"}, CoffreVeh.IndexRemove, nil, {}, true, {
                onListChange = function(index)
                    CoffreVeh.IndexRemove = index
                    if index == 1 then 
                        CoffreVeh.ItemR, CoffreVeh.WeaponR, CoffreVeh.MoneyR = true, false, false 
                    elseif index == 2 then 
                        CoffreVeh.ItemR, CoffreVeh.WeaponR, CoffreVeh.MoneyR = false, true, false 
                    elseif index == 3 then 
                        CoffreVeh.ItemR, CoffreVeh.WeaponR, CoffreVeh.MoneyR = false, false, true 
                    end
                end
            })  

            if CoffreVeh.ItemR then 
                if Data["items"] ~= nil then 
                    for k, v in pairs(Data["items"]) do 
                        RageUI.Button("> "..v.label.." [x"..v.count.."]", "Cet item pèse un total de  ~r~"..v.weight.." kg  ", {RightLabel = "~r~Retirer"}, true, {
                            onSelected = function()
                                local check, count = CheckQuantity(KeyboardInput("Combien voulez vous retirer ?","Combien voulez vous retirer ?", "", 15))
                                if check then 
                                    if v.count >= count then 
                                        TriggerServerEvent("snox:actionsitemveh", plate, Info.id, "remove", count, v.name)
                                    else
                                        ESX.ShowNotification("Vous ne disposez pas d'assser de ~r~"..v.label.." ~s~pour faire cela")
                                    end
                                else
                                    ESX.ShowNotification("Veuillez entrez des chiffres" )
                                end
                            end
                        })
                    end
                else
                    RageUI.Separator("↓ Aucun Items dans le coffre ↓")
                end
            end

            if CoffreVeh.WeaponR then 
                if Data["weapons"] ~= nil then 
                    for k, v in pairs(Data["weapons"]) do 
                        RageUI.Button("> "..v.label.." [x"..v.count.."]", "Cet item pèse un total de  ~r~"..v.weight.." kg  ", {RightLabel = "~r~Retirer"}, true, {
                            onSelected = function()
                                local check, count = CheckQuantity(KeyboardInput("Combien voulez vous retirer ?","Combien voulez vous retirer ?", "", 15))
                                if check then 
                                    if v.count >= count then 
                                        TriggerServerEvent("snox:actionsweaponsveh", plate, Info.id, "remove", v.name, count, v.label)
                                    else
                                        ESX.ShowNotification("Vous ne disposez pas d'assser de ~r~"..v.label.." ~s~pour faire cela")
                                    end
                                else
                                    ESX.ShowNotification("Veuillez entrez des chiffres")
                                end
                            end
                        })
                    end
                else
                    RageUI.Separator("↓ Aucunes armes dans le coffre ↓")
                end
            end

            if CoffreVeh.MoneyR then 
                if Data["accounts"] ~= nil  then 
                    RageUI.Button("> Argent propre: ~g~"..Data["accounts"].cash.." $", nil, {RightLabel = "→→→"}, true, {
                        onSelected = function()
                            local check, count = CheckQuantity(KeyboardInput("Combien voulez vous retirer ?","Combien voulez vous retirer ?", "", 15))
                            if check then 
                                if Data["accounts"].cash >= tonumber(count) then 
                                    TriggerServerEvent("snox:actionsargentveh", plate, Info.id, "remove", count, "cash")
                                else
                                    ESX.ShowNotification("Somme invalide")
                                end
                            else
                                ESX.ShowNotification("Veuillez entrez des chiffres")
                            end

                        end
                    })
                else
                    RageUI.Separator("↓ Aucun argent propre ↓")
                end

                if Data["accounts"] ~= nil then 
                    RageUI.Button("> Argent sale: ~r~"..Data["accounts"].dirtycash.." $", nil, {RightLabel = "→→→"}, true, {
                        onSelected = function()
                            local check, count = CheckQuantity(KeyboardInput("Combien voulez vous retirer ?","Combien voulez vous retirer ?", "", 15))
                            if check then 
                                if Data["accounts"].dirtycash >= tonumber(count) then 
                                    TriggerServerEvent("snox:actionsargentveh", plate, Info.id, "remove", count, "dirtycash")
                                else
                                    ESX.ShowNotification("Somme invalide")
                                end
                            else
                                ESX.ShowNotification("Veuillez entrez des chiffres")
                            end

                        end
                    })
                else
                    RageUI.Separator("↓ Aucun argent sale ↓")
                end

            end
        
        end, function()
        end)

        if not RageUI.Visible(maincoffre) and 
        not RageUI.Visible(depositincoffre) and 
        not RageUI.Visible(retirerincoffre) then 
            maincoffre = RMenu:DeleteType("maincoffre")
        end
    end
end

Keys.Register("L", "coffre", "Pour ouvrir le coffre de la voiture", function()
    if not IsPedSittingInAnyVehicle(PlayerPedId()) then 
        local coord = GetEntityCoords(PlayerPedId())
        local VehCloset, VehDist = ESX.Game.GetClosestVehicle(coord, false)
        local VehCoords = GetEntityCoords(VehCloset)
        local dist = GetDistanceBetweenCoords(PlayerPedId(), VehDist, true)
        if dist < 4 then 
            local locked = GetVehicleDoorLockStatus(VehCloset) 
            if locked == 1 then
                local class = GetVehicleClass(VehCloset)
                local plate = GetVehicleNumberPlateText(VehCloset)
                local model = GetEntityModel(VehCloset)
                OpenCoffreVeh(VehCoords, plate, model, class)
            else
                ESX.ShowNotification("Le véhicule est fermé")
            end
        else
            ESX.ShowNotification("Aucun véhicule aux alentours")
        end
    else
        ESX.ShowNotification("Vous ne pouvez pas faire cela dans un véhicule")
    end
end)


RegisterNetEvent("snox:recievecoffrevehclientside")
AddEventHandler("snox:recievecoffrevehclientside", function(data)
    Data = data.data
    Info = data.infos
end)


