
local S = cleanroom.translator

local dustless_levels = {
    {
      -- low dust
      particles_nm = {
        [100] = 9*1000000000,
        [200] = 9*237000000,
        [300] = 9*102000000,
        [500] = 9*35200000,
        [1000] = 9*8320000,
        [5000] = 9*293000,
      },
    },
    {
      -- class 9
      particles_nm = {
        [100] = 1000000000,
        [200] = 237000000,
        [300] = 102000000,
        [500] = 35200000,
        [1000] = 8320000,
        [5000] = 293000,
      },
    },
    {
      -- class 8
      particles_nm = {
        [100] = 100000000,
        [200] = 23700000,
        [300] = 10200000,
        [500] = 3520000,
        [1000] = 832000,
        [5000] = 29300,
      },
    },
    {
      -- class 7
      particles_nm = {
        [100] = 10000000,
        [200] = 2370000,
        [300] = 1020000,
        [500] = 352000,
        [1000] = 83200,
        [5000] = 2930,
      },
    },
    {
      -- class 6
      particles_nm = {
        [100] = 1000000,
        [200] = 237000,
        [300] = 102000,
        [500] = 35200,
        [1000] = 8320,
        [5000] = 293,
      },
    },
    {
      -- class 5
      particles_nm = {
        [100] = 100000,
        [200] = 23700,
        [300] = 10200,
        [500] = 3520,
        [1000] = 832,
        [5000] = 29,
      },
    },
    {
      -- class 4
      particles_nm = {
        [100] = 10000,
        [200] = 2370,
        [300] = 1020,
        [500] = 352,
        [1000] = 83,
        [5000] = 2,
      },
    },
    {
      -- class 3
      particles_nm = {
        [100] = 1000,
        [200] = 237,
        [300] = 102,
        [500] = 35,
        [1000] = 8,
        [5000] = 0,
      },
    },
    {
      -- class 2
      particles_nm = {
        [100] = 100,
        [200] = 24,
        [300] = 10,
        [500] = 4,
        [1000] = 0,
        [5000] = 0,
      },
    },
    {
      -- class 1
      particles_nm = {
        [100] = 10,
        [200] = 2,
        [300] = 0,
        [500] = 0,
        [1000] = 0,
        [5000] = 0,
      },
    },
  }

local particles_sizes = {100,200,300,500,1000,5000}

local function get_dustlevel(node, sizes)
  sizes = sizes or particles_sizes
  local def = minetest.registered_nodes[node.name]
  if def then
    if def._particles_nm then
      local particles_nm = {}
      local coef = (0.1+0.9*node.param2/255)
      for _,key in pairs(sizes) do
        particles_nm[key] = def._particles_nm[key] * coef
      end
      return particles_nm
    end
    return def._particles_const
  end
  return nil
end
cleanroom.get_dustlevel = get_dustlevel

local function get_dustlevel_node(particles_nm, sizes)
  sizes = sizes or particles_sizes
  local name = "cleanroom:dustless_preair"
  local param2 = 0
  for _, data in pairs(dustless_levels) do
    local higger = false
    local lower = true
    for _,key in pairs(sizes) do
      local particles = particles_nm[key]
      if  (particles>data.particles_nm[key]) then
        higger = true
        break
      end
      if (particles>=(0.1*data.particles_nm[key])) then
        lower = false
      end
    end
    if higger then
      break
    end
    if not lower then
      name = data.node_name
      param2 = 0
      for _,key in pairs(sizes) do
        local calc = (particles_nm[key]-0.1*data.particles_nm[key])/(0.9*data.particles_nm[key])
        if calc>param2 then
          param2 = calc
        end
      end
      param2 = math.min(math.ceil(param2*255), 255)
      return name, param2
    end
  end
  return name, param2
end
cleanroom.get_dustlevel_node = get_dustlevel_node

local positions = {}
for x = -1,1 do
  for y = -1,1 do
    for z = -1,1 do
      table.insert(positions, vector.new(x, y, z))
    end
  end
