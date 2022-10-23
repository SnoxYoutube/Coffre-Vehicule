ESX = nil
TriggerEvent(Config.ESX..'esx:getSharedObject', function(obj) ESX = obj end)
VehCoffre = {}
local OwnerVeh = {}
CoffreLoad = false 
CoffreLoadNumber = 0
CreateThread(function()
    MySQL.Async.fetchAll("SELECT * FROM coffre_veh", {}, function(result)
        for k, v in pairs(result) do 
            CoffreLoadNumber = CoffreLoadNumber +1
            local InfoVeh = json.decode(v.info)
            if not VehCoffre[InfoVeh.plate] then 
                VehCoffre[InfoVeh.plate] = {}
                VehCoffre[InfoVeh.plate].id = v.id
                VehCoffre[InfoVeh.plate].infos = InfoVeh
                v.data = json.decode(v.data)
                if v.data ~= nil then 
                    if v.data["items"] ~= nil then 
                        VehCoffre[InfoVeh.plate].data = v.data 
                    else
                        VehCoffre[InfoVeh.plate].data = v.data 
                        VehCoffre[InfoVeh.plate].data["weapons"] = {}
                    end
                else
                    VehCoffre[InfoVeh.plate].data = {
                        ["weapons"] = {},
                        ["items"] = {},
                        ['accounts'] = {
                            cash = 0,
                            dirtycash = 0
                        },
                    }
                end
            end
        end
        CoffreLoad = true 
        print("Ajout de "..CoffreLoadNumber.." coffre de véhicule dans le cache du serveur", "Coffre Véhicule")
    end)   

    MySQL.Async.fetchAll("SELECT * FROM owned_vehicles", {}, function(result)
        for k, v in pairs(result) do 
            if not OwnerVeh[v.plate] then 
                OwnerVeh[v.plate] = {}
                OwnerVeh[v.plate].plate = v.plate 
                OwnerVeh[v.plate].owner = v.owner 
            end
        end
    end)
end)

RegisterNetEvent("snox:recievecoffrevehserverside")
AddEventHandler("snox:recievecoffrevehserverside", function(plate)
    if VehCoffre[plate] then 
        TriggerClientEvent("snox:recievecoffrevehclientside", source, VehCoffre[plate] )
    else
        return
    end
end)

CreateThread(function()
    while not CoffreLoad do 
        Wait(1)
    end
    local CunterSave = 0
    while true do 
        for k, v in pairs(VehCoffre) do 
            MySQL.Sync.execute("UPDATE coffre_veh set info = @info, data = @data WHERE id = @id", {
                ["@id"] = v.id,
                ["@info"] = json.encode(v.infos),
                ["@data"] = json.encode(v.data)
            })
        end
        CunterSave = CunterSave + 1
        Wait(10*60000)
        print("[^4"..CunterSave.."^0] Save de coffre de véhicule effecutée !", "^2Coffre Save^0")
    end
end)

RegisterCommand("savecoffreveh", function(source)
    if source == 0 then 
        for k, v in pairs(VehCoffre) do 
            MySQL.Sync.execute("UPDATE coffre_veh set info = @info, data = @data WHERE id = @id", {
                ["@id"] = v.id,
                ["@info"] = json.encode(v.infos),
                ["@data"] = json.encode(v.data)
            })
        end
        print("LES COFFRES DES VEHICULES ONT ETE SAVE CORRECTEMENT !")
    else
        return
    end
end)

CreateVehToBdd = function(plate, class)
    local xPlayer = ESX.GetPlayerFromId(source)
    local NewId = math.random(0, 999999)
    local Infos = {
        plate = plate,
        maxweight = WeightWeh[class],
        weight = 0
    }
    VehCoffre[plate] = {}
    VehCoffre[plate].plate = plate 
    VehCoffre[plate].id = NewId 
    VehCoffre[plate].infos = Infos 
    VehCoffre[plate].data = {
        ["weapons"] = {},
        ["items"] = {},
        ['accounts'] = {
            cash = 0,
            dirtycash = 0
        },
    }
    MySQL.Async.execute("INSERT INTO coffre_veh (info, id) VALUES (@info, @id)", {
        ["@info"] = json.encode(Infos),
        ["@id"] = NewId
    })
    return true 
end



