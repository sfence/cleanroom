
function cleanroom.get_pressure_meta(pos, node, meta)
  return tonumber(meta:get("pressure") or cleanroom.normal_air_pressure)
end

function cleanroom.get_dustlevel_particles_meta(pos, node, meta)
  return {
      p100n = meta:get_float("p100n"),
      p200n = meta:get_float("p200n"),
      p300n = meta:get_float("p300n"),
      p500n = meta:get_float("p500n"),
      p1000n = meta:get_float("p1000n"),
      p5000n = meta:get_float("p5000n"),
    }
end

function cleanroom.pressure_update_cleanwall(pos, node, node_new, meta, def, pressure, particles)
  for key,value in pairs(particles) do
    meta:set_float(key, meta:get_float(key)+value)
  end
end

local placedust_level = cleanroom.placedust_level
local particles_sizes = cleanroom.dust_particles_sizes

function cleanroom.get_dustlevel_particles_cleanwall(pos, node, meta, def)
  local particles = {}
  -- part > 0 and part < 1
  local part = def._particles_part
  for _,key in pairs(particles_sizes) do
    local value = tonumber(meta:get(key) or placedust_level[key])
    local released = math.floor(value*part)
    particles[key] = released
    meta:set_float(key, value - released)
  end
  return particles
end

function cleanroom.clean_node(itemstack, user, pointed_thing)
  if pointed_thing.type=="node" then
    local under = minetest.get_node(pointed_thing.under)
    local under_def = minetest.registered_nodes[under.name]
    local above = minetest.get_node(pointed_thing.above)
    local above_def = minetest.registered_nodes[above.name]
    
    if (under_def._pressure_update and above_def.groups and above_def.groups.pressure_spreadable) then
      local under_particles = cleanroom.get_dustlevel(pointed_thing.under, under, true)
      if not under_particles then
        return
      end
      local pressure = cleanroom.get_pressure(pointed_thing.above, above, true)
      local particles = cleanroom.get_dustlevel(pointed_thing.above, above, true)
      if not particles then
        return
      end
    
      local def = itemstack:get_definition()
      local meta = itemstack:get_meta()
      local above_meta = minetest.get_meta(pointed_thing.above)
      local pallete_index = 0
      local cleaning_eff = under_def._cleaning_eff or 1.0
      
      print(dump(under_particles))
      print(dump(particles))
      
      for _,key in pairs(particles_sizes) do
        local item_enough = meta:get_float(key)
        local enough = under_particles[key] or placedust_level[key]
        local eff = math.min((enough/def._eff_coefs[key])^2, 1)*cleaning_eff
        local eff_to_air = math.min((def._eff_coefs[key]/enough), 1)
        local eff_to_node = math.min((item_enough/enough), 1)
        local node_to_item = def._node_to_item_coefs[key]*enough*eff
        local node_to_air = def._node_to_air_coefs[key]*enough*eff
        local item_to_air = def._item_to_air_coefs[key]*item_enough*eff_to_air
        local item_to_node = def._item_to_node_coefs[key]*item_enough*eff_to_node
        
        print(string.format("key: %s, eff: %s\nnode_to_item: %s; node_to_air: %s\nitem_to_air: %s; item_to_node: %s", key, eff, node_to_item, node_to_air, item_to_air, item_to_node))
        
        item_enough = math.max(0, item_enough + node_to_item - item_to_air - item_to_node)
        meta:set_float(key, item_enough)
        pallete_index = pallete_index + def._pallete_coefs[key]*item_enough
        under_particles[key] = math.max(0, enough - node_to_item - node_to_air + item_to_node)
        above_meta:set_float(key, particles[key] + node_to_air + item_to_air)
      end
      print(dump(under_particles))
      under_def._pressure_update(pointed_thing.under, under, under, minetest.get_meta(pointed_thing.under), under_def, nil, under_particles)
      
      meta:set_string("pallete_index", math.min(255, math.floor(pallete_index)))
      
      local node_name, node_param2 = cleanroom.get_pressure_node(pressure)
      if (above.param2~=node_param2) or (above.name~=node_name) then
        above.name = node_name
        above.param2 = node_param2
        minetest.swap_node(pointed_thing.above, above)
        -- should lay out server usage from one moment to time
        local timer = minetest.get_node_timer(pointed_thing.above)
        if not timer:is_started() then
          timer:set(1, 0.5)
        end
      end
      
      return itemstack
    else
      print("Node udner "..under.name.." and above "..above.name.." not cleanable.")
    end
  end
end

function cleanroom.is_pressure_leak(node)
  local def = minetest.registered_nodes[node.name]
  if def then
    if def._pressure_step then
      return false
    end
    if def._pressure_get then
      return false
    end
    if def._pressure_const~=nil then
      if def._pressure_const~=false then
        return true
      end
      return false
    end
    -- pressure avarage or ignore
    if def._pressure_ignore then
      return false
    end
  end
  return true
end