end

local function update_dustless(pos, sizes)
  sizes = sizes or particles_sizes
  local nodes = {}
  local dustnodes = {}
  local sum = {}
  local nums = 0
  for i,vect in pairs(positions) do
    nodes[i] = minetest.get_node(vector.add(pos,vect))
    local particles_nm = get_dustlevel(nodes[i])
    --print("dust of node "..nodes[i].name..": "..dump(particles_nm))
    dustnodes[i] = particles_nm
    if particles_nm then
      for _,key in pairs(sizes) do
        sum[key] = (sum[key] or 0) + particles_nm[key]
      end
      nums = nums + 1
    end
  end
  for i,vect in pairs(positions) do
    if dustnodes[i]==nil then
      local asum = {}
      local anums = 0
      for z = math.max(vect.z-1,-1),math.min(vect.z+1,1) do
        for y = math.max(vect.y-1,-1),math.min(vect.y+1,1) do
          for x = math.max(vect.x-1,-1),math.min(vect.x+1,1) do
            local index = z*9+y*3+x+14
            if dustnodes[index] then
              for _,key in pairs(sizes) do
                asum[key] = (asum[key] or 0) + dustnodes[index][key]
              end
              anums = anums + 1
            end
          end
        end
      end
      if anums>0 then
        for _,key in pairs(sizes) do
          sum[key] = sum[key] + asum[key]/anums
        end
        nums = nums + 1
      end
    end
  end
  for _,key in pairs(sizes) do
    sum[key] = sum[key] / nums
  end
  local node_name, node_param2 = get_dustlevel_node(sum)
  --print("new_node: "..node_name.." for "..dump(sum))
  for i,vect in pairs(positions) do
    local node = nodes[i]
    if dustnodes[i] and minetest.get_item_group(node.name, "dust_spreadable")>0 then
      if (node.param2~=node_param2) or (node.name~=node_name) then
        node.name = node_name
        node.param2 = node_param2
        local npos = vector.add(pos, vect)
        minetest.swap_node(npos, node)
        -- should lay out server usage from one moment to time
        minetest.get_node_timer(npos):set(1, 0.02*i)
      end
    end
  end
end
cleanroom.update_dustless = update_dustless

local function on_construct(pos, node)
  minetest.get_node_timer(pos):start(1)
end
local function on_timer(pos, elapsed)
  update_dustless(pos)
  return false
end

for level, data in pairs(dustless_levels) do
  data.node_name = "cleanroom:dustless_air_l"..level
  minetest.register_node(data.node_name, {
      description = S("Dustless air"),
      drawtype = "airlike",
      --drawtype = "glasslike",
      --tiles = {"cleanroom_dustless.png"},
      --use_texture_alpha = "blend",
      paramtype = "light",
      sun_light_propagates = true,
      floodable = true,
      walkable = false,
      diggable = false,
      pointable = false,
      buildable_to = true,
      drop = "",
      groups = {dustless=1,dust_spreadable=1},
      _particles_nm = data.particles_nm,
      on_construct = on_construct,
      on_timer = on_timer,
    })
end

minetest.register_node("cleanroom:dustless_preair", {
    description = S("Dustless Pre-Air"),
    drawtype = "airlike",
    paramtype = "light",
    sun_light_propagates = true,
    floodable = true,
    walkable = false,
    diggable = false,
    pointable = false,
    buildable_to = true,
    drop = "",
    groups = {dust_spreadable=1,not_in_creative_inventory=1},
    _particles_const = {
        [100] = 10*1000000000,
        [200] = 10*237000000,
        [300] = 10*102000000,
        [500] = 10*35200000,
        [1000] = 10*8320000,
        [5000] = 10*293000,
    },
    on_construct = on_construct,
    on_timer = function(pos, elapsed)
      local np = minetest.find_node_near(pos, 1, "group:dustless")
      if np then
        update_dustless(pos)
      else
        minetest.swap_node(pos, {name="air"})
      end
      return false
    end,
  })

