local mod = mod_loader.mods[modApi.currentMod]
local timeDilation = mod:loadScript("libs/timeDilation")

-- Alternate weapon: confuse shot
SteelConfMech = Pawn:new {
  Name = "Confuse Mech",
  Class = "Science",
  Health = 3,
  Image = "steel_mech_confuse",
  MoveSpeed = 4,
  ImageOffset = 4,
  SkillList = { "Steel_Science_Confwell", "Passive_FriendlyFire" },
  SoundLocation = "/mech/science/pulse_mech/",
  DefaultTeam = TEAM_PLAYER,
  ImpactMaterial = IMPACT_METAL,
  Massive = true
}

Steel_Science_Confwell = LineArtillery:new{
  -- basic
  Class = "Science",
  Icon = "weapons/steel_science_confwell.png",
  ArtilleryStart = 2,
  ArtillerySize = 8,
  -- upgrades
  PowerCost = 0,
  Upgrades = 1,
  UpgradeCost = {1},
  -- overrides
  Damage = 0,
  Time = false,
  -- display
  Sound = "",
  Explosion = "",
  CustomTipImage = "Steel_Science_Confwell_Tip",
  LaunchSound = "/weapons/enhanced_tractor",
  ImpactSound = "/impact/generic/tractor_beam"
}
Steel_Science_Confwell_A = Steel_Science_Confwell:new{
  Time = true
}

modApi:addWeapon_Texts({
  Steel_Science_Confwell_Name = "Confuse Well",
  Steel_Science_Confwell_Description = "Artillery weapon that confuses its target.",
  Steel_Science_Confwell_Upgrade1 = "Time Confusion",
  Steel_Science_Confwell_A_UpgradeDescription = "Makes the targeted enemy attack last."
})

function Steel_Science_Confwell:GetSkillEffect(p1,p2)
  local ret = SkillEffect()
  ret:AddBounce(p1, -2)

  -- dilate target
  if self.Time then
    timeDilation(ret, p2)
  end

  -- flip target
  local damage = SpaceDamage(p2, self.Damage, DIR_FLIP)
  damage.sAnimation = "ExploRepulse3"
  ret:AddArtillery(damage, "effects/steel_shot_confuse.png")

  return ret
end

Steel_Science_Confwell_Tip = Steel_Science_Confwell:new{
  TipImage = {
    Unit = Point(2,3),
    Enemy = Point(2,1),
    Target = Point(2,1),
    CustomEnemy = "Firefly2",
    Length = 4
  }
}

function Steel_Science_Confwell_Tip:GetSkillEffect(p1,p2)
  local ret = SkillEffect()
  ret.piOrigin = Point(2,3)
  local damage = SpaceDamage(0)
  damage.bHide = true
  damage.sScript = "Board:GetPawn(Point(2,1)):FireWeapon(Point(2,2),1)"
  ret:AddDamage(damage)
  ret:AddDelay(1.5)
  ret:AddBounce(p1, -2)
  damage = SpaceDamage(p2, self.Damage, DIR_FLIP)
  damage.bHide = true
  damage.sAnimation = "ExploRepulse3"
  ret:AddArtillery(damage, "effects/steel_shot_confuse.png")
  return ret
end

-- add mech to selection screen
modApi:addModsInitializedHook(function()
  local oldGetStartingSquad = getStartingSquad
  function getStartingSquad(choice, ...)
    -- get vanilla results
    local result = oldGetStartingSquad(choice, ...)
    if not mod.enableConfuseMech then
      return result
    end

    -- if confuse mech is enabled, insert into the results
    -- steel judoku is always in slot 4, but slot 4 may not be Steel Judoku
    if choice == 4 and result[1] == "Steel Judoka" then
      local copy = {}
      for i, v in pairs(result) do
        copy[#copy+1] = v
      end
      copy[#copy+1] = "SteelConfMech"
      return copy
    end

    return result
  end
end)
