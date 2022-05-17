
function cleanroom.get_pressure_meta = function(pos, node, meta)
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
    meta:set_float(key, value)
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

