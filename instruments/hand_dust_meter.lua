
local S = cleanroom.translator

cleanroom.hand_dust_meter = appliances.tool:new(
    {
      tool_name = "cleanroom:hand_dust_meter",
      
      tool_description = S("Hand Dust Meter"),
    	tool_help = S("Measure Dust."),
    })

local hand_dust_meter = cleanroom.hand_dust_meter;

hand_dust_meter:battery_data_register(
  {
    ["technic_battery"] = {
      },
    ["power_generators_battery"] = {
      },
  })

function hand_dust_meter:cb_do_use(itemstack, _meta, user, _pointed_thing)
  if not user then
    return itemstack
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
  return itemstack
end

hand_dust_meter:register_tool({
    description = S("Hand Dust Meter"),
    inventory_image = "cleanroom_hand_dust_meter.png",
  })
