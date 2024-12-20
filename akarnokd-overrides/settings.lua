data:extend({
    {
        type = "bool-setting",
        name = "akarnokd-override-stack-size-enable",
        order = "a",
        setting_type = "startup",
        default_value = true,
    },
    {
        type = "int-setting",
        name = "akarnokd-override-stack-size",
        order = "b",
        setting_type = "startup",
        default_value = 1000000,
        minimum_value = 1,
        maximum_value = 1000000000
    },
    {
        type = "bool-setting",
        name = "akarnokd-override-machine-speed-enable",
        order = "c",
        setting_type = "startup",
        default_value = true,
    },
    {
        type = "int-setting",
        name = "akarnokd-override-machine-speed",
        order = "d",
        setting_type = "startup",
        default_value = 100,
        minimum_value = 1,
        maximum_value = 1000000000
    },
    {
        type = "int-setting",
        name = "akarnokd-override-pole-reach",
        order = "e",
        setting_type = "startup",
        default_value = 45,
        minimum_value = 1,
        maximum_value = 1000000000
    },
    {
        type = "int-setting",
        name = "akarnokd-override-character-reach",
        order = "f",
        setting_type = "startup",
        default_value = 100,
        minimum_value = 1,
        maximum_value = 1000000000
    },
    {
        type = "double-setting",
        name = "akarnokd-override-character-speed",
        order = "g",
        setting_type = "startup",
        default_value = 0.45,
        minimum_value = 0.01,
        maximum_value = 100.0
    },
    {
        type = "double-setting",
        name = "akarnokd-override-character-mining-speed",
        order = "h",
        setting_type = "startup",
        default_value = 100,
        minimum_value = 1,
        maximum_value = 10000000
    },
    {
        type = "double-setting",
        name = "akarnokd-override-drone-speed",
        order = "i",
        setting_type = "startup",
        default_value = 0.5,
        minimum_value = 0.01,
        maximum_value = 100.0
    },
    {
        type = "int-setting",
        name = "akarnokd-override-drone-capacity",
        order = "j",
        setting_type = "startup",
        default_value = 50,
        minimum_value = 1,
        maximum_value = 1000000
    },
    {
        type = "int-setting",
        name = "akarnokd-override-miner-range",
        order = "k",
        setting_type = "startup",
        default_value = 0,
        minimum_value = 0,
        maximum_value = 1000000
    },
    {
        type = "bool-setting",
        name = "akarnokd-override-early-robots",
        order = "l",
        setting_type = "startup",
        default_value = false,
    },
    {
        type = "int-setting",
        name = "akarnokd-override-recipe-mult",
        order = "k",
        setting_type = "startup",
        default_value = 1,
        minimum_value = 1,
        maximum_value = 1000
    },
    {
        type = "bool-setting",
        name = "akarnokd-override-cheese",
        order = "m",
        setting_type = "startup",
        default_value = false,
    },
})