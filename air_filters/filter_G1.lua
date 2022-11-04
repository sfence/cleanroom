--------------------------
-- Bacterium Cultivator --
--------------------------
--------- Ver 2.0 --------
-----------------------
-- Initial Functions --
-----------------------
local S = cleanroom.translator;

cleanroom.filter_G1 = appliances.appliance:new(
    {
      node_name_inactive = "cleanroom:filter_G1",
      node_name_active = "cleanroom:filter_G1_active",
      
      node_description = S("Air Filter G1"),
      
      input_stack_size = 1,
      input_stack = "filter",
      use_stack_size = 0,
      have_usage = false,
      output_stack_size = 0,
    })

local filter_G1 = cleanroom.filter_G1;

filter_G1:power_data_register(
  {
    ["time_power"] = {
        run_speed = 0,
      },
  })
filter_G1:item_data_register(
  {
    ["tube_item"] = {
      },
  })

--------------
-- Formspec --
--------------

function filter_G1:get_formspec(meta, production_percent, consumption_percent)
  local progress = "image[3.6,0.9;5.5,0.95;appliances_production_progress_bar.png^[transformR270]]";
  if production_percent then
    progress = "image[3.6,0.9;5.5,0.95;appliances_production_progress_bar.png^[lowpart:" ..
            (production_percent) ..
            ":appliances_production_progress_bar_full.png^[transformR270]]";
  end
  
  
  
  local formspec =  "size[12.75,8.5]" ..
                    "background[-1.25,-1.25;15,10;appliances_appliance_formspec.png]" ..
                    progress..
                    "list[current_player;main;0.3,3;10,4;]" ..
                    "list[context;"..self.input_stack..";2,0.8;1,1;]"..
                    "list[context;"..self.output_stack..";9.75,0.8;1,1;]" ..
                    "listring[current_player;main]" ..
                    "listring[context;"..self.input_stack.."]" ..
                    "listring[current_player;main]" ..
                    "listring[context;"..self.output_stack.."]" ..
                    "listring[current_player;main]";
  return formspec;
end

--------------------
-- Node callbacks --
--------------------

function filter_G1:cb_on_production(timer_step)
  cleanroom.filter_filter_air(timer_step.pos, timer_step.meta)
end

----------
-- Node --
----------

local node_def = {
    paramtype2 = "facedir",
    groups = {cracky = 2},
    legacy_facedir_simple = true,
    is_ground_content = false,
    --sounds = hades_sounds.node_sound_stone_defaults(),
    drawtype = "node",
    
    _pressure_const = false,
    _particles_part = 0.005,
    _particles_func = cleanroom.get_dustlevel_particles_cleanwall,
    _pressure_update = cleanroom.pressure_update_cleanwall,
    _cleaning_eff = 0.8,
  }

local node_inactive = {
    tiles = {
      "cleanroom_filter_G1_top.png",
      "cleanroom_filter_G1_bottom.png",
      "cleanroom_filter_G1_side.png",
      "cleanroom_filter_G1_side.png",
      "cleanroom_filter_G1_side.png",
      "cleanroom_filter_G1_front.png"
    },
  }

local node_active = {
    tiles = {
      "cleanroom_filter_G1_top.png",
      "cleanroom_filter_G1_bottom.png",
      "cleanroom_filter_G1_side.png",
      "cleanroom_filter_G1_side.png",
      "cleanroom_filter_G1_side.png",
      {
        image = "cleanroom_filter_G1_front_active.png",
        backface_culling = true,
        animation = {
          type = "vertical_frames",
          aspect_w = 16,
          aspect_h = 16,
          length = 1.5
        }
      }
    },
  }

filter_G1:register_nodes(node_def, node_inactive, node_active)

-------------------------
-- Recipe Registration --
-------------------------

appliances.register_craft_type("cleanroom_filter_G1_use", {
    description = S("Filtration"),
    width = 1,
    height = 1,
  })


filter_G1:register_recipes("", "cleanroom_filter_G1_use")

