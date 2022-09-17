local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('qb-whiteboard:changewhiteboard', function(url, room)
    local Player = QBCore.Functions.GetPlayer(source)
    if Player.PlayerData.job.name == 'police' then
        TriggerClientEvent('qb-whiteboard:changewhiteboardcli', -1, url, room)
    end
end)