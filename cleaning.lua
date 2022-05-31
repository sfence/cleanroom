
local S = cleanroom.translator

minetest.register_craftitem("cleanroom:cotton_towel", {
    description = S("Cotton Towel"),
    inventory_image = "cleanroom_cotton_towel.png",
    palette = "cleanroom_towel_pallete.png",
    stack_max = 1,
    
    _eff_coefs = {
      p100n = 100*1000000000,
      p200n = 100*237000000,
      p300n = 100*102000000,
      p500n = 100*35200000,
      p1000n = 100*8320000,
      p5000n = 100*293000,
    },
    _node_to_item_coefs = {
      p100n = 0.001,
      p200n = 0.01,
      p300n = 0.05,
      p500n = 0.1,
      p1000n = 0.2,
      p5000n = 0.5,
    },
    _node_to_air_coefs = {
      p100n = 0.01,
      p200n = 0.05,
      p300n = 0.1,
      p500n = 0.2,
      p1000n = 0.15,
      p5000n = 0.1,
    },
    _item_to_air_coefs = {
      p100n = 0.00075,
      p200n = 0.0075,
      p300n = 0.037,
      p500n = 0.075,
      p1000n = 0.15,
      p5000n = 0.37,
    },
    _item_to_node_coefs = {
      p100n = 0.0005,
      p200n = 0.005,
      p300n = 0.025,
      p500n = 0.05,
      p1000n = 0.1,
      p5000n = 0.25,
    },
    _pallete_coefs = {
      p100n = 10e-20,
      p200n = 50e-20,
      p300n = 100e-20,
      p500n = 200e-20,
      p1000n = 800e-20,
      p5000n = 5000e-20,
    },
    
    on_use = cleanroom.clean_node,
    
  })
