-- cleanroom mesecon compatible switch

local S = cleanroom.translator

mesecon.register_node("cleanroom:mesecon_switch_gold", {
  description=S("Switch"),
  paramtype2="facedir",
  is_ground_content = false,
  sounds = default.node_sound_stone_defaults(),
      
  _pressure_const = false,
  _particles_part = 0.01,
  _particles_func = cleanroom.get_dustlevel_particles_cleanwall,
  _pressure_update = cleanroom.pressure_update_cleanwall,
  _cleaning_eff = 0.9,
  
  on_rightclick = function (pos, node)
    if(mesecon.flipstate(pos, node) == "on") then
      mesecon.receptor_on(pos)
    else
      mesecon.receptor_off(pos)
    end
    minetest.sound_play("mesecons_switch", { pos = pos }, true)
  end
},{
  groups = {dig_immediate=2},
  tiles = {
        "cleanroom_block_gold.png", "cleanroom_block_gold.png",
        "cleanroom_block_gold.png", "cleanroom_block_gold.png",
        "cleanroom_block_gold.png", "cleanroom_switch_gold_off.png"},
  mesecons = {receptor = { state = mesecon.state.off }}
},{
  groups = {dig_immediate=2, not_in_creative_inventory=1},
  tiles = {
        "cleanroom_block_gold.png", "cleanroom_block_gold.png",
        "cleanroom_block_gold.png", "cleanroom_block_gold.png",
        "cleanroom_block_gold.png", "cleanroom_switch_gold_on.png"},
  mesecons = {receptor = { state = mesecon.state.on }}
})

minetest.register_craft({
  output = "mesecons_switch:mesecon_switch_off 2",
  recipe = {
    {"default:steel_ingot", "default:cobble", "default:steel_ingot"},
    {"group:mesecon_conductor_craftable","", "group:mesecon_conductor_craftable"},
  }
})

