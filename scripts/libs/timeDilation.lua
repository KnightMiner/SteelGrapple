local mod = mod_loader.mods[modApi.currentMod]
local previewer = mod:loadScript("weaponPreview/api")

--[[--
  Dilates a unit, making it attack last

  @param ret    Skill effect to add dilation into
  @param point  Location of unit
]]
return function(ret, point)
  if Board:IsPawnSpace(point) and Board:IsPawnTeam(point, TEAM_ENEMY) then
    ret:AddScript(string.format([[
      local point = %s
      local pawn = Board:GetPawn(point)
      Board:RemovePawn(pawn)
      Board:AddPawn(pawn, point)
    ]], point:GetString()))
    previewer:AddAnimation(point, "steel_time_icon")
  else
    previewer:AddAnimation(point, "steel_notime_icon")
  end
end
