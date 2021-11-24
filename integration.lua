
minetest.override_item("air", {
    groups = {not_in_creative_inventory=1,pressure_spreadable=1},
    _pressure_const = 100000,
    _particles_const = cleanroom.basedust_level,
  })

if minetest.get_modpath("default") then
  minetest.override_item("default:steelblock", {
      _pressure_const = false,
      _particles_const = false,
    })
  minetest.override_item("default:glass", {
      _pressure_const = false,
      _particles_const = false,
    })
end
