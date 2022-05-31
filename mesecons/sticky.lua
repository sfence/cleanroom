
local S = cleanroom.translator

minetest.register_node("cleanroom:stickyblock_gold", {
    description = S("Gold Sticky Block"),
    tiles = {"cleanroom_stickyblock_gold.png"},
    is_ground_content = false,
    groups = {choppy=3, oddly_breakable_by_hand=2},
    sounds = default.node_sound_wood_defaults(),
    
    mvps_sticky = function (pos, node)
      local connected = {}
      local dir = minetest.facedir_to_dir(node.param2%32)
      return {
          vector.add(pos, dir),
          vector.subtract(pos, dir),
        }
    end, 
  
    _pressure_const = false,
    _particles_part = 0.005,
    _particles_func = cleanroom.get_dustlevel_particles_cleanwall,
    _pressure_update = cleanroom.pressure_update_cleanwall,
    _cleaning_eff = 0.5,
  })

