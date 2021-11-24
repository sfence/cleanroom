
local S = cleanroom.translator

local basedust_level = {
    p100n = 100*1000000000,
    p200n = 100*237000000,
    p300n = 100*102000000,
    p500n = 100*35200000,
    p1000n = 100*8320000,
    p5000n = 100*293000,
  }
cleanroom.basedust_level = basedust_level

--[[
  {
    -- class 9
    particles_nm = {
      p100nm = 1000000000,
      p200nm = 237000000,
      p300nm = 102000000,
      p500nm = 35200000,
      p1000nm = 8320000,
      p5000nm = 293000,
    },
  },
  {
    -- class 8
    particles_nm = {
      p100nm = 100000000,
      p200nm = 23700000,
      p300nm = 10200000,
      p500nm = 3520000,
      p1000nm = 832000,
      p5000nm = 29300,
    },
  },
  {
    -- class 7
    particles_nm = {
      p100nm = 10000000,
      p200nm = 2370000,
      p300nm = 1020000,
      p500nm = 352000,
      p1000nm = 83200,
      p5000nm = 2930,
    },
  },
  {
    -- class 6
    particles_nm = {
      p100nm = 1000000,
      p200nm = 237000,
      p300nm = 102000,
      p500nm = 35200,
      p1000nm = 8320,
      p5000nm = 293,
    },
  },
  {
    -- class 5
    particles_nm = {
      p100nm = 100000,
      p200nm = 23700,
      p300nm = 10200,
      p500nm = 3520,
      p1000nm = 832,
      p5000nm = 29,
    },
  },
  {
    -- class 4
    particles_nm = {
      p100nm = 10000,
      p200nm = 2370,
      p300nm = 1020,
      p500nm = 352,
      p1000nm = 83,
      p5000nm = 2,
    },
  },
  {
    -- class 3
    particles_nm = {
      p100nm = 1000,
      p200nm = 237,
      p300nm = 102,
      p500nm = 35,
      p1000nm = 8,
      p5000nm = 0,
    },
  },
  {
    -- class 2
    particles_nm = {
      p100nm = 100,
      p200nm = 24,
      p300nm = 10,
      p500nm = 4,
      p1000nm = 0,
      p5000nm = 0,
    },
  },
  {
    -- class 1
    particles_nm = {
      p100nm = 10,
      p200nm = 2,
      p300nm = 0,
      p500nm = 0,
      p1000nm = 0,
      p5000nm = 0,
    },
  },
--]]

local pressure_levels = {
    ["100M"] = {
      -- high pressure air
      pressure_max = 10000000,
      pressure_min = 1000000,
      drowning = 0,
      damage_per_second = 2,
    },
    ["1M"] = {
      -- high pressure air
      pressure_max = 1000000,
      pressure_min = 500000,
      drowning = 0,
      damage_per_second = 1,
    },
    ["500k"] = {
      -- medium pressure air
      pressure_max = 500000,
      --pressure_min = 100000,
      pressure_min = 110000,
      drowning = 0,
    },
    ["50k"] = {
      -- low pressure air
      --pressure_max = 100000,
      pressure_max = 90000,
      pressure_min = 50000,
      drowning = 0,
    },
    ["3k"] = {
      -- low vacuum
      --pressure_max = 100000,
      pressure_max = 50000,
      pressure_min = 3000,
      drowning = 1,
    },
    ["100m"] = {
      -- medium vacuum
      pressure_max = 3000,
      pressure_min = 0.1,
    },
    ["100n"] = {
      -- high vacuum
      pressure_max = 0.1,
      pressure_min = 1e-7,
    },
    ["100p"] = {
      -- ultra high vacuum
      pressure_max = 1e-7,
      pressure_min = 1e-10,
    },
    ["10f"] = {
      -- extremely high vacuum
      pressure_max = 1e-10,
      pressure_min = 1e-14,
      -- followed by vacuum from vacuum mod?
    },
  }

local particles_sizes = {"p100n","p200n","p300n","p500n","p1000n","p5000n"}

