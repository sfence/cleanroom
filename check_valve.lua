
local S = cleanroom.translator

local check_valve_get_pressure = function(pos, node, meta)
  --print("check valve -> get_pressure")
  --return nil
  return tonumber(meta:get("pressure") or cleanroom.normal_air_pressure)
end

local placedust_level = cleanroom.placedust_level
local particles_sizes = cleanroom.dust_particles_sizes

local check_valve_update_pressure = function(pos, node_old, node_new, meta, def, pressure, particles)
  meta:set_float("pressure", pressure)
  for _, key in pairs(particles_sizes) do
    meta:set_float(key, particles[key] or placedust_level[key])
  end
  local timer = minetest.get_node_timer(pos)
  if not timer:is_started() then
    timer:set(1, 0.5)
  end
  --print("check valve -> update")
end

local check_valve_on_timer = function(pos, elapsed)
  --print("check valve -> on_timer")
  local node = minetest.get_node(pos)
  local meta = minetest.get_meta(pos)
  local dir = minetest.facedir_to_dir(node.param2%32)
  local in_pos = vector.subtract(pos, dir)
  local out_pos = vector.add(pos, dir)
  local in_node = minetest.get_node(in_pos)
  local out_node = minetest.get_node(out_pos)
  local ret_timer = false
  
  local in_pressure = cleanroom.get_pressure(in_pos, in_node, true)
  if not in_pressure then
    return false
  end
  local out_pressure = cleanroom.get_pressure(out_pos, out_node, true)
  if not out_pressure then
    return false
  end
  --print("pressure in: "..in_pressure.." out: "..out_pressure)
  
  local in_particles = cleanroom.get_dustlevel(in_pos, in_node, true)
  local out_particles = cleanroom.get_dustlevel(out_pos, out_node, true)
  
  local diff = 0
  local in_new_pressure = 0
  local out_new_pressure = 0
  local new_name = "cleanroom:check_valve_close"
  if ((out_pressure+300)<in_pressure) then
    diff = in_pressure - out_pressure - 300
    in_new_pressure = in_pressure - 0.9*diff
    out_new_pressure = out_pressure + 0.9*diff
    new_name = "cleanroom:check_valve_open"
    ret_timer = true
  elseif (out_pressure>(in_pressure+300)) then
    diff = out_pressure - in_pressure - 300
    in_new_pressure = in_pressure + 0.1*diff
    out_new_pressure = out_pressure - 0.1*diff
    ret_timer = true
  else
    diff = in_pressure - out_pressure
    in_new_pressure = in_pressure - 0.25*diff
    out_new_pressure = out_pressure + 0.25*diff
  end
  
  local in_meta = minetest.get_meta(in_pos)
  local out_meta = minetest.get_meta(out_pos)
  
  if in_pressure>in_new_pressure then
    local diff = in_pressure-in_new_pressure
    for _,key in pairs(cleanroom.dust_particles_sizes) do
      local psum = in_particles[key]+out_particles[key]
      local dens = in_particles[key]/in_pressure
      -- 0.005 equvivalent to 0.01*psum/2
      in_particles[key] = 0.9*in_particles[key] + 0.005*psum - dens*diff
      out_particles[key] = 0.9*out_particles[key] + 0.005*psum + dens*diff
    end
  else
    local diff = out_pressure-out_new_pressure
    for _,key in pairs(cleanroom.dust_particles_sizes) do
      local psum = in_particles[key]+out_particles[key]
      local dens = out_particles[key]/out_pressure
      -- 0.005 equvivalent to 0.01*psum/2
      in_particles[key] = 0.9*in_particles[key] + 0.005*psum + dens*diff
      out_particles[key] = 0.9*out_particles[key] + 0.005*psum - dens*diff
    end
  end
  
  cleanroom.pressure_node_update(in_pos, in_node, in_meta, nil, in_new_pressure, in_particles)
  
  cleanroom.pressure_node_update(out_pos, out_node, out_meta, nil, out_new_pressure, out_particles)
  
  if new_name~=node.name then
    node.name = new_name
    minetest.swap_node(pos, node)
  end
  
  return ret_timer
end

minetest.register_node("cleanroom:check_valve_close", {
    description = S("Check Valve"),
    drawtype = "mesh",
    mesh = "cleanroom_check_valve_close.obj",
    tiles = {"cleanroom_steel.png", "icleanroom_check_valve.png"},
    groups = {choppy = 2},
    _pressure_ignore = true,
    _particles_func = cleanroom.get_dustlevel_particles_meta,
    _pressure_update = check_valve_update_pressure,
    on_timer = check_valve_on_timer,
  })

minetest.register_node("cleanroom:check_valve_open", {
    description = S("Check Valve"),
    drawtype = "mesh",
    mesh = "cleanroom_check_valve_open.obj",
    tiles = {"cleanroom_steel.png", "icleanroom_check_valve.png"},
    groups = {choppy = 2, not_in_creative_inventory = 1},
    drop = "cleanroom:check_valve_closed",
    _pressure_ignore = true,
    _particles_func = cleanroom.get_dustlevel_particles_meta,
    _pressure_update = check_valve_update_pressure,
    on_timer = check_valve_on_timer,
  })
