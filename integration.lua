
minetest.override_item("air", {
    groups = {not_in_creative_inventory=1,pressure_spreadable=1},
    _pressure_max = cleanroom.air.pressure_max,
    _pressure_min = cleanroom.air.pressure_min,
    _pressure_step = cleanroom.air.pressure_step,
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
  minetest.override_item("default:goldblock", {
      _pressure_const = false,
      _particles_part = 0.01,
      _particles_func = cleanroom.get_dustlevel_particles_cleanwall,
      _pressure_update = cleanroom.pressure_update_cleanwall,
      _cleaning_eff = 1.0,
    })
end
if minetest.get_modpath("technic") then
  minetest.override_item("technic:lv_cable_plate_1", {
      _pressure_const = false,
      _particles_const = false,
    })
  minetest.override_item("technic:lv_cable_plate_2", {
      _pressure_const = false,
      _particles_const = false,
    })
  minetest.override_item("technic:lv_cable_plate_3", {
      _pressure_const = false,
      _particles_const = false,
    })
  minetest.override_item("technic:lv_cable_plate_6", {
      _pressure_const = false,
      _particles_const = false,
    })
end

