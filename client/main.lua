local currentClassRoomBoardUrl = "https://cdn.discordapp.com/attachments/979775387896774661/982377179751018577/unknown.png"
local inClassRoom = false
local dui = nil
local duiCounter = 0
local availableDuis = {}
local duis = {}

Citizen.CreateThread(function()

    local classZones = {}
    classZones[1] = BoxZone:Create(
        vector3(444.6514, -985.756, 34.970), 10.2, 11.2, {
            name="class_zone",
            debugPoly = false,
            minZ = 33.9,
            maxZ = 37.2
        }
    )

    local ClassCombo = ComboZone:Create(classZones, {name = "ClassCombo", debugPoly = false})
    ClassCombo:onPlayerInOut(function(isPointInside)
        if isPointInside then
            if not dui then
                dui = getDui(currentClassRoomBoardUrl)
                AddReplaceTexture("prop_planning_b1", "prop_base_white_01b", dui.dictionary, dui.texture)
            else
                changeDuiUrl(dui.id, currentClassRoomBoardUrl)
            end
            inClassRoom = true
        else
            RemoveReplaceTexture("prop_planning_b1", "prop_base_white_01b")
            if dui ~= nil then
                releaseDui(dui.id)
                dui = nil
            end
            inClassRoom = false
        end
    end)

    exports['qb-target']:AddBoxZone("mrdp_change_picture", vector3(439.44, -985.89, 34.97), 1.0, 0.4, {
        name = "mrdp_change_picture",
        heading = 0,
        debugPoly = false,
        minZ = 35.37,
        maxZ = 36.17
    }, {
        options = {
            {
                type = "client",
                event = "qb-whiteboard:changewhiteboardurl",
                icon = "fa fa-camera",
                label = "Change Image",
                job = "police",
            },
        },
        distance = 2.5
    })

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

AddEventHandler("qb-whiteboard:changewhiteboardurl", function()
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
        TriggerServerEvent("qb-whiteboard:changewhiteboard", link, 'classroom')
    end
end)

RegisterNetEvent("qb-whiteboard:changewhiteboardcli", function(pUrl, pRoom)
    if pRoom == "classroom" then
        currentClassRoomBoardUrl = pUrl

        if inClassRoom and dui then
            changeDuiUrl(dui.id, currentClassRoomBoardUrl)
        end
    end
end)