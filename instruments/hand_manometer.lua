
local S = cleanroom.translator

minetest.register_tool("cleanroom:hand_manometer", {
    description = S("Hand Manometer"),
    inventory_image = "cleanroom_hand_manometer.png",
    on_use = function(itemstack, user, pointed_thing)
      if not user then
        return
      end
      local player_name = user:get_player_name()
      if player_name~="" then
        local pos = vector.round(user:get_pos())
        local node = minetest.get_node(pos)
        local meta = minetest.get_meta(pos)
        local pressure = cleanroom.get_pressure(pos, node, meta)
        local msg = "Error"
        if pressure then
          if pressure>1000000 then
            msg = ""..(math.floor(pressure/100000+0.5)/10).." MPa"
          elseif pressure>1000 then
            msg = ""..(math.floor(pressure/100+0.5)/10).." kPa"
          elseif pressure>1 then
            msg = ""..(math.floor(pressure*10+0.5)/10).." Pa"
          else
            msg = ""..(math.floor(pressure*1000+0.5)).." mPa"
          end
        end
        minetest.chat_send_player(player_name, msg)
      end
    end,
  })
