fx = {}

fx.propname = "bzzz_xmas23_convert_tree_gift" -- Credits: https://forum.cfx.re/t/props-christmas-for-mappers/5181133

fx.viewdistance = 100.0 -- Distance at which gifts will start spawning
fx.enablesnow = true
fx.enablesnowballs = true

fx.snowballsettings = {
    pickupkey = 119, -- Default: G key
    snowballsperpickup = 2,
    pickupcooldown = 1950,
    weaponname = "weapon_snowball",
    notifyonpickup = true
}

-- Interaction type: 'text' or 'target'
fx.interactiontype = 'target'

fx.collectionanim = {
    dict = "anim@mp_snowball",
    anim = "pickup_snowball",
    duration = 2000,
    label = "Collecting gift..."
}

fx.rewards = {
    [1] = {
        money = {min = 10000, max = 15000},
        items = {
            {name = "weapon_pistol", count = 1}
        }
    },
    [2] = {
        money = {min = 5000, max = 8000},
        items = {
            {name = "burger", count = 5},
            {name = "water", count = 5}
        }
    },
    [3] = {
        money = {min = 20000, max = 25000},
        items = {}
    },
    [4] = {
        money = {min = 0, max = 0},
        items = {
            {name = "weapon_smg", count = 1},
            {name = "ammo-9", count = 100}
        }
    },
    [5] = {
        money = {min = 15000, max = 20000},
        items = {
            {name = "lockpick", count = 3}
        }
    },
    [6] = {
        money = {min = 8000, max = 12000},
        items = {
            {name = "bandage", count = 10}
        }
    },
    [7] = {
        money = {min = 25000, max = 30000},
        items = {}
    },
    [8] = {
        money = {min = 0, max = 0},
        items = {
            {name = "weapon_carbinerifle", count = 1},
            {name = "ammo-rifle", count = 200}
        }
    },
    [9] = {
        money = {min = 10000, max = 15000},
        items = {
            {name = "phone", count = 1},
            {name = "radio", count = 1}
        }
    },
    [10] = {
        money = {min = 18000, max = 22000},
        items = {
            {name = "lockpick", count = 5}
        }
    },
    [11] = {
        money = {min = 12000, max = 16000},
        items = {
            {name = "burger", count = 10},
            {name = "water", count = 10}
        }
    },
    [12] = {
        money = {min = 30000, max = 35000},
        items = {}
    },
    [13] = {
        money = {min = 0, max = 0},
        items = {
            {name = "weapon_shotgun", count = 1},
            {name = "ammo-shotgun", count = 50}
        }
    },
    [14] = {
        money = {min = 15000, max = 18000},
        items = {
            {name = "repairkit", count = 2}
        }
    },
    [15] = {
        money = {min = 22000, max = 28000},
        items = {
            {name = "weapon_combatpistol", count = 1},
            {name = "ammo-pistol", count = 100}
        }
    },
    [16] = {
        money = {min = 40000, max = 50000},
        items = {}
    },
    [17] = {
        money = {min = 0, max = 0},
        items = {
            {name = "weapon_assaultrifle", count = 1},
            {name = "ammo-rifle", count = 300}
        }
    },
    [18] = {
        money = {min = 20000, max = 25000},
        items = {
            {name = "lockpick", count = 10}
        }
    },
    [19] = {
        money = {min = 25000, max = 30000},
        items = {
            {name = "bandage", count = 20}
        }
    },
    [20] = {
        money = {min = 35000, max = 40000},
        items = {}
    },
    [21] = {
        money = {min = 0, max = 0},
        items = {
            {name = "weapon_sniperrifle", count = 1},
            {name = "ammo-sniper", count = 50}
        }
    },
    [22] = {
        money = {min = 50000, max = 60000},
        items = {
            {name = "armour", count = 2}
        }
    },
    [23] = {
        money = {min = 45000, max = 55000},
        items = {
            {name = "weapon_knife", count = 1},
            {name = "lockpick", count = 5}
        }
    },
    [24] = {
        money = {min = 100000, max = 150000},
        items = {
            {name = "weapon_combatpistol", count = 1},
            {name = "armour", count = 3}
        }
    }
}

fx.locations = {
    {coords = vector4(154.2419, -1038.1038, 29.3139, 70.7248), reward = 1},      -- Legion square bank
    {coords = vector4(-1116.2338, -827.8639, 19.3161, 79.9140), reward = 2},     -- Vespucci pd
    {coords = vector4(-358.0140, -137.4088, 39.4306, 252.1214), reward = 3},     -- Los santos customs
    {coords = vector4(300.3682, -573.1422, 43.2615, 199.4884), reward = 4},      -- Pillbox hill ems
    {coords = vector4(-1040.0410, -2731.6516, 20.1555, 113.3024), reward = 5},   -- LSIA
    {coords = vector4(-13.3650, -1441.9994, 31.1012, 10.5975), reward = 6},      -- Franklin's house (grove St)
    {coords = vector4(333.8082, -202.4494, 54.2264, 249.2897), reward = 7},      -- Pinkcage motel
    {coords = vector4(920.6014, 40.5109, 81.0960, 150.8566), reward = 8},        -- Casino entrance
    {coords = vector4(1391.8140, 1157.8063, 114.4433, 271.2303), reward = 9},    -- La fuente blanca
    {coords = vector4(1178.5769, 2702.8826, 38.1703, 283.4202), reward = 10},    -- R68 bank
    {coords = vector4(1862.3064, 3687.0117, 34.2675, 296.8862), reward = 11},    -- Sandy shores sheriff
    {coords = vector4(2451.1550, 4970.5366, 46.5714, 226.5949), reward = 12},    -- Oneil ranch
    {coords = vector4(112.5340, 6619.8154, 31.8210, 313.5454), reward = 13},     -- Paleto lsc
    {coords = vector4(-106.6533, 6464.4360, 32.0630, 135.1958), reward = 14},    -- Paleto bank
    {coords = vector4(-447.8351, 6012.9370, 32.6934, 47.1876), reward = 15},     -- Paleto sd
    {coords = vector4(457.1667, 5571.8613, 781.1837, 183.6849), reward = 16},    -- Mount chiliad cable car top
    {coords = vector4(499.7014, 5606.3975, 796.6908, 84.2611), reward = 17},     -- Mount chiliad 
    {coords = vector4(3426.7017, 5174.6357, 7.4145, 179.9268), reward = 18},     -- Lighthouse
    {coords = vector4(2746.7258, 3464.7827, 57.5934, 155.9054), reward = 19},    -- Youtool
    {coords = vector4(2427.9360, 3082.3474, 49.0876, 100.4794), reward = 20},    -- Sandy shores scrapyard
    {coords = vector4(1846.0731, 2584.3564, 45.6720, 5.5445), reward = 21},      -- Bolingbroke prison
    {coords = vector4(-1888.0323, 2050.7273, 140.9840, 253.0233), reward = 22},  -- Marlowe vineard
    {coords = vector4(-1577.4224, 2101.1804, 68.2829, 70.1163), reward = 23}     -- Owl statue near marlowe vineyard
}