RegisterNetEvent("snox:actionsitemveh", function(plate, class, action, count, name)
    local xPlayer = ESX.GetPlayerFromId(source)
    local VerifExistPlate = VehCoffre[plate] ~= nil and true or false 
    local VehNoOwner = OwnerVeh[plate] ~= nil and true or false 
    if VehNoOwner then 
        if xPlayer.identifier == OwnerVeh[plate].owner then 
            OwnerofVeh = true 
        else
            OwnerofVeh = false 
        end
    end

    local InfoItem = xPlayer.getInventoryItem(name)
    if action == "deposit" then 
        if OwnerofVeh == false then 
            xPlayer.showNotification("Vous ne pouvez pas déposer d'item dans le coffre de ce véhicule")
            return
        end
        if InfoItem.count >= tonumber(count) then 
            if not VerifExistPlate then 
                local CreateVeh = CreateVehToBdd(plate, class)
                if CreateVeh then 
                    local VerifWeigt = tonumber(VehCoffre[plate].infos.weight) + tonumber(InfoItem.weight*count) <= VehCoffre[plate].infos.maxweight and true or false 
                    if VerifWeigt then 
                        VehCoffre[plate].data["items"][InfoItem.name] = {}
                        VehCoffre[plate].data["items"][InfoItem.name].name = InfoItem.name 
                        VehCoffre[plate].data["items"][InfoItem.name].label = InfoItem.label 
                        VehCoffre[plate].data["items"][InfoItem.name].weight = tonumber(InfoItem.weight*count)
                        VehCoffre[plate].data["items"][InfoItem.name].count = tonumber(count)
                        VehCoffre[plate].infos.weight = tonumber(VehCoffre[plate].infos.weight) + tonumber(InfoItem.weight*count)
                        xPlayer.removeInventoryItem(name, count)
                        xPlayer.showNotification("Vous venez de déposé ~b~x"..count.." "..InfoItem.label.."~s~ dans le coffre du véhicule")
                        TriggerClientEvent("snox:recievecoffrevehclientside", source, VehCoffre[plate])
                    else
                        xPlayer.showNotification("Le coffre ne dispose pas d'asser de place pour déposer autant de ~b~"..InfoItem.label)
                    end
                end
            else
                local VerifWeigt = tonumber(VehCoffre[plate].infos.weight) + tonumber(InfoItem.weight*count) <= VehCoffre[plate].infos.maxweight and true or false 
                if VerifWeigt then 
                    if VehCoffre[plate].data["items"][InfoItem.name] then 
                        VehCoffre[plate].data["items"][InfoItem.name].weight = VehCoffre[plate].data["items"][InfoItem.name].weight + tonumber(InfoItem.weight*count)
                        VehCoffre[plate].data["items"][InfoItem.name].count = VehCoffre[plate].data["items"][InfoItem.name].count + tonumber(count)
                        VehCoffre[plate].infos.weight = tonumber(VehCoffre[plate].infos.weight) + tonumber(InfoItem.weight*count)
                    else
                        VehCoffre[plate].data["items"][InfoItem.name] = {}
                        VehCoffre[plate].data["items"][InfoItem.name].name = InfoItem.name 
                        VehCoffre[plate].data["items"][InfoItem.name].label = InfoItem.label 
                        VehCoffre[plate].data["items"][InfoItem.name].weight = tonumber(InfoItem.weight*count)
                        VehCoffre[plate].data["items"][InfoItem.name].count = tonumber(count)
                        VehCoffre[plate].infos.weight = tonumber(VehCoffre[plate].infos.weight) + tonumber(InfoItem.weight*count)
                        xPlayer.showNotification("Vous venez de déposé ~b~x"..count.." "..InfoItem.label.."~s~ dans le coffre du véhicule")
                    end
                    xPlayer.removeInventoryItem(name, count)
                    xPlayer.showNotification("Vous venez de déposé ~b~x"..count.." "..InfoItem.label.."~s~ dans le coffre du véhicule")
                    TriggerClientEvent("snox:recievecoffrevehclientside", source, VehCoffre[plate])
                else
                    xPlayer.showNotification("Le coffre ne dispose pas d'asser de place pour déposer autant de ~b~"..InfoItem.label)
                end
            end
        else
            DropPlayer(source, "Tentative de Cheat" )
        end
    elseif action == "remove" then 
        if OwnerofVeh == false then 
            xPlayer.showNotification("Vous ne pouvez pas retirer d'item dans le coffre de ce véhicule")
            return
        end
        if xPlayer.canCarryItem(InfoItem.name, count) then 
            if VehCoffre[plate].data["items"][InfoItem.name] ~= nil then 
                if VehCoffre[plate].data["items"][InfoItem.name].count >= tonumber(count) then 
                    VehCoffre[plate].data["items"][InfoItem.name].count = VehCoffre[plate].data["items"][InfoItem.name].count - tonumber(count)
                    VehCoffre[plate].data["items"][InfoItem.name].weight = VehCoffre[plate].data["items"][InfoItem.name].weight - tonumber(InfoItem.weight*count)
                    VehCoffre[plate].infos.weight = tonumber(VehCoffre[plate].infos.weight) - tonumber(InfoItem.weight*count)
                    xPlayer.showNotification("Vous venez de retiré ~g~x"..count.." "..InfoItem.label.."~s~ du coffre du véhicule")
                    xPlayer.addInventoryItem(InfoItem.name, count)
                  
                    if VehCoffre[plate].data["items"][InfoItem.name].count == 0 then 
                        VehCoffre[plate].data["items"][InfoItem.name] = nil 
                    end
                    TriggerClientEvent("snox:recievecoffrevehclientside", source, VehCoffre[plate])
                else
                    DropPlayer(source, "Tentative de Cheat" )
                end
            else
                DropPlayer(source, "Tentative de Cheat" )
            end
        else
            xPlayer.showNotification("Vous êtes trop lourd !")
        end
    end
end)

