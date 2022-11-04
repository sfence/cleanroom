
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

minetest.register_node("cleanroom:block_aluminium", {
	description = S("Aluminium Block with Surface for Cleanrooms"),
	tiles = {"cleanroom_block_aluminium.png"},
	is_ground_content = true,
	groups = {cracky = 3, stone = 1},
	sounds = metal_sounds,
  
  _pressure_const = false,
  _particles_part = 0.1,
  _particles_func = cleanroom.get_dustlevel_particles_cleanwall,
  _pressure_update = cleanroom.pressure_update_cleanwall,
  _cleaning_eff = 0.85,
})

minetest.register_node("cleanroom:block_stainless_steel", {
	description = S("Stainless Steel Block with Surface for Cleanrooms"),
	tiles = {"cleanroom_block_aluminium.png"},
	is_ground_content = true,
	groups = {cracky = 3, stone = 1},
	sounds = metal_sounds,
  
  _pressure_const = false,
  _particles_part = 0.1,
  _particles_func = cleanroom.get_dustlevel_particles_cleanwall,
  _pressure_update = cleanroom.pressure_update_cleanwall,
  _cleaning_eff = 0.8,
})

minetest.register_node("cleanroom:block_gold", {
	description = S("Gold Block with Surface for Cleanrooms"),
	tiles = {"cleanroom_block_gold.png"},
	is_ground_content = true,
	groups = {cracky = 3, stone = 1},
	sounds = metal_sounds,
  
  _pressure_const = false,
  _particles_part = 0.1,
  _particles_func = cleanroom.get_dustlevel_particles_cleanwall,
  _pressure_update = cleanroom.pressure_update_cleanwall,
  _cleaning_eff = 0.9,
})

minetest.register_node("cleanroom:block_polished_gold", {
	description = S("Polished Gold Block with Surface for Cleanrooms"),
	tiles = {"cleanroom_block_polished_gold.png"},
	is_ground_content = true,
	groups = {cracky = 3, stone = 1},
	sounds = metal_sounds,
  
  _pressure_const = false,
  _particles_part = 0.01,
  _particles_func = cleanroom.get_dustlevel_particles_cleanwall,
  _pressure_update = cleanroom.pressure_update_cleanwall,
  _cleaning_eff = 0.99,
})

local grating_node_box = {
    type = "fixed",
    fixed = {
      {-8/16,7/16,-8/16,  -7/16,8/16,8/16},
      {-6/16,7/16,-8/16,  -5/16,8/16,8/16},
      {-4/16,7/16,-8/16,  -3/16,8/16,8/16},
      {-2/16,7/16,-8/16,  -1/16,8/16,8/16},
      {1/16,7/16,-8/16,   2/16,8/16,8/16},
      {3/16,7/16,-8/16,   4/16,8/16,8/16},
      {5/16,7/16,-8/16,   6/16,8/16,8/16},
      {7/16,7/16,-8/16,   8/16,8/16,8/16},
      
      {-8/16,7/16,-8/16,  8/16,8/16,-7/16},
      {-8/16,7/16,-6/16,  8/16,8/16,-5/16},
      {-8/16,7/16,-4/16,  8/16,8/16,-3/16},
      {-8/16,7/16,-2/16,  8/16,8/16,-1/16},
      {-8/16,7/16,1/16,   8/16,8/16,2/16},
      {-8/16,7/16,3/16,   8/16,8/16,4/16},
      {-8/16,7/16,5/16,   8/16,8/16,6/16},
      {-8/16,7/16,7/16,   8/16,8/16,8/16},
    },
  }

minetest.register_node("cleanroom:grating_gold", {
	description = S("Gold Floor Grating for Cleanrooms"),
	tiles = {"cleanroom_block_gold.png"},
	is_ground_content = true,
	groups = {cracky = 3, stone = 1},
	sounds = metal_sounds,
  
  drawtype = "nodebox",
  node_box = grating_node_box,
  
  _pressure_func = cleanroom.get_pressure_meta,
  _particles_part = 0.05,
  _particles_func = cleanroom.get_dustlevel_particles_cleanwall,
  _pressure_update = cleanroom.pressure_update_cleanwall,
  _cleaning_eff = 0.85,
})

minetest.register_node("cleanroom:block_gold_glass", {
	description = S("Gold Glass for Cleanrooms"),
	tiles = {"cleanroom_block_gold.png", "cleanroom_block_glass.png"},
	is_ground_content = true,
	groups = {cracky = 3, stone = 1},
	sounds = metal_sounds,
  
  paramtype = "light",
  drawtype = "mesh",
  mesh = "cleanroom_node_frame.obj",
  use_texture_alpha = "clip",
  
  _pressure_func = cleanroom.get_pressure_meta,
  _particles_part = 0.05,
  _particles_func = cleanroom.get_dustlevel_particles_cleanwall,
  _pressure_update = cleanroom.pressure_update_cleanwall,
  _cleaning_eff = 0.85,
})
