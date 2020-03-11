local mod = mod_loader.mods[modApi.currentMod]
local previewer = mod:loadScript("weaponPreview/api")

-- update vanilla weapon upgrades
Science_Gravwell.Upgrades = 2
Science_Gravwell.UpgradeCost = {1, 2}

-- store in a variable to swap out with config
local gravwellA = Science_Gravwell:new({
  UpgradeName = "Time Dilation",
  UpgradeDescription = "Makes the targeted enemy attack last.",
  Time = true
})
Science_Gravwell_A = gravwellA

Science_Gravwell_B = Science_Gravwell:new({
  UpgradeName = "Directional",
  UpgradeDescription = "Can push a target by targeting an empty space behind it.",
  Directional = true,
	TipImage = {
		Unit = Point(2,3),
		Enemy = Point(2,1),
		Target = Point(2,0)
	}
})

Science_Gravwell_AB = Science_Gravwell_A:new({
  Time = true,
  Directional = true
})

modApi:addWeapon_Texts({
  Science_Gravwell_Upgrade1 = Science_Gravwell_A.UpgradeName,
  Science_Gravwell_A_UpgradeDescription = Science_Gravwell_A.UpgradeDescription,
  Science_Gravwell_Upgrade2 = Science_Gravwell_B.UpgradeName,
  Science_Gravwell_B_UpgradeDescription = Science_Gravwell_A.UpgradeDescription
})

--[[--
  Actual dilation logic, needs to be done using board logic outside skill effect
  Assumes a pawn exists on the space that is safe to dialate (enemy team)

  @param point  Location of unit
]]
function Science_Gravwell_A:Dilation(point)
  local pawn = Board:GetPawn(point)
  Board:RemovePawn(pawn)
  Board:AddPawn(pawn, point)
end

--[[--
  Dilates a unit, making it attack last

  @param ret    Skill effect to add dilation into
  @param point  Location of unit
]]
local function dialate(ret, point)
  if Board:IsPawnSpace(point) and Board:IsPawnTeam(point, TEAM_ENEMY) then
    ret:AddScript(string.format("Science_Gravwell_A:Dilation(%s)", point:GetString()))
    previewer:AddAnimation(point, "steel_time_icon")
  else
    previewer:AddAnimation(point, "steel_notime_icon")
  end
end

--[[--
  Helper function to find a pawn that is not immobile

  @param point location to check for the pawn
]]
local function isMobile(point)
  return Board:IsPawnSpace(point) and not Board:GetPawn(point):IsGuarding()
end

function Science_Gravwell:GetSkillEffect(p1, p2)
  local ret = SkillEffect()
  ret:AddBounce(p1, -2)

  -- normal gravity well
  local dir = GetDirection(p1 - p2)
  local pullDamage = SpaceDamage(p2, self.Damage, dir)
	pullDamage.sAnimation = PUSH_ANIMS[dir]
  if self.Directional then
    local behind = p2 + DIR_VECTORS[dir]

    -- only suck if there is a pawn, and none at the target
    if behind:Manhattan(p1) > 1 and isMobile(behind) and not isMobile(p2) then
      local reverse = (dir + 2) % 4
      pullDamage = SpaceDamage(behind, self.Damage, reverse)
      pullDamage.sAnimation = PUSH_ANIMS[reverse]
    end
  end

  -- dilate target
  if self.Time then
    dialate(ret, pullDamage.loc)
  end

  -- actual pushing
	ret:AddArtillery(pullDamage,"effects/shot_pull_U.png")

  return ret
end

return gravwellA