RegisterNetEvent("snox:actionsweaponsveh", function(plate, class, action, name, ammo, label, id)
    local xPlayer = ESX.GetPlayerFromId(source)
    local VerifExistPlate = VehCoffre[plate] ~= nil and true or false 
    local VehNoOwner = OwnerVeh[plate] ~= nil and true or false 
    if VehNoOwner then 
        if xPlayer.identifier == OwnerVeh[plate].owner then 
            OwnerofVeh = true 
        else
            OwnerofVeh = false 
        end
    end
    local InfoWeapon = xPlayer.getWeapon(name)
    if action == "deposit" then 
        if OwnerofVeh == false then 
            xPlayer.showNotification("Vous ne pouvez pas déposer d'item dans le coffre de ce véhicule")
            return
        end
        if InfoWeapon > 0 then 
            if not VerifExistPlate then 
                local CreateVeh = CreateVehToBdd(plate, class)
                if CreateVeh then 
                    if WeaponWeight[name] == nil then 
                        xPlayer.showNotification("Vous ne pouvez pas déposer cette arme dans le coffre de ce véhicule")
                        return;
                    end
                    local VerifWeigt = tonumber(VehCoffre[plate].infos.weight) + tonumber(WeaponWeight[name]) <= VehCoffre[plate].infos.maxweight and true or false 
                    if VerifWeigt then 
                        if not VehCoffre[plate].data["weapons"][name] then 
                            VehCoffre[plate].data["weapons"][name] = {}
                            VehCoffre[plate].data["weapons"][name].name = name 
                            VehCoffre[plate].data["weapons"][name].ammo = ammo 
                            VehCoffre[plate].data["weapons"][name].label = label 
                            VehCoffre[plate].data["weapons"][name].weight = tonumber(WeaponWeight[name])
                            VehCoffre[plate].data["weapons"][name].count = 1
                            VehCoffre[plate].infos.weight = tonumber(VehCoffre[plate].infos.weight) + tonumber(WeaponWeight[name])
                        end
                        xPlayer.removeWeapon(name)
                        xPlayer.showNotification("Vous venez de déposé ~b~x1 "..label.."~s~ dans le coffre du véhicule")
                        TriggerClientEvent("snox:recievecoffrevehclientside", source, VehCoffre[plate])
                    else
                        xPlayer.showNotification("Le coffre ne dispose pas d'asser de place pour déposer autant de ~b~"..label)
                    end
                end
            else
                if WeaponWeight[name] == nil then 
                    xPlayer.showNotification("Vous ne pouvez pas déposer cette arme dans le coffre de ce véhicule")
                    return;
                end
                local VerifWeigt = tonumber(VehCoffre[plate].infos.weight) + tonumber(WeaponWeight[name]) <= VehCoffre[plate].infos.maxweight and true or false 
                if VerifWeigt then 
                    if VehCoffre[plate].data["weapons"][name] then 
                        VehCoffre[plate].data["weapons"][name].weight =  VehCoffre[plate].data["weapons"][name].weight+ tonumber(WeaponWeight[name]) 
                        VehCoffre[plate].data["weapons"][name].count = VehCoffre[plate].data["weapons"][name].count + 1
                        VehCoffre[plate].infos.weight = tonumber(VehCoffre[plate].infos.weight) + tonumber(WeaponWeight[name])
                    else
                        VehCoffre[plate].data["weapons"][name] = {}
                        VehCoffre[plate].data["weapons"][name].name = name 
                        VehCoffre[plate].data["weapons"][name].ammo = ammo 
                        VehCoffre[plate].data["weapons"][name].label = label 
                        VehCoffre[plate].data["weapons"][name].weight = tonumber(WeaponWeight[name])
                        VehCoffre[plate].data["weapons"][name].count = 1
                        VehCoffre[plate].infos.weight = tonumber(VehCoffre[plate].infos.weight) + tonumber(WeaponWeight[name])
                    end
                    xPlayer.removeWeapon(name)
                    xPlayer.showNotification("Vous venez de déposé ~b~x1 "..label.."~s~ dans le coffre du véhicule")
                    TriggerClientEvent("snox:recievecoffrevehclientside", source, VehCoffre[plate])
                else
                    xPlayer.showNotification("Le coffre ne dispose pas d'asser de place pour déposer autant de ~b~"..label)
                end
            end
        else
            DropPlayer(source, "Tentative de Cheat" )
        end
    elseif action == "remove" then 
        if OwnerofVeh == false then 
            xPlayer.showNotification("Vous ne pouvez pas retirer d'item dans le coffre de ce véhicule")
            return
        end
        if VehCoffre[plate].data["weapons"][name] ~= nil then  
            if VehCoffre[plate].data["weapons"][name].count >= tonumber(ammo) then 
                VehCoffre[plate].data["weapons"][name].count = VehCoffre[plate].data["weapons"][name].count - tonumber(ammo)
                VehCoffre[plate].data["weapons"][name].weight = VehCoffre[plate].data["weapons"][name].weight - tonumber(WeaponWeight[name]*ammo)
                VehCoffre[plate].infos.weight = tonumber(VehCoffre[plate].infos.weight) - tonumber(WeaponWeight[name]*ammo)
                xPlayer.addWeapon(name, VehCoffre[plate].data["weapons"][name].ammo)
                xPlayer.showNotification("Vous venez de retiré ~g~x"..tostring(ammo).." "..label.."~s~ du coffre du véhicule")
                if VehCoffre[plate].data["weapons"][name].count == 0 then 
                    VehCoffre[plate].data["weapons"][name] = nil 
                end
                TriggerClientEvent("snox:recievecoffrevehclientside", source, VehCoffre[plate])
            else
                DropPlayer(source, "Tentative de Cheat" )
            end
        else
            DropPlayer(source, "Tentative de Cheat" )
        end
       
    end
end)


