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

function Steel_Science_Confwell:Advance(point)
  local target = Board:GetPawn(point)
  local targetId = target:GetId()
  -- remove each pawn but target
  local pawns = Board:GetPawns(TEAM_ENEMY)
  for i = 1, pawns:size() do
    local pawnId = pawns:index(i)
    if pawnId ~= targetId then
      local pawn = Board:GetPawn(pawnId)
      local pawnSpace = pawn:GetSpace()
      Board:RemovePawn(pawn)
      Board:AddPawn(pawn, pawnSpace)
      pawn:SetSpace(pawnSpace)
    end
  end
  -- yellow glow on target
  Board:Ping(point, GL_Color(64, 196, 0))
end

local function skillEffect(self, ret, p1, p2, hide)
  ret:AddBounce(p1, -2)


  -- flip target
  local damage = SpaceDamage(p2, self.Damage, DIR_FLIP)
  damage.sAnimation = "ExploRepulse3"
  damage.bHide = hide

  -- if time, add icon and make target first
  local advance = false
  if self.Time then
    if Board:IsPawnSpace(p2) and Board:IsPawnTeam(p2, TEAM_ENEMY) then
      damage.sImageMark = "combat/icons/steel_time_add_icon.png"
      advance = true
    else
      damage.sImageMark = "combat/icons/steel_no_time_icon.png"
    end
  end
  -- actual artillery
  ret:AddArtillery(damage, "effects/steel_shot_confuse.png")

  -- dilation
  if advance then
    ret:AddScript(string.format("Steel_Science_Confwell:Advance(%s)", p2:GetString()))
  end

  return ret
end

function Steel_Science_Confwell:GetSkillEffect(p1, p2)
  return skillEffect(self, SkillEffect(), p1, p2, false)
end

modApi:addWeapon_Texts({
  Steel_Science_Confwell_Name = "Confuse Well",
  Steel_Science_Confwell_Description = "Artillery weapon that confuses its target.",
  Steel_Science_Confwell_Upgrade1 = "Time Confusion",
  Steel_Science_Confwell_A_UpgradeDescription = "Causes the target to attack first."
})

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
  skillEffect(self, ret, p1, p2, true)
  return ret
end
