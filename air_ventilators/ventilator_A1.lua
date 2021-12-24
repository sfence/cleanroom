--------------------------
-- Bacterium Cultivator --
--------------------------
--------- Ver 2.0 --------
-----------------------
-- Initial Functions --
-----------------------
local S = cleanroom.translator;

cleanroom.ventilator_A1 = appliances.appliance:new(
    {
      node_name_inactive = "cleanroom:ventilator_A1",
      node_name_active = "cleanroom:ventilator_A1_active",
      
      node_description = S("Ventilato A1"),
    	node_help = S("Connect to power 50 EU (LV)"),
      
      output_stack_size = 1,
      input_stack_size = 0,
      have_input = false,
      
      have_control = true,
    })

local ventilator_A1 = cleanroom.ventilator_A1;

ventilator_A1:power_data_register(
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
ventilator_A1:control_data_register(
  {
    ["mesecons_control"] = {
      },
    ["digilines_control"] = {
        cmd_power_on = "POWER ON",
        cmd_power_off = "POWER OFF",
        st_running = "STATUS RUN",
        st_deactivate = "STATUS STOP",
      },
  })

--------------
-- Formspec --
--------------

function ventilator_A1:get_formspec(meta, production_percent, consumption_percent)
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
    sounds = noe_sounds,
    drawtype = "mesh",
    mesh = "cleanroom_ventilator.obj",
  }

local node_inactive = {
    tiles = {
      "default_steel_block.png",
      "cleanroom_ventilator_motor.png",
      "cleanroom_ventilator_shalt.png",
      "cleanroom_ventilator_vane.png",
    },
  }

local node_active = {
    tiles = {
      "default_steel_block.png",
      "cleanroom_ventilator_motor.png",
      {
        image = "cleanroom_ventilator_shalt_active.png",
        backface_culling = true,
        animation = {
          type = "vertical_frames",
          aspect_w = 16,
          aspect_h = 16,
          length = 1.5
        }
      },
      {
        image = "cleanroom_ventilator_vane_active.png",
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

ventilator_A1:register_nodes(node_def, node_inactive, node_active)

-------------------------
-- Recipe Registration --
-------------------------


