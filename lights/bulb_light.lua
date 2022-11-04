----------------
-- Bulb Light --
----------------

-----------------------
-- Initial Functions --
-----------------------
local S = cleanroom.translator;

cleanroom.bulb_light = appliances.appliance:new(
    {
      node_name_inactive = "cleanroom:bulb_light",
      node_name_active = "cleanroom:bulb_light_active",
      
      node_description = S("Electric Bulb Light"),
      
      power_connect_sides = {"top"},
      
      input_stack_size = 1,
      use_stack_size = 0,
      have_usage = false,
      output_stack_size = 0,
      output_stack = "input",
      
      have_control = true,
    })

local bulb_light = cleanroom.bulb_light;

bulb_light:power_data_register(
  {
    ["LV_power"] = {
        demand = 80,
        run_speed = 1,
        disable = {"no_power"},
      },
    ["no_power"] = {
        run_speed = 0,
      },
  })
bulb_light:control_data_register(
  {
    ["punch_control"] = {
      },
  })

--------------
-- Formspec --
--------------

function bulb_light:get_formspec(meta, production_percent, consumption_percent)
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
                    "listring[current_player;main]" ..
                    "listring[context;"..self.input_stack.."]" ..
                    "listring[current_player;main]";
  return formspec;
end

--------------------
-- Node callbacks --
--------------------

----------
-- Node --
----------

local node_def = {
    paramtype = "light",
    groups = {cracky = 2, attached_node=0},
    legacy_facedir_simple = true,
    is_ground_content = false,
    --sounds = hades_sounds.node_sound_stone_defaults(),
    drawtype = "node",
    
    _pressure_const = false,
    _particles_part = 0.05,
    _particles_func = cleanroom.get_dustlevel_particles_cleanwall,
    _pressure_update = cleanroom.pressure_update_cleanwall,
    _cleaning_eff = 0.85,
  }

local node_inactive = {
    tiles = {
      "cleanroom_bulb_light_off.png",
    },
  }

local node_active = {
    light_source = minetest.LIGHT_MAX,
    tiles = {
      "cleanroom_bulb_light_on.png",
    },
  }

bulb_light:register_nodes(node_def, node_inactive, node_active)

-------------------------
-- Recipe Registration --
-------------------------

appliances.register_craft_type("cleanroom_bulb", {
    description = S("Lighting"),
    width = 1,
    height = 1,
  })

bulb_light:recipe_register_input("morelights:bulb", {
    inputs = 1,
    outputs = {""},
    production_time = 3600,
  })

bulb_light:register_recipes("", "cleanroom_bulb")

