
cleanroom = {
  translator = minetest.get_translator("cleanroom")
}

local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)

dofile(modpath.."/functions.lua")

dofile(modpath.."/pressure_air.lua")

dofile(modpath.."/dignode.lua")
dofile(modpath.."/leaks.lua")

dofile(modpath.."/integration.lua")

-- hand measuring instruments
dofile(modpath.."/instruments.lua")

dofile(modpath.."/check_valve.lua")

-- appliances
--dofile(modpath.."/vacuum_pumps/pump.lua")

dofile(modpath.."/compressors/compressor.lua")
dofile(modpath.."/compressors/compressor_M1.lua")

dofile(modpath.."/air_ventilators/ventilator.lua")
dofile(modpath.."/air_ventilators/ventilator_M1.lua")

--dofile(modpath.."/air_filters/filter.lua")

dofile(modpath.."/nodes.lua")
dofile(modpath.."/craftitems.lua")
--dofile(modpath.."/crafting.lua")

