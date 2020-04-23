local mod = mod_loader.mods[modApi.currentMod]

local timeDilation = {}

--[[--
  Checks if a unit can be dilated

  @param point  Point to check
  @return true if the point can be dilated
]]
local function canApply(point)
  return Board:IsPawnSpace(point) and Board:IsPawnTeam(point, TEAM_ENEMY)
end

--[[--
  Dilates a unit, making it attack last

  @param ret    Skill effect to add dilation into
  @param point  Location of unit
  @param color  Effect color
]]
function timeDilation.apply(ret, point, color)
  if canApply(point) then
    ret:AddScript(string.format([[
      local point = %s
      local pawn = Board:GetPawn(point)
      Board:RemovePawn(pawn)
      Board:AddPawn(pawn, point)
      Board:Ping(point, %s)
    ]], point:GetString(), color:GetString()))
  end
end

--[[--
  Gets the icon for display at a point
  @param point  Point to check
  @return  Icon name
]]
function timeDilation.getIcon(point)
  return canApply(point) and "combat/icons/steel_time_icon.png" or "combat/icons/steel_notime_icon.png"
end

return timeDilation
