-- LEAKS
local leaky_nodes = {
  "group:door"
}

if appliances.have_pipeworks then
  table.insert(leaky_nodes, "group:pipe")
  table.insert(leaky_nodes, "group:tube")
end

if appliances.have_technic then
  table.insert(leaky_nodes, "technic:lv_cable")
  table.insert(leaky_nodes, "technic:mv_cable")
  table.insert(leaky_nodes, "technic:hv_cable")
end

minetest.register_abm({
    label = "Vacuum or ustless air leaks",
    nodenames = leaky_nodes,
    interval = 2,
    chance = 2,
    action = function (pos, node)
      --[[if minetest.get_item_group(node.name, "vacuum_leakness")==0 then
        local np = minetest.find_node_near(pos, 1, "group:vacuum")
        if np then
          cleanroom.update_vacuum(pos)
        end
      end
      if minetest.get_item_group(node.name, "dust_leakness")==0 then
        local np = minetest.find_node_near(pos, 1, "group:dustless")
        if np then
          cleanroom.update_dustless(pos)
        end
      end--]]
      if minetest.get_item_group(node.name, "pressure_leakness")==0 then
        local np = minetest.find_node_near(pos, 1, "group:pressure_air")
        if np then
          cleanroom.update_pressure_air(pos)
        end
      end
    end,
  })
