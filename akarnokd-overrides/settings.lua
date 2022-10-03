data:extend({
    {
        type = "int-setting",
        name = "akarnokd-override-stack-size",
        order = "aa",
        setting_type = "startup",
        default_value = 1000000,
        minimum_value = 1,
        maximum_value = 1000000000
    },
    {
        type = "int-setting",
        name = "akarnokd-override-machine-speed",
        order = "aa",
        setting_type = "startup",
        default_value = 100,
        minimum_value = 1,
        maximum_value = 1000000000
    },
    {
        type = "int-setting",
        name = "akarnokd-override-pole-reach",
        order = "aa",
        setting_type = "startup",
        default_value = 45,
        minimum_value = 1,
        maximum_value = 1000000000
    },
    {
        type = "int-setting",
        name = "akarnokd-override-character-reach",
        order = "aa",
        setting_type = "startup",
        default_value = 100,
        minimum_value = 1,
        maximum_value = 1000000000
    },
    {
        type = "double-setting",
        name = "akarnokd-override-character-speed",
        order = "aa",
        setting_type = "startup",
        default_value = 0.45,
        minimum_value = 0.01,
        maximum_value = 100.0
    },
    {
        type = "double-setting",
        name = "akarnokd-override-character-mining-speed",
        order = "aa",
        setting_type = "startup",
        default_value = 100,
        minimum_value = 1,
        maximum_value = 10000000
    },
    {
        type = "double-setting",
        name = "akarnokd-override-drone-speed",
        order = "aa",
        setting_type = "startup",
        default_value = 0.5,
        minimum_value = 0.01,
        maximum_value = 100.0
    },
    {
        type = "int-setting",
        name = "akarnokd-override-drone-capacity",
        order = "aa",
        setting_type = "startup",
        default_value = 50,
        minimum_value = 1,
        maximum_value = 1000000
    },
})