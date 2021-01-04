SteelVortexMech = Pawn:new {
  Name = "Vortex Mech",
  Class = "Ranged",
  Health = 2,
  Image = "steel_vortex_mech",
  ImageOffset = 4,
  MoveSpeed = 3,
  SkillList = { "Steel_Ranged_Vortex" },
  SoundLocation = "/mech/distance/dstrike_mech/",
  DefaultTeam = TEAM_PLAYER,
  ImpactMaterial = IMPACT_METAL,
  Massive = true
}

Steel_Ranged_Vortex = LineArtillery:new{
  Class = "Ranged",
  PowerCost = 1,
  Upgrades = 2,
  UpgradeCost = {2,2},
  Damage = 1,
  BuildingDamage = true,
  -- display
  BounceAmount = 2,
  Icon = "weapons/steel_ranged_vortex.png",
  Sound = "/general/combat/explode_small",
  UpShot = "effects/shotup_dstrike_missile.png",
  LaunchSound = "/weapons/defense_strike",
  ImpactSound = "/impact/generic/explosion",
  ExplosionCenter = "ExploRepulse2",
  OuterAnimation = "explopush1_",
  TipImage = {
    Unit     = Point(2,4),
    Building = Point(2,2),
    Enemy    = Point(2,0),
    Enemy2   = Point(3,2),
    Target   = Point(2,2)
  }
}

--[[--
  Adds damage for a side
  @param ret     Return object
  @paran self    Weapon instance
  @param target  Target space
  @param dir     Attack direction
]]
local function addSideDamage(ret, self, target, dir)
  local damage = SpaceDamage(target, self.Damage, dir)
  damage.sAnimation = self.OuterAnimation..dir
  if not self.BuildingDamage and Board:IsBuilding(target) then
    damage.iDamage = 0
    damage.sAnimation = "airpush_"..dir
  end
  ret:AddDamage(damage)
  ret:AddBounce(target, self.BounceAmount)
end

function Steel_Ranged_Vortex:GetSkillEffect(p1, p2)
  local ret = SkillEffect()

  -- center animation
  ret:AddBounce(p1, 1)
  local damage = SpaceDamage(p2, 0)
  damage.sAnimation = self.ExplosionCenter
  ret:AddArtillery(damage, self.UpShot)

  -- opposite for front back
	local dir = GetDirection(p2 - p1)
  addSideDamage(ret, self, p2 - DIR_VECTORS[dir], dir)
  addSideDamage(ret, self, p2 + DIR_VECTORS[dir] * 2, (dir + 2) % 4)
  -- sides are normal
  local side = (dir + 1) % 4
  addSideDamage(ret, self, p2 + DIR_VECTORS[side], side)
  side = (dir + 3) % 4
  addSideDamage(ret, self, p2 + DIR_VECTORS[side], side)

  return ret
end

Steel_Ranged_Vortex_A = Steel_Ranged_Vortex:new{
  BuildingDamage = false,
  TipImage = {
    Unit      = Point(2,4),
    Building  = Point(2,2),
    Building2 = Point(3,2),
    Enemy     = Point(2,0),
    Target    = Point(2,2)
  }
}

Steel_Ranged_Vortex_B = Steel_Ranged_Vortex:new{
  Damage = 2,
  BounceAmount = 3,
  OuterAnimation = "explopush2_"
}

Steel_Ranged_Vortex_AB = Steel_Ranged_Vortex_A:new{
  Damage = 2,
  BounceAmount = 3,
  OuterAnimation = "explopush2_"
}

modApi:addWeapon_Texts({
  Steel_Ranged_Vortex_Name = "Vortex Artillery",
  Steel_Ranged_Vortex_Description = "Suck enemies towards a tile and shoot others away.",
  Steel_Ranged_Vortex_Upgrade1 = "Buildings Immune",
  Steel_Ranged_Vortex_A_UpgradeDescription = "This attack will no longer damage Grid Buildings.",
  Steel_Ranged_Vortex_Upgrade2 = "+1 Damage",
  Steel_Ranged_Vortex_B_UpgradeDescription = "Increases damage to adjacent tiles by 1."
})
