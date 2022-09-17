local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('qb-whiteboard:changewhiteboard', function(url, room)
    local Player = QBCore.Functions.GetPlayer(source)
    if Config.Locations[room].job == false or Player.PlayerData.job.name == Config.Locations[room].job then
        TriggerClientEvent('qb-whiteboard:changewhiteboardcli', -1, url, room)
    end
end)