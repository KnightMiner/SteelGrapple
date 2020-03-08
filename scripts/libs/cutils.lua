
local mod = mod_loader.mods[modApi.currentMod]
local path = mod.scriptPath .."libs/utils.dll"

local old = package.loaded["itb_c_utilities"]

package.loaded["itb_c_utilities"] = nil
itb_c_utilities = nil

assert(package.loadlib(path, "luaopen_utils"), "cannot find C-Utils dll")()
local ret = itb_c_utilities

package.loaded["itb_c_utilities"] = old
itb_c_utilities = old

return ret
