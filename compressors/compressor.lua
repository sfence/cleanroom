
local S = cleanroom.translator;

function cleanroom.compressor_push_air(pos, meta, compress_speed, compress_ratio)
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
  
  -- do a push, no check valve
  if out_pressure>=(in_pressure*compress_ratio) then
    -- no compression posible
    return
  end
  local sum = (in_pressure+out_pressure)
  if sum<1000 then
    compress_ration = compress_ratio/(4-math.log10(sum))
  end
  out_pressure = math.min(in_pressure*compress_ratio, out_pressure+in_pressure*compress_speed)
  local in_new_pressure = sum-out_pressure
  
  --print("compressed pressure: in: "..in_pressure.." out: "..out_pressure)
  
  local in_particles = cleanroom.get_dustlevel(in_pos, in_node)
  local out_particles = cleanroom.get_dustlevel(out_pos, out_node)
  
  local in_meta = minetest.get_meta(in_pos)
  local out_meta = minetest.get_meta(out_pos)
  
  local diff = in_pressure-in_new_pressure
  for _,key in pairs(cleanroom.dust_particles_sizes) do
    local psum = in_particles[key]+out_particles[key]
    local dens = in_particles[key]/in_pressure
    -- 0.005 equvivalent to 0.01*psum/2
    in_particles[key] = 0.9*in_particles[key] + 0.005*psum - dens*diff
    out_particles[key] = 0.9*out_particles[key] + 0.005*psum + dens*diff
  end
  
  cleanroom.pressure_node_update(in_pos, in_node, in_meta, nil, in_new_pressure, in_particles)
  
  cleanroom.pressure_node_update(out_pos, out_node, out_meta, nil, out_pressure, out_particles)
  
end


