data:extend({
    {
        type = "int-setting",
        name = "akarnokd-latc-max-items",
        order = "a",
        setting_type = "runtime-global",
        default_value = 10000,
    },
    {
        type = "bool-setting",
        name = "akarnokd-latc-insert-if-empty-output",
        order = "b",
        setting_type = "runtime-global",
        default_value = true,
    },
    {
        type = "int-setting",
        name = "akarnokd-latc-recipe-factor",
        order = "c",
        setting_type = "runtime-global",
        min_value = 1,
        default_value = 1
    },
    {
        type = "int-setting",
        name = "akarnokd-latc-provider-tick",
        order = "d",
        setting_type = "runtime-global",
        min_value = 1,
        default_value = 1
    },
    {
        type = "int-setting",
        name = "akarnokd-latc-requester-tick",
        order = "e",
        setting_type = "runtime-global",
        min_value = 1,
        default_value = 1
    },
})