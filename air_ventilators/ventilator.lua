
local S = cleanroom.translator;

function cleanroom.ventilator_push_air(pos, meta, pressure_diff)
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
  
  -- do a push, no check valve
  local sum = (in_pressure+out_pressure)
  pressure_diff = pressure_diff*sum
  if sum<1000 then
    pressure_diff = pressure_diff/(4-math.log10(sum))
  end
  local in_new_pressure = (sum-pressure_diff)/2
  local out_new_pressure = (sum+pressure_diff)/2
  
  --print("pushed pressure: in: "..in_pressure.." out: "..out_pressure)
  
  local in_meta = minetest.get_meta(in_pos, in_node)
  local out_meta = minetest.get_meta(out_pos, out_node)
  
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
end


