
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

-- appliances
--dofile(modpath.."/pump.lua")
--dofile(modpath.."/filter.lua")

dofile(modpath.."/nodes.lua")
--dofile(modpath.."/craftitems.lua")
--dofile(modpath.."/crafting.lua")

