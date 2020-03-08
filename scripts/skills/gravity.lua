local mod = mod_loader.mods[modApi.currentMod]
local previewer = mod:loadScript("weaponPreview/api")

Science_Gravwell.Upgrades = 1
Science_Gravwell.UpgradeCost = {1}
Science_Gravwell_A = Science_Gravwell:new()

modApi:addWeapon_Texts({
  Science_Gravwell_Upgrade1 = "Time Dilation",
  Science_Gravwell_A_UpgradeDescription = "Makes the targeted enemy attack last"
})

ANIMS.steel_time_icon = Animation:new{
	Image = "combat/icons/icon_time_glow.png",
	PosX = -10,
	PosY = 22
}

ANIMS.steel_notime_icon = Animation:new{
	Image = "combat/icons/icon_notime_glow.png",
	PosX = -10,
	PosY = 22
}

function Science_Gravwell_A:Dilation(point)
  if Board:IsPawnSpace(point) and Board:IsPawnTeam(point, TEAM_ENEMY) then
    local pawn = Board:GetPawn(point)
    Board:RemovePawn(pawn)
    Board:AddPawn(pawn, point)
  end
end

function Science_Gravwell_A:GetSkillEffect(p1, p2)
  local ret = SkillEffect()
  local dir = GetDirection(p1 - p2)

  -- dilate unit
  -- TODO: animation?
  ret:AddScript(string.format("Science_Gravwell_A:Dilation(%s)", p2:GetString()))
	previewer:AddAnimation(p2, (Board:IsPawnSpace(p2) and Board:IsPawnTeam(p2, TEAM_ENEMY)) and "steel_time_icon" or "steel_notime_icon")

  -- normal gravity well
  ret:AddBounce(p1,-2)
	local damage = SpaceDamage(p2, self.Damage, dir)
	damage.sAnimation = PUSH_ANIMS[dir]
	ret:AddArtillery(damage,"effects/shot_pull_U.png")

  return ret
end
