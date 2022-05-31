
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

minetest.register_tool("cleanroom:hand_dust_meter", {
    description = S("Hand Dust Meter"),
    inventory_image = "cleanroom_hand_dust_meter.png",
    on_use = function(itemstack, user, pointed_thing)
      if not user then
        return
      end
      local player_name = user:get_player_name()
      if player_name~="" then
        local pos = vector.round(user:get_pos())
        local node = minetest.get_node(pos)
        local meta = minetest.get_meta(pos)
        local dustlevel = cleanroom.get_dustlevel(pos, node, meta)
        print(node.name)
        local msg = "Error"
        if dustlevel then
          local mass =  dustlevel.p5000n*cleanroom.basedust_mass.p5000n
                      + dustlevel.p1000n*cleanroom.basedust_mass.p1000n
                      + 0.75*dustlevel.p500n*cleanroom.basedust_mass.p500n
                      + 0.5*dustlevel.p300n*cleanroom.basedust_mass.p300n
                      + 0.2*dustlevel.p200n*cleanroom.basedust_mass.p200n
                      + 0.05*dustlevel.p100n*cleanroom.basedust_mass.p100n
          if mass<1 then
            msg = ""..(math.floor(mass*1000+0.5)).." ng/m^3"
          else
            msg = ""..(math.floor(mass+0.5)).." ug/m^3"
          end
        end
        minetest.chat_send_player(player_name, msg)
      end
    end,
  })

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