function cleanroom.get_pressure(pos, node, meta)
  local def = minetest.registered_nodes[node.name]
  if def then
    if def._pressure_step then
      return def._pressure_min + def._pressure_step*node.param2
    end
    return def._pressure_const
  end
  return nil
end
local get_pressure = cleanroom.get_pressure
function cleanroom.get_dustlevel(pos, node, meta)
  local def = minetest.registered_nodes[node.name]
  if def then
    if def._particles_func then
      return def._particles_func(pos, node, meta)
    end
    return def._particles_const
  end
  return nil
end
local get_dustlevel = cleanroom.get_dustlevel

local function get_pressure_node(pressure)
  local name = "cleanroom:pressure_preair"
  local param2 = 0
  for _, data in pairs(pressure_levels) do
    if (pressure<=data.pressure_max) 
        and (pressure>=data.pressure_min) then
      name = data.node_name
      param2 = (pressure-data.pressure_min)/data.pressure_step
      --[[if pressure<100000 then
        param2 = math.min(math.ceil(param2), 255)
      else
        param2 = math.min(math.floor(param2), 255)
      end--]]
      param2 = math.min(math.floor(param2+0.5), 255)
      return name, param2
    end
  end
  return name, param2
end
cleanroom.get_pressure_node = get_pressure_node

local positions = {}
for x = -1,1 do
  for y = -1,1 do
    for z = -1,1 do
      table.insert(positions, vector.new(x, y, z))
    end
  end
end

local function update_pressure_air(pos)
  local nodes = {}
  local nodes_pos = {}
  local nodes_meta = {}
  local nodes_pressure = {}
  local nodes_particles = {}
  local max_pressure = 0
  local sum_pressure = 0
  local nums_pressure = 0
  local sum_particles = {0,0,0,0,0,0}
  local nums_particles = 0
  for i,vect in pairs(positions) do
    nodes_pos[i] = vector.add(pos,vect)
    nodes[i] = minetest.get_node(nodes_pos[i])
    nodes_meta[i] = minetest.get_meta(nodes_pos[i])
    local pressure = get_pressure(nodes_pos[i], nodes[i], nodes_meta[i])
    local particles_nm = get_dustlevel(nodes_pos[i], nodes[i], nodes_meta[i])
    --print("dust of node "..nodes[i].name..": "..dump(particles_nm))
    nodes_pressure[i] = pressure
    nodes_particles[i] = particles_nm
    if pressure then
      sum_pressure = sum_pressure + pressure
      nums_pressure = nums_pressure + 1
      if pressure>max_pressure then
        max_pressure = pressure
      end
      --print("num: "..nums_pressure.." sum: "..sum_pressure)
    end
    if particles_nm then
      for index, key in pairs(particles_sizes) do
        sum_particles[index] = sum_particles[index] + particles_nm[key]
      end
      nums_particles = nums_particles + 1
    end
  end
  for i,vect in pairs(positions) do
    if (nodes_pressure[i]==nil) or (nodes_particles[i]==nil) then
      local asum_pressure = 0
      local anums_pressure = 0
      local asum_particles = {0,0,0,0,0,0}
      local anums_particles = 0
      for z = math.max(vect.z-1,-1),math.min(vect.z+1,1) do
        for y = math.max(vect.y-1,-1),math.min(vect.y+1,1) do
          for x = math.max(vect.x-1,-1),math.min(vect.x+1,1) do
            local index = z*9+y*3+x+14
            if (nodes_pressure[i]==nil) and nodes_pressure[index] then
              asum_pressure = asum_pressure + nodes_pressure[index]
              anums_pressure = anums_pressure + 1
            end
            if (nodes_particles[i]==nil) and nodes_particles[index] then
              for k, key in pairs(particles_sizes) do
                asum_particles[k] = asum_particles[k] + nodes_particles[index][key]
              end
              anums_particles = anums_particles + 1
            end
          end
        end
      end
      if anums_pressure>0 then
        sum_pressure = sum_pressure + asum_pressure/anums_pressure
        nums_pressure = nums_pressure + 1
      end
      if anums_particles>0 then
        for key=1,6 do
          sum_particles[key] = sum_particles[key] + asum_particles[key]/anums_particles
        end
        nums_particles = nums_particles + 1
      end
    end
  end
  for key=1,6 do
    sum_particles[key] = sum_particles[key] / nums_particles
  end
  sum_pressure = sum_pressure/nums_pressure
  if sum_pressure>(2*max_pressure) then
    print("Error, skipped. "..dump(pos))
    print(dump(nodes_pressure))
    --print(dump(nodes_particles))
    print("sum: "..sum_pressure)
    print("nums: "..nums_pressure)
    return
  end
  local node_name, node_param2 = get_pressure_node(sum_pressure)
  --print("new_node: "..node_name.." for "..(sum_pressure))
  --[[if node_name=="cleanroom:pressure_preair" then
    print(dump(nodes_pressure))
    print(dump(nodes_particles))
    print("sum: "..sum_pressure)
    print("nums: "..nums_pressure)
  end--]]
  for i = 1,27 do
    local node = nodes[i]
    local meta = nodes_meta[i]
    if nodes_pressure[i] and minetest.get_item_group(node.name, "pressure_spreadable")>0 then
      if (node.param2~=node_param2) or (node.name~=node_name) then
        node.name = node_name
        node.param2 = node_param2
        minetest.swap_node(nodes_pos[i], node)
        -- should lay out server usage from one moment to time
        local timer = minetest.get_node_timer(nodes_pos[i])
        if not timer:is_started() then
          timer:set(1, 0.02*i)
        end
        --timer:stop()
      end
    end
    if nodes_particles[i] and minetest.get_item_group(node.name, "dust_spreadable")>0 then
      for index, key in pairs(particles_sizes) do
        meta:set_int(key, sum_particles[index])
      end
    end
  end
