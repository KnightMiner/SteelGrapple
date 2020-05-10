SteelCycloneMech = Pawn:new {
  Name = "Cyclone Mech",
  Class = "Ranged",
  Health = 2,
  Image = "steel_cyclone_mech",
  ImageOffset = 4,
  MoveSpeed = 3,
  SkillList = { "Steel_Ranged_Cyclone" },
  SoundLocation = "/mech/distance/dstrike_mech/",
  DefaultTeam = TEAM_PLAYER,
  ImpactMaterial = IMPACT_METAL,
  Massive = true
}

Steel_Ranged_Cyclone = LineArtillery:new{
  Class = "Ranged",
  PowerCost = 1,
  Upgrades = 2,
  UpgradeCost = {2,2},
  Damage = 1,
  BuildingDamage = true,
  -- display
  BounceAmount = 2,
  Icon = "weapons/steel_ranged_cyclone.png",
  Sound = "/general/combat/explode_small",
  UpShot = "effects/shotup_dstrike_missile.png",
  LaunchSound = "/weapons/defense_strike",
  ImpactSound = "/impact/generic/explosion",
  ExplosionCenter = "ExploRepulse2",
  OuterAnimation = "explopush1_",
  TipImage = {
    Unit = Point(2,4),
    Building = Point(2,2),
    Enemy = Point(2,1),
    Enemy2 = Point(3,2),
    Target = Point(2,2)
  }
}

function Steel_Ranged_Cyclone:GetSkillEffect(p1, p2)
  local ret = SkillEffect()

  -- center animation
  ret:AddBounce(p1, 1)
  local damage = SpaceDamage(p2, 0)
  damage.sAnimation = self.ExplosionCenter
  ret:AddArtillery(damage, self.UpShot)

  -- pushes on outside
  for dir = 0, 3 do
    local target = p2 + DIR_VECTORS[(dir+1)%4]
    damage = SpaceDamage(target, self.Damage, dir)
    damage.sAnimation = self.OuterAnimation..dir
    -- buildings safe
    if not self.BuildingDamage and Board:IsBuilding(target) then
      damage.iDamage = 0
      damage.sAnimation = "airpush_"..dir
    end
    ret:AddDamage(damage)
    ret:AddBounce(target, self.BounceAmount)
  end

  return ret
end

Steel_Ranged_Cyclone_A = Steel_Ranged_Cyclone:new{
  BuildingDamage = false,
  TipImage = {
    Unit = Point(2,4),
    Building = Point(2,2),
    Building2 = Point(3,2),
    Enemy3 = Point(2,1),
    Target = Point(2,2)
  }
}

Steel_Ranged_Cyclone_B = Steel_Ranged_Cyclone:new{
  Damage = 2,
  BounceAmount = 3,
  OuterAnimation = "explopush2_"
}

Steel_Ranged_Cyclone_AB = Steel_Ranged_Cyclone_A:new{
  Damage = 2,
  BounceAmount = 3,
  OuterAnimation = "explopush2_"
}

modApi:addWeapon_Texts({
  Steel_Ranged_Cyclone_Name = "Cyclone Artillery",
  Steel_Ranged_Cyclone_Description = "Protect a tile with a cyclone of missiles.",
  Steel_Ranged_Cyclone_Upgrade1 = "Buildings Immune",
  Steel_Ranged_Cyclone_A_UpgradeDescription = "This attack will no longer damage Grid Buildings.",
  Steel_Ranged_Cyclone_Upgrade2 = "+1 Damage",
  Steel_Ranged_Cyclone_B_UpgradeDescription = "Increases damage to adjacent tiles by 1."
})
