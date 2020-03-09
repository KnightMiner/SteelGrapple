local mod = mod_loader.mods[modApi.currentMod]
local cutils = mod:loadScript("libs/cutils")
local previewer = mod:loadScript("weaponPreview/api")

-- override Prime_Shift with changes
Prime_Shift = Skill:new{
  -- basic
	Class = "Prime",
	Icon = "weapons/prime_shift.png",
  -- upgrades
	PowerCost = 0,
	Upgrades = 2,
	UpgradeCost = {2,3},
  -- overrides
	Damage = 1,
	Range = 1,
  FriendlyDamage = true,
	RangeBoost = 0,
  -- display
	LaunchSound = "/weapons/shift",
	TipImages = {
		Mountain = {
			Unit          = Point(2,2),
			Enemy         = Point(2,1),
			Target        = Point(2,1),
			Mountain      = Point(1,2),
			Second_Origin = Point(2,2),
			Second_Target = Point(1,2)
		},
		Normal = {
			Unit   = Point(2,2),
			Enemy  = Point(2,1),
			Target = Point(2,1)
		}
	}
}
Prime_Shift.TipImage = Prime_Shift.TipImage.Mountain

-- Upgrade 1a: ally immune
Prime_Shift_A_Friendly = Prime_Shift:new{
	FriendlyDamage = false,
	TipImage = {
		Unit          = Point(2,2),
		Friendly      = Point(2,1),
		Enemy         = Point(3,2),
		Target        = Point(2,1),
		Second_Origin = Point(2,2),
		Second_Target = Point(1,2),
	}
}
-- Upgrade 1b: ally immune with range
Prime_Shift_A_Master = Prime_Shift:new{
	FriendlyDamage = false,
	Range = 2,
	RangeBoost = 1,
	TipImage = {
		Unit          = Point(2,2),
		Friendly      = Point(2,1),
		Enemy         = Point(3,2),
		Target        = Point(2,1),
		Second_Origin = Point(2,2),
		Second_Target = Point(0,2),
	}
}

-- Upgrade 2a: damage
Prime_Shift_B_Damage = Prime_Shift:new{
	Damage = 3
}
-- Upgrade 2b: range
Prime_Shift_B_Range = Prime_Shift:new{
	Range = 3,
	RangeBoost = 2,
	TipImages = {
		Mountain = {
			Unit          = Point(2,2),
			Enemy         = Point(2,1),
			Target        = Point(2,4),
			Mountain      = Point(1,2),
			Second_Origin = Point(2,2),
			Second_Target = Point(1,2)
		},
		Normal = {
			Unit   = Point(2,2),
			Enemy  = Point(2,1),
			Target = Point(2,4)
		}
	}
}

-- Both upgrades: vanilla
Prime_Shift_AB_Base = Prime_Shift_A_Friendly:new{
	Damage = 3
}
-- both upgrades: master
Prime_Shift_AB_Master = Prime_Shift_A_Master:new{
	Damage = 3
}
-- both upgraes: range
Prime_Shift_AB_Range = Prime_Shift_A_Master:new{
	Range = 3,
	RangeBoost = 2
}
-- both upgrades: both boost
Prime_Shift_AB_Both = Prime_Shift_A_Master:new{
	Damage = 3,
	Range = 2,
	RangeBoost = 1
}

-- default upgrades: judo master
Prime_Shift_A = Prime_Shift_A_Master
Prime_Shift_B = Prime_Shift_B_Damage
Prime_Shift_AB = Prime_Shift_AB_Master

-- targets landing instead of units
function Prime_Shift:GetTargetArea(point)
	local ret = PointList()
	for dir = DIR_START, DIR_END do
    local side = DIR_VECTORS[dir]
    local target = point + side
    -- can target non-guarding pawns or mountains
    if (Board:IsPawnSpace(target) and not Board:GetPawn(target):IsGuarding())
        or mod.rockThrow and Board:GetTerrain(target) == TERRAIN_MOUNTAIN then
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

--[[--
  Spawns in a rock on a mountain, as vanilla does not like spawning units on mountains

  @param  space  Point to place the rock
]]
function Prime_Shift:AddRock(space)
  -- start by removing the mountain
  local mountainHealth = 0
  if Board:GetTerrain(space) == TERRAIN_MOUNTAIN then
    mountainHealth = cutils.GetTileHealth(Board, space)
    Board:SetTerrain(space, TERRAIN_RUBBLE)
  end

  -- spawn in the rock
  local rock = SpaceDamage(space, 0)
  rock.sPawn = "RockThrown"
  Board:DamageSpace(rock)

  -- then add the mountain back if we had one
  if mountainHealth > 0 then
    Board:SetTerrain(space, TERRAIN_MOUNTAIN)
    cutils.SetTileHealth(Board, space, mountainHealth)
  end
end

-- toss units to landing
function Prime_Shift:GetSkillEffect(p1, p2)
	local ret = SkillEffect()
	local dir = GetDirection(p2 - p1)

	-- determine target and landing
	local target
	local landing = p2

	-- if targeting the pawn, throw to first available space
	if Board:IsPawnSpace(p2) or Board:GetTerrain(p2) == TERRAIN_MOUNTAIN then
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
		-- if targeting an empty space, that is where the unit lands
		target = p1 - DIR_VECTORS[dir]
	end

	-- area to toss unit
	local move = PointList()
	move:push_back(target)
	move:push_back(landing)

	-- mountains throw a rock
	if mod.rockThrow and Board:GetTerrain(target) == TERRAIN_MOUNTAIN then
		ret:AddMelee(p1, SpaceDamage(target, self.Damage))
		ret:AddScript(string.format("Prime_Shift:AddRock(%s)", target:GetString()))
		ret:AddLeap(move, FULL_DELAY)
		ret:AddBounce(landing, 3)
		ret:AddSound("/impact/dynamic/rock")

		-- add a fake rock for the preview
		local fakeRock = SpaceDamage(landing, 0)
		fakeRock.sPawn = "RockThrown"
		previewer:AddDamage(fakeRock)
	else
		-- animation punch and toss
		local fake_punch = SpaceDamage(target, 0)
		ret:AddMelee(p1, fake_punch)
		ret:AddLeap(move, FULL_DELAY)

		-- damage the target after landing
		if self.FriendlyDamage or not Board:IsPawnTeam(target, TEAM_PLAYER) then
			ret:AddDamage(SpaceDamage(landing, self.Damage))
		end
		ret:AddBounce(landing, 3)
	end

	return ret
end
