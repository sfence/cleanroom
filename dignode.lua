
minetest.register_on_dignode(function(pos, oldnode, digger)
    local np = minetest.find_node_near(pos, 1, "group:pressure_air")
    if np then
      local pressure = cleanroom.get_pressure(pos)
      local node_name, node_param2 = cleanroom.get_pressure_node(pressure)
      minetest.set_node(pos, {name=node_name, param2=node_param2})
      -- apply dust
      local def = minetest.registered_nodes[oldnode.name]
      local dust = cleanroom.digdust_level
      if def and def._particles_dig then
        dust = def._particles_dig
      end
      local meta = minetest.get_meta(pos)
      for _,key in pairs(cleanroom.dust_particles_sizes) do
        meta:set_float(key, dust[key])
      end
    end
  end)

minetest.register_on_placenode(function(pos, node, placer)
    local np = minetest.find_node_near(pos, 1, "group:pressure_air")
    local def = minetest.registered_nodes(node.name)
    if def._pressure_update then
      local pressure
      if np then
        pressure = cleanroom.get_pressure(np)
      else
        pressure = cleanroom.normal_air_pressure
      end
      local node_name, node_param2 = cleanroom.get_pressure_node(pressure)
      local dust = cleanroom.placedust_level
      if def and def._particles_place then
        dust = def._particles_place
      end
      local meta = minetest.get_node_meta(pos)
      def._pressure_update(pos, node, {name=node_name,param2=node_param2}, meta, def, pressure, dust)
      return
    end
    if np then
      -- apply dust
      local def = minetest.registered_nodes[node.name]
      local dust = cleanroom.placedust_level
      if def and def._particles_place then
        dust = def._particles_place
      end
      local meta = minetest.get_meta(pos)
      for _,key in pairs(cleanroom.dust_particles_sizes) do
        meta:set_float(key, meta:get_float(key)+dust[key])
      end
    end
  end)

