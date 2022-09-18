Config = {}

Config.Debug = false -- Debug Status For PolyZone
Config.DefaultBoardUrl = "https://cdn.discordapp.com/attachments/979775387896774661/982377179751018577/unknown.png" -- Don't Edit

Config.Locations = {
    ['classroom'] = { -- Name Of Room
        PolyZone = { -- Room Area For After Enter Show Image
            coords = vector3(444.6514, -985.756, 34.970),
            length = 10.2,
            width = 11.2,
            minZ = 33.9,
            maxZ = 37.2
        },
        Target = { -- Area for Show Target Options
            coords = vector3(439.44, -985.89, 34.97),
            length = 1.0,
            width = 0.4,
            minZ = 35.37,
            maxZ = 36.17
        },
        -- Props For Replace Texture
        origTxd = 'prop_planning_b1', -- Prop
        origTxn = 'prop_base_white_01b', -- Texture
        job = 'police', -- Job Name Or false
        currentImage = Config.DefaultBoardUrl, -- Don't Edit
        inZone = false -- Don't Edit
    }
}