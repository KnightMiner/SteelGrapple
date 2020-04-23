local weapons = {
	normal = {
		Prime_Shift = Prime_Shift,
		Prime_Shift_A = Prime_Shift_A,
		Prime_Shift_B = Prime_Shift_B,
		Prime_Shift_AB = Prime_Shift_AB
	},
	rock = {}
}

-- replacement for Prime_Shift with rock throw ability
weapons.rock.Prime_Shift = Prime_Shift:new{
	TipImage = {
		Unit          = Point(2,2),
		Enemy         = Point(2,1),
		Target        = Point(2,3),
		Mountain      = Point(1,2),
		Second_Origin = Point(2,2),
		Second_Target = Point(3,2)
	}
}
weapons.rock.Prime_Shift_A = weapons.rock.Prime_Shift:new{
	FriendlyDamage = false,
	TipImage = {
		Unit = Point(2,2),
		Friendly = Point(2,1),
		Enemy = Point(3,2),
		Target = Point(2,1),
		Second_Origin = Point(2,2),
		Second_Target = Point(3,2),
	}
}
weapons.rock.Prime_Shift_B = weapons.rock.Prime_Shift:new{
	Damage = 3
}
weapons.rock.Prime_Shift_AB = weapons.rock.Prime_Shift_A:new{
	Damage = 3
}
--- add in mountain targeting
function weapons.rock.Prime_Shift:GetTargetArea(point)
	local ret = PointList()
	for i = DIR_START, DIR_END do
		local target = point + DIR_VECTORS[i]
		if not Board:IsBlocked(point - DIR_VECTORS[i], PATH_FLYER)
			and ((Board:IsPawnSpace(target) and not Board:GetPawn(target):IsGuarding())
			  or Board:IsTerrain(target, TERRAIN_MOUNTAIN)) then
			ret:push_back(target)
		end
	end

	return ret
end
--- add in mountain targeting
function weapons.rock.Prime_Shift:GetSkillEffect(p1, p2)
	local ret = SkillEffect()
	local dir = GetDirection(p2 - p1)
	local target = p1-DIR_VECTORS[dir]
	if Board:IsTerrain(p2, TERRAIN_MOUNTAIN) then
		-- punch mountain
		ret:AddMelee(p1, SpaceDamage(p2, self.Damage))
		-- toss rock to target
		local rock = SpaceDamage(target, 0)
		rock.sPawn = "RockThrown"
		ret:AddArtillery(p2, rock, FULL_DELAY)
		ret:AddBounce(target, 3)
		ret:AddSound("/impact/dynamic/rock")
	else
		-- punch for animation
		ret:AddMelee(p1, SpaceDamage(p2, 0))
		-- toss the target
		local move = PointList()
		move:push_back(p2)
		move:push_back(target)
		ret:AddLeap(move, FULL_DELAY)
		-- damage the target
		local damage = SpaceDamage(target,self.Damage)
		if not self.FriendlyDamage and Board:IsPawnTeam(p2,TEAM_PLAYER) then
			damage.iDamage = 0
		end
		ret:AddDamage(damage)
		ret:AddBounce(target, 3)
	end
	return ret
end

return weapons