RegisterNetEvent("snox:actionsargentveh", function(plate, class, action, count, typee)
    local xPlayer = ESX.GetPlayerFromId(source)
    local VerifExistPlate = VehCoffre[plate] ~= nil and true or false 
    local VehNoOwner = OwnerVeh[plate] ~= nil and true or false 
    if VehNoOwner then 
        if xPlayer.identifier == OwnerVeh[plate].owner then 
            OwnerofVeh = true 
        else
            OwnerofVeh = false 
        end
    end
    if action == "deposit" then 
        if OwnerofVeh == false then 
            xPlayer.showNotification("Vous ne pouvez pas déposer d'item dans le coffre de ce véhicule")
            return
        end
        if xPlayer.getAccount(typee).money >= tonumber(count) then 
            if not VerifExistPlate then 
                local CreateVeh = CreateVehToBdd(plate, class)
                if CreateVeh then 
                    if VehCoffre[plate].data["accounts"][typee] then 
                        VehCoffre[plate].data["accounts"][typee] = VehCoffre[plate].data["accounts"][typee] + tonumber(count)
                    end
                    xPlayer.removeAccountMoney(typee, count)
                    xPlayer.showNotification("Vous venez de déposé ~b~ "..count.." $~s~ dans le coffre du véhicule")
                    TriggerClientEvent("snox:recievecoffrevehclientside", source, VehCoffre[plate])
                end
            else
                if VehCoffre[plate].data["accounts"][typee] then 
                    VehCoffre[plate].data["accounts"][typee] = VehCoffre[plate].data["accounts"][typee] + tonumber(count)
                end
                xPlayer.removeAccountMoney(typee, count)
                xPlayer.showNotification("Vous venez de déposé ~b~ "..count.." $~s~ dans le coffre du véhicule")
                TriggerClientEvent("snox:recievecoffrevehclientside", source, VehCoffre[plate])    
            end
        else
            xPlayer.showNotification("Vous n'avez pas les fonds nécéssaire pour faire cela")
        end
    elseif action == "remove" then 
        if OwnerofVeh == false then 
            xPlayer.showNotification("Vous ne pouvez pas retirer d'item dans le coffre de ce véhicule")
            return
        end
        if VehCoffre[plate].data["accounts"][typee] >= tonumber(count) then 
            VehCoffre[plate].data["accounts"][typee] = VehCoffre[plate].data["accounts"][typee] - tonumber(count)
            if VehCoffre[plate].data["accounts"][typee] == 0 then 
                VehCoffre[plate].data["accounts"][typee] = 0
            end
            xPlayer.addAccountMoney(typee, count)
            xPlayer.showNotification("Vous venez de retiré ~b~"..count.." $~s~ dans le coffre du véhicule")
            TriggerClientEvent("snox:recievecoffrevehclientside", source, VehCoffre[plate])    
        else
            DropPlayer(source, "Tentative de Cheat" )
        end
       
    end
end)