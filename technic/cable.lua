
local S = cleanroom.translator

local adaptation = cleanroom.adaptation

if (not adaptation.LV_cable) then
  return
end

local LV_cable_def = minetest.registered_nodes[adaptation.LV_cable.name]

technic.register_cable_tier("cleanroom:technic_lv_cable_in_gold", "LV")
minetest.register_node("cleanroom:technic_lv_cable_in_gold", {
    description = S("Cleanroom Compatible LV Cable"),
    tiles = {"cleanroom_block_gold.png^cleanroom_technic_LV_cable.png"},
    groups = {cracky = 2, technic_lv_cable = 1},
    sounds = LV_cable_def.sounds,
    on_construct = LV_cable_def.on_construct,
    on_destruct = LV_cable_def.on_destruct,
  
    _pressure_const = false,
    _particles_part = 0.15,
    _particles_func = cleanroom.get_dustlevel_particles_cleanwall,
    _pressure_update = cleanroom.pressure_update_cleanwall,
    _cleaning_eff = 0.85,
  })

minetest.register_alias("cleanroom:technic_LV_cable_in_gold", "cleanroom:technic_lv_cable_in_gold")
