
local S = cleanroom.translator

local vacuum_levels = {
    {
      -- low preasure air
      --preasure_max = 100000,
      preasure_max = 90000,
      preasure_min = 50000,
      drowning = 0,
    },
    {
      -- low vacuum
      --preasure_max = 100000,
      preasure_max = 50000,
      preasure_min = 3000,
      drowning = 1,
    },
    {
      -- medium vacuum
      preasure_max = 3000,
      preasure_min = 0.1,
    },
    {
      -- high vacuum
      preasure_max = 0.1,
      preasure_min = 1e-7,
    },
    {
      -- ultra high vacuum
      preasure_max = 1e-7,
      preasure_min = 1e-10,
    },
    {
      -- extremely high vacuum
      preasure_max = 1e-10,
      preasure_min = 1e-14,
      -- followed by vacuum from vacuum mod?
    },
  }

local function get_preasure(node)
  local def = minetest.registered_nodes[node.name]
  if def then
    if def._preasure_step then
      return def._preasure_min + def._preasure_step*node.param2
    end
    return def._preasure_const
  end
  return nil
end
cleanroom.get_preasure = get_preasure

local function get_preasure_node(preasure)
  local name = "cleanroom:vacuum_preair"
  local param2 = 0
  for _, data in pairs(vacuum_levels) do
    if (preasure<=data.preasure_max) 
        and (preasure>=data.preasure_min) then
      name = data.node_name
      param2 = math.ceil((preasure-data.preasure_min)/data.preasure_step)
      param2 = math.min(param2, 255)
      return name, param2
    end
  end
  return name, param2
end
cleanroom.get_preasure_node = get_preasure_node

local positions = {}
for z = -1,1 do
  for y = -1,1 do
    for x = -1,1 do
      table.insert(positions, vector.new(x, y, z))
    end
  end
end

local function update_vacuum(pos)
  local nodes = {}
  local preasures = {}
  local sum = 0
  local nums = 0
  for i,vect in pairs(positions) do
    nodes[i] = minetest.get_node(vector.add(pos,vect))
    local preasure = get_preasure(nodes[i])
    --print("preasure of node "..nodes[i].name..": "..dump(preasure))
    preasures[i] = preasure
    if preasure then
      sum = sum + preasure
      nums = nums + 1
    end
  end
  for i,vect in pairs(positions) do
    if preasures[i]==nil then
      local asum = 0
      local anums = 0
      for z = math.max(vect.z-1,-1),math.min(vect.z+1,1) do
        for y = math.max(vect.y-1,-1),math.min(vect.y+1,1) do
          for x = math.max(vect.x-1,-1),math.min(vect.x+1,1) do
            local index = z*9+y*3+x+14
            if preasures[index] then
              asum = asum + preasures[index]
              anums = anums + 1
            end
          end
        end
      end
      if anums>0 then
        sum = sum + asum/anums
        nums = nums + 1
      end
    end
  end
  local node_name, node_param2 = get_preasure_node(sum/nums)
  --print("new_node: "..node_name)
  for i,vect in pairs(positions) do
    local node = nodes[i]
    if preasures[i] and minetest.get_item_group(node.name, "vacuum_spreadable")>0 then
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
cleanroom.update_vacuum = update_vacuum

local function on_construct(pos, node)
  minetest.get_node_timer(pos):start(1)
end
local function on_timer(pos, elapsed)
  update_vacuum(pos)
  return false
end

for level, data in pairs(vacuum_levels) do
  data.node_name = "cleanroom:vacuum_l"..level
  data.preasure_step = (data.preasure_max-data.preasure_min)/255
  
  minetest.register_node(data.node_name, {
      description = S("Vacuum"),
      drawtype = "airlike",
      --drawtype = "glasslike",
      --tiles = {"cleanroom_vacuum.png"},
      --use_texture_alpha = "blend",
      paramtype = "light",
      sun_light_propagates = true,
      floodable = true,
      walkable = false,
      diggable = false,
      pointable = false,
      buildable_to = true,
      drop = "",
      groups = {vacuum=1,vacuum_spreadable=1},
      _preasure_max = data.preasure_max,
      _preasure_min = data.preasure_min,
      _preasure_step = data.preasure_step,
      drowning = data.drowning or 2,
      on_construct = on_construct,
      on_timer = on_timer,
    })
end

minetest.register_node("cleanroom:vacuum_preair", {
    description = S("Vacuum Pre-Air"),
    drawtype = "airlike",
    paramtype = "light",
    sun_light_propagates = true,
    floodable = true,
    walkable = false,
    diggable = false,
    pointable = false,
    buildable_to = true,
    drop = "",
    groups = {vacuum_spreadable=1,not_in_creative_inventory=1},
    _preasure_const = 100000,
    on_construct = on_construct,
    on_timer = function(pos, elapsed)
      local np = minetest.find_node_near(pos, 1, "group:vacuum")
      if np then
        update_vacuum(pos)
      else
        minetest.swap_node(pos, {name="air"})
      end
      return false
    end,
  })

