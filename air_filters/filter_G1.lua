--------------------------
-- Bacterium Cultivator --
--------------------------
--------- Ver 2.0 --------
-----------------------
-- Initial Functions --
-----------------------
local S = laboratory.translator;

laboratory.filter_G1 = appliances.appliance:new(
    {
      node_name_inactive = "hades_laboratory:filter_G1",
      node_name_active = "hades_laboratory:filter_G1_active",
      
      node_description = S("Bacterium cultivator"),
    	node_help = S("Connect to power 50 EU (LV)").."\n"..S("Cultivate bacteries in growth medium"),
      
      output_stack_size = 1,
      use_stack_size = 0,
      have_usage = false,
    })

local filter_G1 = laboratory.filter_G1;

filter_G1:power_data_register(
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
  
  
  
  local formspec =  "formspec_version[3]" .. "size[12.75,8.5]" ..
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

----------
-- Node --
----------

local node_def = {
    paramtype2 = "facedir",
    groups = {cracky = 2},
    legacy_facedir_simple = true,
    is_ground_content = false,
    sounds = hades_sounds.node_sound_stone_defaults(),
    drawtype = "node",
    
    _pressure_const = false,
    _particles_part = 0.005,
    _particles_func = cleanroom.get_dustlevel_particles_cleanwall,
    _pressure_update = cleanroom.pressure_update_cleanwall,
    _cleaning_eff = 0.8,
  }

local node_inactive = {
    tiles = {
      "laboratory_filter_G1_top.png",
      "laboratory_filter_G1_bottom.png",
      "laboratory_filter_G1_side.png",
      "laboratory_filter_G1_side.png",
      "laboratory_filter_G1_side.png",
      "laboratory_filter_G1_front.png"
    },
  }

local node_active = {
    tiles = {
      "laboratory_filter_G1_top.png",
      "laboratory_filter_G1_bottom.png",
      "laboratory_filter_G1_side.png",
      "laboratory_filter_G1_side.png",
      "laboratory_filter_G1_side.png",
      {
        image = "laboratory_filter_G1_front_active.png",
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

appliances.register_craft_type("laboratory_filter_G1", {
    description = S("Cultivating"),
    width = 1,
    height = 1,
  })

if laboratory.have_paleotest then

  filter_G1:recipe_register_input(
    "hades_laboratory:growth_medium",
    {
      inputs = 1,
      outputs = {"hades_laboratory:medium_with_bacteries"},
      production_time = 180,
      consumption_step_size = 1,
    });
  for i=2,5 do
    filter_G1:recipe_register_input(
      "hades_laboratory:growth_medium_use_"..i,
      {
        inputs = 1,
        outputs = {"hades_laboratory:medium_with_bacteries_"..i},
        production_time = 180,
        consumption_step_size = 1,
      });
  end
end

filter_G1:register_recipes("laboratory_filter_G1", "laboratory_filter_G1_use")

