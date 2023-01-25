local ESX, QBCore = nil, nil

if Scully.UseItem then
    if Scully.Framework == "esx" then
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        
        if Scully.UseItem then
            ESX.RegisterUsableItem('radio', function(source)
                TriggerClientEvent("scully_radio:openRadio", source)
            end)
        end

        ESX.RegisterServerCallback("scully_radio:itemCheck", function(source, cb)
            local xPlayer = ESX.GetPlayerFromId(source)
            if xPlayer then
                local itemCount = xPlayer.getInventoryItem("radio").count
                cb(itemCount > 0)
            else
                cb(false)
            end
        end)
    elseif Scully.Framework == "qbcore" then
        QBCore = exports['qb-core']:GetCoreObject()

        if Scully.UseItem then
            QBCore.Functions.CreateUseableItem("radio", function(source, item)
                TriggerClientEvent("scully_radio:openRadio", source)
            end)
        end

        QBCore.Functions.CreateCallback("scully_radio:itemCheck", function(source, cb)
            local xPlayer = QBCore.Functions.GetPlayer(source)
            if xPlayer then
                local HasRadio = xPlayer.Functions.GetItemByName("radio")
                cb(HasRadio)
            else
                cb(false)
            end
        end)

        RegisterNetEvent('hospital:server:SetDeathStatus', function(isDead)
            local _source = source
            if isDead then
                TriggerClientEvent("qbcore:onPlayerDeath", _source)
            end
        end)
    elseif Scully.Framework == "none" then
        RegisterNetEvent("scully_radio:requestIdentifiers", function()
            local _source = source
            local identifiers = GetPlayerIdentifiers(_source)
            TriggerClientEvent("scully_radio:sendIdentifiers", _source, identifiers)
        end)
    end
end

RegisterNetEvent("scully_radio:updatelist", function(channel)
    local _source = source
    if channel == 0 then
        TriggerClientEvent("scully_radio:updatelist", _source, false)
        return
    end
    local players = exports['pma-voice']:getPlayersInRadioChannel(channel)
    local list = {}
    for player, isTalking in pairs(players) do
        if Scully.Framework == "scully" then
            local xPlayer = exports.scully_core:GetPlayerDataFromId(player)
            if xPlayer.character then
                table.insert(list, xPlayer.character.callsign .. " | " .. string.sub(xPlayer.character.firstname, 1, 1) .. ". " .. xPlayer.character.lastname)
            else
                table.insert(list, GetPlayerName(player))
            end
        elseif Scully.Framework == "esx" then
            local xPlayer = ESX.GetPlayerFromId(player)
            table.insert(list, xPlayer.get('firstName') .. " " .. xPlayer.get('lastName'))
        elseif Scully.Framework == "qbcore" then
            local xPlayer = QBCore.Functions.GetPlayer(player)
            table.insert(list, xPlayer.PlayerData.charinfo.firstname .. " " .. xPlayer.PlayerData.charinfo.lastname)
        end
    end
    TriggerClientEvent("scully_radio:updatelist", _source, list)
end)