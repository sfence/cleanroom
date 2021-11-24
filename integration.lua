
minetest.override_item("air", {
    _preasure_const = 100000,
    _particles_const = {
        [100] = 10*1000000000,
        [200] = 10*237000000,
        [300] = 10*102000000,
        [500] = 10*35200000,
        [1000] = 10*8320000,
        [5000] = 10*293000,
    },
    groups = {not_in_creative_inventory = 1, vacuum_spreadable = 1, dust_spreadable = 1},
  })

if minetest.get_modpath("default") then
  minetest.override_item("default:steelblock", {
      _preasure_const = false,
    })
  minetest.override_item("default:glass", {
      _preasure_const = false,
    })
end
