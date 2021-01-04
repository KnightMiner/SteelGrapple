SteelHarpoonMech = Pawn:new{
  Name = "Harpoon Mech",
	Class = "Brute",
	Image = "steel_harpoon_mech",
	ImageOffset = 4,
	Health = 3,
	MoveSpeed = 3,
	SkillList = { "Steel_Brute_Harpoon" },
	SoundLocation = "/mech/brute/tank/",
	DefaultTeam = TEAM_PLAYER,
	ImpactMaterial = IMPACT_METAL,
	Massive = true
}

-- Harpoon weapon
Steel_Brute_Harpoon = Brute_Grapple:new{
	Icon = "weapons/steel_brute_harpoon.png",
	PowerCost = 1,
	Upgrades = 2,
	UpgradeCost = {1, 2},
  Grapple = "effects/steel_harpoon_grapple",
  -- upgrades
	Damage = 1,
  AllyImmune = false
}
Steel_Brute_Harpoon_A = Steel_Brute_Harpoon:new{
  AllyImmune = true,
  TipImage = {
		Unit = Point(2,2),
		Friendly = Point(2,0),
		Target = Point(2,0),
		Second_Origin = Point(2,2),
		Second_Target = Point(2,4),
		Building = Point(2,4),
	}
}
Steel_Brute_Harpoon_B = Steel_Brute_Harpoon:new{
	Damage = 2
}
Steel_Brute_Harpoon_AB = Steel_Brute_Harpoon_B:new{
  AllyImmune = true
}

function Steel_Brute_Harpoon:GetTargetArea(point)
	local ret = PointList()
	for dir = DIR_START, DIR_END do
		local this_path = {}

    local offset = DIR_VECTORS[dir]
		local target = point + offset

		while not Board:IsBlocked(target, PATH_PROJECTILE) do
			this_path[#this_path+1] = target
			target = target + offset
		end

		if Board:IsValid(target) then
			this_path[#this_path+1] = target
			for i,v in ipairs(this_path) do
				ret:push_back(v)
			end
		end
	end

	return ret
end

function Steel_Brute_Harpoon:GetSkillEffect(p1,p2)
	local ret = SkillEffect()

	-- find target
	local direction = GetDirection(p2 - p1)
  local offset = DIR_VECTORS[direction]
	local target = p1 + offset
	while not Board:IsBlocked(target, PATH_PROJECTILE) do
		target = target + offset
	end
	if not Board:IsValid(target) then
		return ret
	end

	-- harpoon the target
	local damage = SpaceDamage(target)
	damage.bHidePath = true
	ret:AddProjectile(damage, self.Grapple)

	-- if its mobile, move it
  local landing
	if Board:IsPawnSpace(target) and not Board:GetPawn(target):IsGuarding() then
		-- damage the unit where it lands
		landing = p1 + offset
		ret:AddCharge(Board:GetSimplePath(target, landing), FULL_DELAY)
    local damage = self.Damage
    if self.AllyImmune and Board:IsPawnTeam(target, TEAM_PLAYER) then
      damage = 0
    end
		ret:AddDamage(SpaceDamage(landing, damage))
	elseif Board:IsBlocked(target, Pawn:GetPathProf()) then
		-- damage after we move
    landing = target - offset
		ret:AddCharge(Board:GetSimplePath(p1, landing), FULL_DELAY)
		ret:AddDamage(SpaceDamage(target, self.Damage))
	end

  -- push sides of where it lands
  -- if self.Push then
  --   for i = -1, 1, 2 do
  --     local side = (direction + i) % 4
  --     ret:AddDamage(SpaceDamage(landing + DIR_VECTORS[side], 0, side))
  --   end
  -- end

	return ret
end

modApi:addWeapon_Texts({
  Steel_Brute_Harpoon_Name = "Harpoon",
  Steel_Brute_Harpoon_Description = "Use a harpoon to pull the mech towards objects, or units to the mech.",
  Steel_Brute_Harpoon_Upgrade1 = "Ally Immune",
  Steel_Brute_Harpoon_A_UpgradeDescription = "Allies are not damaged by the harpoon",
  Steel_Brute_Harpoon_Upgrade2 = "+1 Damage",
  Steel_Brute_Harpoon_B_UpgradeDescription = "Increases the damage by 1."
})

-- Add trick shot to normal hookshot optionally
-- Brute_Grapple.UpgradeCost = { 1, 2 }
-- Brute_Grapple_B = trickGrapple:new{
--   UpgradeDescription = "Can pull units through other units.",
--   Trick = true,
-- 	TipImage = trickTooltip,
--   Grapple = "effects/shot_grapple"
-- }
-- Brute_Grapple_AB = Brute_Grapple_B:new{
--   ShieldAlly = true
-- }
-- modApi:addWeapon_Texts({
--   Brute_Grapple_Upgrade2 = "Trick Shot",
-- })
