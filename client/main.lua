local QBCore = exports['qb-core']:GetCoreObject()

local dui = nil
local duiCounter = 0
local availableDuis = {}
local duis = {}

Citizen.CreateThread(function()

    -- Sync Image
    QBCore.Functions.TriggerCallback('qb-whiteboard:getCurrentImage', function(images)
        for k,v in pairs(images) do
            if Config.Locations[k] ~= nil then
                Config.Locations[k].currentImage = v
            end
        end
    end)

    -- Setup Zones
    for k,v in pairs(Config.Locations) do

        local Zones = {}
        Zones[#Zones + 1] = BoxZone:Create(
            v.PolyZone.coords, v.PolyZone.length, v.PolyZone.width, {
                name = k..'_Room',
                debugPoly = Config.Debug,
                minZ = v.PolyZone.minZ,
                maxZ = v.PolyZone.maxZ
            }
        )

        local Combo = ComboZone:Create(Zones, {name = k..'_Room', debugPoly = false})
        Combo:onPlayerInOut(function(isPointInside)
            if isPointInside then
                if not dui then
                    dui = getDui(v.currentImage)
                    AddReplaceTexture(v.origTxd, v.origTxn, dui.dictionary, dui.texture)
                else
                    changeDuiUrl(dui.id, v.currentImage)
                end
                Config.Locations[k].inZone = true
            else
                RemoveReplaceTexture(v.origTxd, v.origTxn)
                if dui ~= nil then
                    releaseDui(dui.id)
                    dui = nil
                end
                Config.Locations[k].inZone = false
            end
        end)

        exports['qb-target']:AddBoxZone(k..'_Target', v.Target.coords, v.Target.length, v.Target.width, {
            name = k..'_Target',
            heading = 0,
            debugPoly = false,
            minZ = v.Target.minZ,
            maxZ = v.Target.maxZ
        }, {
            options = {
                {
                    type = "client",
                    event = "qb-whiteboard:changewhiteboardurl",
                    location = k,
                    icon = "fa fa-camera",
                    label = "Change Image",
                    job = v.job
                },
                {
                    type = "client",
                    event = "qb-whiteboard:changewhiteboardurl",
                    url = Config.DefaultBoardUrl,
                    location = k,
                    icon = "fa fa-lock",
                    label = "Remove Image",
                    job = v.job
                },
            },
            distance = 2.5
        })
    end

end)

function getDui(url, width, height)
    width = width or 512
    height = height or 512

    local duiSize = tostring(width) .. "x" .. tostring(height)

    if (availableDuis[duiSize] and #availableDuis[duiSize] > 0) then
        local n,t = pairs(availableDuis[duiSize])
        local nextKey, nextValue = n(t)
        local id = nextValue
        local dictionary = duis[id].textureDictName
        local texture = duis[id].textureName

        nextValue = nil
        table.remove(availableDuis[duiSize], nextKey)

        SetDuiUrl(duis[id].duiObject, url)

        return {id = id, dictionary = dictionary, texture = texture}
    end

    duiCounter = duiCounter + 1
    local generatedDictName = duiSize.."-dict-"..tostring(duiCounter)
    local generatedTxtName = duiSize.."-txt-"..tostring(duiCounter)
    local duiObject = CreateDui(url, width, height)
    local dictObject = CreateRuntimeTxd(generatedDictName)
    local duiHandle = GetDuiHandle(duiObject)
    local txdObject = CreateRuntimeTextureFromDuiHandle(dictObject, generatedTxtName, duiHandle)

    duis[duiCounter] = {
        duiSize = duiSize,
        duiObject = duiObject,
        duiHandle = duiHandle,
        dictionaryObject = dictObject,
        textureObject = txdObject,
        textureDictName = generatedDictName,
        textureName = generatedTxtName
    }

    return {id = duiCounter, dictionary = generatedDictName, texture = generatedTxtName}
end

function changeDuiUrl(id, url)
    if (not duis[id]) then
        return
    end

    local settings = duis[id]
    SetDuiUrl(settings.duiObject, url)
end

function releaseDui(id)
    if (not duis[id]) then
        return
    end

    local settings = duis[id]
    local duiSize = settings.duiSize

    SetDuiUrl(settings.duiObject, "about:blank")
    if not availableDuis[duiSize] then
      availableDuis[duiSize] = {}
    end
    table.insert(availableDuis[duiSize], id)
end

AddEventHandler("qb-whiteboard:changewhiteboardurl", function(data)
    if data.url then
        TriggerServerEvent("qb-whiteboard:changewhiteboard", data.url, data.location)
    else
        local keyboard = exports['qb-input']:ShowInput({
            header = "URL",
            submitText = "Confirm",
            inputs = {
                {
                    type = 'text',
                    isRequired = true,
                    text = "link",
                    name = 'input',
                }
            }
        })
        local link = keyboard.input
        if link then
            TriggerServerEvent("qb-whiteboard:changewhiteboard", link, data.location)
        end
    end
end)

RegisterNetEvent("qb-whiteboard:changewhiteboardcli", function(pUrl, pRoom)
    if Config.Locations[pRoom] ~= nil then
        Config.Locations[pRoom].currentImage = pUrl

        if Config.Locations[pRoom].inZone and dui then
            changeDuiUrl(dui.id, Config.Locations[pRoom].currentImage)
        end
    end
end)
