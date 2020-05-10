-- update vanilla weapon upgrades
Science_Gravwell.Upgrades = 1
Science_Gravwell.UpgradeCost = {1}

Science_Gravwell_A = Science_Gravwell:new({
  UpgradeName = "Back Dilation",
  UpgradeDescription = "Causes the unit behind the mech to attack last.",
  Time = true,
  TipImage = {
    Unit = Point(2,3),
    Enemy = Point(2,0),
    Enemy2 = Point(2,4),
    Target = Point(2,0)
  }
})

modApi:addWeapon_Texts({
  Science_Gravwell_Upgrade1 = Science_Gravwell_A.UpgradeName,
  Science_Gravwell_A_UpgradeDescription = Science_Gravwell_A.UpgradeDescription
})

function Science_Gravwell_A:GetSkillEffect(p1, p2)
  local ret = SkillEffect()
  ret:AddBounce(p1, -2)

  -- dilate behind the mech
  local dir = GetDirection(p1 - p2)
  if self.Time then
    local target = p1 + DIR_VECTORS[dir]
    local icon = SpaceDamage(target, 0)
    if Board:IsPawnSpace(target) and Board:IsPawnTeam(target, TEAM_ENEMY) then
      icon.sImageMark = "combat/icons/steel_time_sub_icon.png"
      ret:AddScript(string.format([[
        local point = %s
        local pawn = Board:GetPawn(point)
        Board:RemovePawn(pawn)
        Board:AddPawn(pawn, point)
        Board:Ping(point, GL_Color(196, 0, 64))
      ]], target:GetString()))
    else
      icon.sImageMark = "combat/icons/steel_no_time_icon.png"
    end
    ret:AddDamage(icon)
  end

  -- normal gravity well
  local pullDamage = SpaceDamage(p2, self.Damage, dir)
  pullDamage.sAnimation = PUSH_ANIMS[dir]
  ret:AddArtillery(pullDamage,"effects/shot_pull_U.png")

  return ret
end
