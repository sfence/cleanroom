--------------------------
-- Bacterium Cultivator --
--------------------------
--------- Ver 2.0 --------
-----------------------
-- Initial Functions --
-----------------------
local S = cleanroom.translator;

cleanroom.ventilator_M1 = appliances.appliance:new(
    {
      node_name_inactive = "cleanroom:ventilator_M1",
      node_name_active = "cleanroom:ventilator_M1_active",
      
      node_description = S("Ventilator M1"),
    	node_help = S("Connect to power 50 EU (LV)"),
      
      power_connect_sides = {"top"},
      
      output_stack_size = 0,
      output_stack = "use_in",
      input_stack_size = 0,
      have_input = false,
      
      have_control = true,
      
      sounds = {
        running = {
          sound = "cleanroom_ventilator_running",
          sound_param = {max_hear_distance = 8, gain = 0.1},
          repeat_timer = 0,
        },
      },
    })

local ventilator_M1 = cleanroom.ventilator_M1;

ventilator_M1:power_data_register(
  {
    ["LV_power"] = {
        demand = 50,
        run_speed = 1,
        disable = {"no_power"},
      },
    ["power_generators_power"] = {
        demand = 50,
        run_speed = 1,
        disable = {"no_power"},
      },
    ["no_power"] = {
        run_speed = 0,
      },
  })
ventilator_M1:control_data_register(
  {
    ["punch_control"] = {
      },
  })

--------------
-- Formspec --
--------------

local player_inv = "list[current_player;main;1.5,3;8,4;]"
if minetest.get_modpath("hades_core") then
  player_inv = "list[current_player;main;0.5,3;10,4;]"
end

function ventilator_M1:get_formspec(meta, production_percent, consumption_percent)
  local progress = "image[3.6,0.9;5.5,0.95;appliances_production_progress_bar.png^[transformR270]]";
  if consumption_percent then
    progress = "image[3.6,1.5;5.5,0.95;appliances_production_progress_bar.png^[lowpart:" ..
            (consumption_percent) ..
            ":appliances_production_progress_bar_full.png^[transformR270]]";
  end
  
  
  
  local formspec =  "formspec_version[3]" .. "size[12.75,8.5]" ..
                    "background[-1.25,-1.25;15,10;appliances_appliance_formspec.png]" ..
                    progress..
                    player_inv ..
                    "list[context;"..self.use_stack..";6,0.3;1,1;]"..
                    "listring[context;"..self.use_stack.."]" ..
                    "listring[current_player;main]";
  return formspec;
end

--------------------
-- Node callbacks --
--------------------

function ventilator_M1:cb_on_production(timer_step)
  cleanroom.ventilator_push_air(timer_step.pos, timer_step.meta, 0.05)
end

----------
-- Node --
----------

local node_sounds = nil

if minetest.get_modpath("default") then
  node_sounds = default.node_sound_metal_defaults()
end
if minetest.get_modpath("hades_sounds") then
  node_sounds = hades_sounds.node_sound_metal_defaults()
end

local node_def = {
    paramtype2 = "facedir",
    groups = {cracky = 2},
    legacy_facedir_simple = true,
    is_ground_content = false,
    sounds = node_sounds,
    drawtype = "mesh",
  }

local node_inactive = {
    mesh = "cleanroom_ventilator.obj",
    tiles = {
      "default_steel_block.png",
      "cleanroom_ventilator_motor.png",
      "cleanroom_ventilator_shalt.png",
      "cleanroom_ventilator_vane.png",
    },
  }

local node_active = {
    mesh = "cleanroom_ventilator_active.obj",
    tiles = {
      "default_steel_block.png",
      "cleanroom_ventilator_motor.png",
      {
        image = "cleanroom_ventilator_shalt_active.png",
        backface_culling = false,
        animation = {
          type = "vertical_frames",
          aspect_w = 16,
          aspect_h = 16,
          length = 1.5
        }
      },
      {
        image = "cleanroom_ventilator_vane_active.png",
        backface_culling = false,
        animation = {
          type = "vertical_frames",
          aspect_w = 16,
          aspect_h = 16,
          length = 1.5
        }
      }
    },
  }

ventilator_M1:register_nodes(node_def, node_inactive, node_active)

-------------------------
-- Recipe Registration --
-------------------------

appliances.register_craft_type("cleanroom_ventilator_use", {
    description = S("Use for ventiling"),
    icon = "clothing_recipe_spinning.png",
    width = 1,
    height = 1,
  })
  
ventilator_M1:recipe_register_usage(
  "cleanroom:grease",
  {
    outputs = {""},
    consumption_time = 300,
    production_step_size = 1,
  });

ventilator_M1:register_recipes("cleanroom_ventilator", "cleanroom_ventilator_use")