end
cleanroom.update_pressure_air = update_pressure_air

local function on_construct(pos, node)
  minetest.get_node_timer(pos):start(1)
end
local function on_timer(pos, elapsed)
  update_pressure_air(pos)
  return false
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

for level, data in pairs(pressure_levels) do
  data.node_name = "cleanroom:pressure_air_"..level
  data.pressure_step = (data.pressure_max-data.pressure_min)/255
  minetest.register_node(data.node_name, {
      description = S("Pressure air"),
      --drawtype = "airlike",
      drawtype = "glasslike",
      tiles = {"cleanroom_pressure_air.png"},
      use_texture_alpha = "blend",
      paramtype = "light",
      sun_light_propagates = true,
      floodable = true,
      walkable = false,
      diggable = false,
      pointable = false,
      buildable_to = true,
      drop = "",
      groups = {pressure_air=1,pressure_spreadable=1},
      drowning = data.drowning or 2,
      damage_per_second = data.damage_per_second or 0,
      _pressure_max = data.pressure_max,
      _pressure_min = data.pressure_min,
      _pressure_step = data.pressure_step,
      _particles_func = cleanroom.get_dustlevel_particles_meta,
      on_construct = on_construct,
      on_timer = on_timer,
    })
end

minetest.register_node("cleanroom:pressure_preair", {
    description = S("Preasure Pre-Air"),
    drawtype = "airlike",
    paramtype = "light",
    sun_light_propagates = true,
    floodable = true,
    walkable = false,
    diggable = false,
    pointable = false,
    buildable_to = true,
    drop = "",
    groups = {pressure_spreadable=1,not_in_creative_inventory=1},
    _pressure_const = 100000,
    _particles_const = table.copy(basedust_level),
    on_construct = on_construct,
    on_timer = function(pos, elapsed)
      local np = minetest.find_node_near(pos, 1, "group:pressure_air")
      if np then
        update_pressure_air(pos)
      else
        -- use set_node (erase metadata)
        minetest.set_node(pos, {name="air"})
      end
      return false
    end,
  })
