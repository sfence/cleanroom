
local S = cleanroom.translator

local stone_sounds = nil
local metal_sounds = nil
if minetest.get_modpath("default") then
	stone_sounds = default.node_sound_stone_defaults()
	metal_sounds = default.node_sound_metal_defaults()
end
if minetest.get_modpath("hades_sounds") then
	stone_sounds = hades_sounds.node_sound_stone_defaults()
	metal_sounds = hades_sounds.node_sound_metal_defaults()
end

minetest.register_node("cleanroom:concreate", {
	description = S("Concreate with Surface for Cleanrooms"),
	tiles = {"cleannroom_concreate.png"},
	is_ground_content = true,
	drop = "cleanroom:concreate_cobble",
	groups = {cracky = 3, stone = 1},
	sounds = stone_sounds,
})

minetest.register_node("cleanroom:steelblock", {
	description = S("Steel block with Surface for Cleanrooms"),
	tiles = {"cleannroom_stealblock.png"},
	is_ground_content = true,
	drop = "cleanroom:steelblock",
	groups = {cracky = 3, stone = 1},
	sounds = metal_sounds,
})

