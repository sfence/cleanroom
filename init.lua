
cleanroom = {
  translator = minetest.get_translator("cleanroom")
}

local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)

dofile(modpath.."/functions.lua")

dofile(modpath.."/dustless.lua")
dofile(modpath.."/gasfree.lua")

dofile(modpath.."/dignode.lua")
dofile(modpath.."/leaks.lua")

dofile(modpath.."/integration.lua")

-- appliances
--dofile(modpath.."/pump.lua")
--dofile(modpath.."/filter.lua")

--dofile(modpath.."/nodes.lua")
--dofile(modpath.."/craftitems.lua")
--dofile(modpath.."/crafting.lua")

