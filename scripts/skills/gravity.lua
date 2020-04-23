local mod = mod_loader.mods[modApi.currentMod]
local timeDilation = mod:loadScript("libs/timeDilation")

-- update vanilla weapon upgrades
Science_Gravwell.Upgrades = 1
Science_Gravwell.UpgradeCost = {1}

Science_Gravwell_A = Science_Gravwell:new({
  UpgradeName = "Time Dilation",
  UpgradeDescription = "Makes the targeted enemy attack last.",
  Time = true
})

modApi:addWeapon_Texts({
  Science_Gravwell_Upgrade1 = Science_Gravwell_A.UpgradeName,
  Science_Gravwell_A_UpgradeDescription = Science_Gravwell_A.UpgradeDescription
})

function Science_Gravwell_A:GetSkillEffect(p1, p2)
  local ret = SkillEffect()
  ret:AddBounce(p1, -2)

  -- normal gravity well
  local dir = GetDirection(p1 - p2)
  local pullDamage = SpaceDamage(p2, self.Damage, dir)
	pullDamage.sAnimation = PUSH_ANIMS[dir]
  if self.Time then
    pullDamage.sImageMark = timeDilation.getIcon(p2)
  end
	ret:AddArtillery(pullDamage,"effects/shot_pull_U.png")

  -- dilate behind the mech
  if self.Time then
    timeDilation.apply(ret, p2, GL_Color(0, 128, 128))
  end

  return ret
end
