
minetest.register_on_dignode(function(pos, oldnode, digger)
    --[[
    local np = minetest.find_node_near(pos, 1, "group:vacuum")
    if np then
      cleanroom.update_vacuum(pos)
    end
    local np = minetest.find_node_near(pos, 1, "group:dustless")
    if np then
      cleanroom.update_dustless(pos)
    end
    --]]
    local np = minetest.find_node_near(pos, 1, "group:pressure_air")
    if np then
      cleanroom.update_pressure_air(pos)
    end
  end)
