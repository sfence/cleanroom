
local S = cleanroom.translator;

local no_particles = {}

for _,key in pairs(cleanroom.dust_particles_sizes) do
  no_particles[key] = 0
end

local no_filter_def = {
  _flow_resistance = 0,
  _preasure_limit = 1e3,
  
  _particle_catch_eff = table.copy(no_particles),
  _particle_hold_eff = table.copy(no_particles),
  
  get_dustlevels = function(meta)
    return table.copy(no_particles), table.copy(no_particles)
  end,
  set_dustlevels = function(meta, in_dust, out_dust)
  end,
}

function cleanroom.filter_filter_air(pos, meta)
  local node = minetest.get_node(pos)
  local dir = minetest.facedir_to_dir(node.param2%32)
  local in_pos = vector.add(pos, dir)
  local out_pos = vector.subtract(pos, dir)
  local in_node = minetest.get_node(in_pos)
  local out_node = minetest.get_node(out_pos)
  
  local in_pressure = cleanroom.get_pressure(in_pos, in_node, true)
  if not in_pressure then
    return
  end
  local out_pressure = cleanroom.get_pressure(out_pos, out_node, true)
  if not out_pressure then
    return
  end
  
  --print("pos: in: "..dump(in_pos).." out: "..dump(out_pos))
  --print("pressure: in: "..in_pressure.." out: "..out_pressure)
  
  local in_particles = cleanroom.get_dustlevel(in_pos)
  local out_particles = cleanroom.get_dustlevel(out_pos)
  
  local in_meta = minetest.get_meta(in_pos, in_node)
  local out_meta = minetest.get_meta(out_pos, out_node)

  local inv = meta:get_inventory()
  local filter = inv:get_stack("filter", 1)
  local filter_def = filter:get_definition() or no_filter_def
  
  local def = minetest.registered_nodes[node.name]
  
  -- flow part, based on filter flow resistance
  local pressure_diff = math.abs(in_pressure - out_pressure)
  
  if filter_def._filter_ripped then
    if pressure_diff>filter_def._pressure_limit then
      appliances.swap_stack(filter, filter_def._filter_ripped)
      inv:set_stack("fiter", 1, filter)
      filter_def = filter:get_definition() or no_filter_def
    end
  end
  
  local in_filter_particles, out_filter_particles = filter_def.get_dustlevels(filter:get_meta())
  
  local flow_part = 1/(1+math.exp((-pressure_diff+filter_def._flow_resistance+def._flow_resistance)/16384))
  
  pressure_diff = (in_pressure - out_pressure)/2
  local in_new_pressure = in_pressure - presure_diff*flow_part
  local out_new_pressure = out_pressure + pressure_diff*flow_part
  
  if in_pressure>out_pressure then
    local diff = in_pressure-in_new_pressure
    if filter_def._filter_ripped then
      for _,key in pairs(cleanroom.dust_particles_sizes) do
        local dens = in_particles[key]/in_pressure
        local catch_eff = filter_def._particle_catch_eff[key]
        local hold_eff = filter_def._particle_hold_eff[key]
        -- 0.005 equvivalent to 0.01*psum/2
        in_particles[key] = in_particles[key] - dens*diff
        out_particles[key] = out_particles[key] + dens*diff*(1-catch_eff) +  out_filter_particles[key]*(1-hold_eff)*diff/filter_def._pressure_limit
        in_filter_particles[key] = in_filter_particles[key] + dens*diff*catch_eff
        out_filter_particles[key] = out_filter_particles[key] - out_filter_particles[key]*(1-hold_eff)*diff/filter_def._pressure_limit
      end
    else
      for _,key in pairs(cleanroom.dust_particles_sizes) do
        local psum = in_particles[key]+out_particles[key]
        local dens = in_particles[key]/in_pressure
        -- 0.025 equvivalent to 0.05*psum/2
        in_particles[key] = 0.95*in_particles[key] + 0.025*psum - dens*diff
        out_particles[key] = 0.95*out_particles[key] + 0.025*psum + in_filter_particles[key]*(1-hold_eff)*diff/filter_def._pressure_limit + out_filter_particles[key]*(1-hold_eff)*diff/filter_def._pressure_limit + filter_def,_particles_source[key]
        in_filter_particles[key] = in_filter_particles[key] - in_filter_particles[key]*(1-hold_eff)*diff/filter_def._pressure_limit
        out_filter_particles[key] = out_filter_particles[key] - out_filter_particles[key]*(1-hold_eff)*diff/filter_def._pressure_limit
      end
    end
  else
    local diff = out_pressure-out_new_pressure
    if filter_def._filter_ripped then
      for _,key in pairs(cleanroom.dust_particles_sizes) do
        local dens = in_particles[key]/in_pressure
        local catch_eff = filter_def._particle_catch_eff[key]
        local hold_eff = filter_def._particle_hold_eff[key]
        -- 0.005 equvivalent to 0.01*psum/2
        out_particles[key] = out_particles[key] - dens*diff
        in_particles[key] = in_particles[key] + dens*diff*(1-catch_eff) +  in_filter_particles[key]*(1-hold_eff)*diff/filter_def._pressure_limit
        out_filter_particles[key] = out_filter_particles[key] + dens*diff*catch_eff
        in_filter_particles[key] = in_filter_particles[key] - in_filter_particles[key]*(1-hold_eff)*diff/filter_def._pressure_limit
      end
    else
      for _,key in pairs(cleanroom.dust_particles_sizes) do
        local psum = in_particles[key]+out_particles[key]
        local dens = in_particles[key]/in_pressure
        -- 0.025 equvivalent to 0.05*psum/2
        out_particles[key] = 0.95*out_particles[key] + 0.025*psum - dens*diff
        in_particles[key] = 0.95*in_particles[key] + 0.025*psum + in_filter_particles[key]*(1-hold_eff)*diff/filter_def._pressure_limit + out_filter_particles[key]*(1-hold_eff)*diff/filter_def._pressure_limit + filter_def,_particles_source[key]
        out_filter_particles[key] = out_filter_particles[key] - out_filter_particles[key]*(1-hold_eff)*diff/filter_def._pressure_limit
        in_filter_particles[key] = in_filter_particles[key] - in_filter_particles[key]*(1-hold_eff)*diff/filter_def._pressure_limit
      end
    end
  end
  
  cleanroom.pressure_node_update(in_pos, in_node, in_meta, nil, in_new_pressure, in_particles)
  
  cleanroom.pressure_node_update(out_pos, out_node, out_meta, nil, out_new_pressure, out_particles)
  
  filter_def.set_dustlevels(filter:get_meta(), in_filter_particles, out_filter_particles)
end

