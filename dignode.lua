
minetest.register_on_dignode(function(pos, oldnode, digger)
    local np = minetest.find_node_near(pos, 1, "group:pressure_air")
    if np then
      local pressure = cleanroom.get_pressure(pos)
      local node_name, node_param2 = cleanroom.get_pressure_node(pressure)
      minetest.set_node(pos, {name=node_name, param2=node_param2})
      -- apply dust
      local def = minetest.registered_nodes[oldnode.name]
      local dust = cleanroom.digdust_level
      if def and def._ then
        dust = def._particles_dig
      end
      local meta = minetest.get_meta(pos)
      for _,key in pairs(cleanroom.dust_particles_sizes) do
        meta:set_float(key, dust[key])
      end
    end
  end)
