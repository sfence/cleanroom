
local S = cleanroom.translator

minetest.register_tool("cleanroom:hand_particulate_meter", {
    description = S("Hand Particulate Meter"),
    inventory_image = "cleanroom_hand_particulate_meter.png",
  })

minetest.register_tool("cleanroom:hand_leakmeter", {
    description = S("Hand Leakmeter"),
    inventory_image = "cleanroom_hand_leakmeter.png",
    on_use = function(itemstack, user, pointed_thing)
      if not user then
        return
      end
      local player_name = user:get_player_name()
      if player_name~="" then
        local pos
        local node
        local msg = S("No leaks detected here.")
        local leak = false
        if pointed_thing.type=="node" then
          pos = pointed_thing.under
          
          node = minetest.get_node(pos)
          leak = leak or cleanroom.is_pressure_leak(node)
          
          pos = pointed_thing.above
        end
        if not pos then
          pos = vector.round(user:get_pos())
        end
        if not leak then
          for x = -1,1 do
            for y = -1,1 do
              for z = -1,1 do
                node = minetest.get_node(vector.add(pos, vector.new(x, y, z)))
                leak = leak or cleanroom.is_pressure_leak(node)
                if leak then break end
              end
              if leak then break end
            end
            if leak then break end
          end
        end
        if leak then
          msg = S("Leak via node "..node.name.." has been detected near.")
        end
        minetest.chat_send_player(player_name, msg)
      end
    end,
  })
