local mod = mod_loader.mods[modApi.currentMod]

-- Alternate weapon: confuse shot
SteelGrappleMech = Pawn:new {
  Name = "Grapple Mech",
	Class = "Prime",
	Health = 3,
	MoveSpeed = 4,
	Image = "steel_grapple_mech",
	ImageOffset = 4,
	SkillList = { "Steel_Grapple_Fist" },
	Armor = true,
	SoundLocation = "/mech/prime/rock_mech/",
	DefaultTeam = TEAM_PLAYER,
	ImpactMaterial = IMPACT_METAL,
	Massive = true
}

-- Create new skill since its pretty different from judo fist
Steel_Grapple_Fist = Skill:new{
	-- basic
	Class = "Prime",
	Icon = "weapons/steel_grapple_fist.png",
	-- upgrades
	PowerCost = 0,
	Upgrades = 2,
	UpgradeCost = {2,2},
	-- overrides
	Damage = 1,
  Range = 1,
	-- display
	LaunchSound = "/weapons/shift",
  TipImages = {
    Rock = {
      Unit          = Point(2,2),
      Enemy         = Point(2,1),
      Target        = Point(2,3),
      Mountain      = Point(1,2),
      Second_Origin = Point(2,2),
      Second_Target = Point(3,2)
    },
    Normal = {
      Unit   = Point(2,2),
      Enemy  = Point(2,1),
      Target = Point(2,3)
    }
  }
}

Steel_Grapple_Fist_A = Steel_Grapple_Fist:new{
  Range = 2,
  TipImages = {
  	Rock = {
  		Unit          = Point(2,2),
  		Enemy         = Point(2,1),
  		Target        = Point(2,4),
  		Mountain      = Point(1,2),
  		Second_Origin = Point(2,2),
  		Second_Target = Point(3,2)
  	},
  	Normal = {
  		Unit   = Point(2,2),
  		Enemy  = Point(2,1),
  		Target = Point(2,4)
  	}
  }
}

Steel_Grapple_Fist_B = Steel_Grapple_Fist:new{
  Damage = 2
}

Steel_Grapple_Fist_AB = Steel_Grapple_Fist_A:new{
  Damage = 2
}

modApi:addWeapon_Texts({
  Steel_Grapple_Fist_Name = "Grapple Fist",
  Steel_Grapple_Fist_Description = "Grab a unit and toss it behind you.",
  Steel_Grapple_Fist_Upgrade1 = "+1 Range",
  Steel_Grapple_Fist_A_UpgradeDescription = "Increases the range of the attack by 1.",
  Steel_Grapple_Fist_Upgrade2 = "+1 Damage",
  Steel_Grapple_Fist_B_UpgradeDescription = "Increases damage by 1."
})

-- target landing or units
function Steel_Grapple_Fist:GetTargetArea(point)
	local ret = PointList()
	for dir = DIR_START, DIR_END do
		local side = DIR_VECTORS[dir]
		local target = point + side
		-- can target non-guarding pawns or mountains
    local pawn = Board:GetPawn(target)
		if (pawn ~= nil and not pawn:IsGuarding()) or (mod.rockThrow and Board:IsTerrain(target, TERRAIN_MOUNTAIN)) then
			-- can land on spaces behind the mech that are open
			local canTarget = false
			for i = 1, self.Range do
				local landing = point - side * i
				if not Board:IsBlocked(landing, PATH_FLYER) then
					ret:push_back(landing)
					canTarget = true
        end
			end
			-- add the pawn as targetable too, adds compat with old behavior
			if canTarget then
				ret:push_back(target)
			end
		end
	end

	return ret
end

-- toss units to landing
function Steel_Grapple_Fist:GetSkillEffect(p1, p2)
	local ret = SkillEffect()
	local dir = GetDirection(p2 - p1)

	-- determine target and landing
	local target
	local landing = p2

	-- if targeting the pawn, throw to first available space
	if Board:IsPawnSpace(p2) or Board:IsTerrain(p2, TERRAIN_MOUNTAIN) then
    target = p2
		local offset = DIR_VECTORS[dir]
		for i = 1, self.Range do
			local point = p1 - offset * i
			if not Board:IsBlocked(point, PATH_FLYER) then
				landing = point
				break
			end
		end
	else
		-- if targeting an empty space, that is where the unit lands, so determine target pawn
		target = p1 - DIR_VECTORS[dir]
	end

	-- mountains throw a rock
	if mod.rockThrow and Board:IsTerrain(target, TERRAIN_MOUNTAIN) then
    -- damage mountain
		ret:AddMelee(p1, SpaceDamage(target, self.Damage))
    -- throw a rock from the mountain
    local rock = SpaceDamage(landing, 0)
    rock.sPawn = "RockThrown"
    ret:AddArtillery(target, rock, "effects/shotdown_rock.png", FULL_DELAY)
		ret:AddBounce(landing, 3)
		ret:AddSound("/impact/dynamic/rock")
	else
		-- fake punch and toss
		ret:AddMelee(p1, SpaceDamage(target, 0))
		-- only add leap if the pawn moves (just in case this is called oddly)
		local damage = self.Damage
		if target ~= landing then
    	local move = PointList()
    	move:push_back(target)
    	move:push_back(landing)
			ret:AddLeap(move, FULL_DELAY)
		end
		-- damage the target after landing
		ret:AddDamage(SpaceDamage(landing, damage))
		ret:AddBounce(landing, 3)
	end

	return ret
end
