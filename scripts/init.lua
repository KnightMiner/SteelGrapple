local mod = {
  id = "steel_grapple",
  name = "Steel Grapple",
  version = "1.1.0",
  requirements = {},
  icon = "img/icon.png",
  rockThrow = true,
  judoBaseRange = 1,
  enableConfuseMech = true
}

--- Options for prime shift, will be set based on config
local judoShifts

--[[--
  Helper function to load mod scripts

  @param  name   Script path relative to mod directory
]]
function mod:loadScript(path)
  return require(self.scriptPath..path)
end

--[[--
  Fixes skill names in pawns

  @param name  Weapon name to fix
]]
function fixWeaponTexts(name)
  -- get name and description
  local base = _G[name]
  base.Name = Weapon_Texts[name .. "_Name"]
  base.Description = Weapon_Texts[name .. "_Description"]
  -- upgrade A description
  for _, key in ipairs({"_A", "_B"}) do
    local fullName = name .. key
    local upgrade = _G[fullName]
    if upgrade ~= nil then
      upgrade.UpgradeDescription =  Weapon_Texts[fullName .. "_UpgradeDescription"]
    end
  end
end

function mod:metadata()
  modApi:addGenerationOption(
    "judoRockThrow",
    "Judo Rock Throw",
    "If checked, judo mech is allowed to target mountains, throwing a rock instead of a unit",
    { enabled = true }
  )
  modApi:addGenerationOption(
    "grappleRockThrow",
    "Grapple Rock Throw",
    "If checked, grapple mech is allowed to target mountains, throwing a rock instead of a unit",
    { enabled = true }
  )
  modApi:addGenerationOption(
    "timeDilation",
    "Gravity Time Dilation",
    "If checked, gravity mech can upgrade the gravity well to make an enemy attack last",
    { enabled = true }
  )
end

function mod:init()
  -- sprites
  local sprites = self:loadScript("libs/sprites")
  sprites.addSprite("weapons", "steel_grapple_fist")
  sprites.addSprite("weapons", "steel_brute_harpoon")
  sprites.addSprite("weapons", "steel_ranged_vortex")
  sprites.addSprite("weapons", "steel_science_confwell")
  sprites.addSprite("effects", "steel_shot_confuse")
  sprites.addSprite("effects", "steel_harpoon_grapple_R")
  sprites.addSprite("effects", "steel_harpoon_grapple_U")
  sprites.addIcon("combat/icons", "steel_time_add_icon", Point(-10,22))
  sprites.addIcon("combat/icons", "steel_time_sub_icon", Point(-10,22))
  sprites.addIcon("combat/icons", "steel_no_time_icon", Point(-10,22))
  sprites.addMechs(
    {
      Name = "steel_grapple_mech",
      Default         = { PosX = -17, PosY = -2 },
      Animated        = { PosX = -17, PosY = -2, NumFrames = 4 },
      Submerged       = { PosX = -17, PosY =  8 },
      Broken          = { PosX = -17, PosY = -2 },
      SubmergedBroken = { PosX = -14, PosY =  6 },
      Icon            = {},
    },
    {
      Name = "steel_harpoon_mech",
      Default         = { PosX = -16, PosY =  8 },
      Animated        = { PosX = -16, PosY =  8, NumFrames = 3 },
      Submerged       = { PosX = -16, PosY = 12 },
      Broken          = { PosX = -16, PosY =  8 },
      SubmergedBroken = { PosX = -16, PosY = 12 },
      Icon            = {},
    },
    {
      Name = "steel_vortex_mech",
      Default         = { PosX = -18, PosY = -5 },
      Animated        = { PosX = -18, PosY = -5, NumFrames = 4 },
      Submerged       = { PosX = -18, PosY =  8 },
      Broken          = { PosX = -18, PosY = -5 },
      SubmergedBroken = { PosX = -18, PosY =  8 },
      Icon            = {},
    },
    {
      Name = "steel_mech_confuse",
      Default         = { PosX = -20, PosY = -1 },
      Animated        = { PosX = -20, PosY = -1, NumFrames = 4 },
      Submerged       = { PosX = -22, PosY =  8 },
      Broken          = { PosX = -20, PosY =  1 },
      SubmergedBroken = { PosX = -19, PosY = 10 },
      Icon            = {},
    }
  )

  -- squad weapons
  self:loadScript("skills/grapple")
  self:loadScript("skills/harpoon")
  self:loadScript("skills/vortex")
  self:loadScript("skills/confuse")
  -- judoka tweaks
  judoShifts = self:loadScript("skills/judo")
  self:loadScript("skills/gravity")

  -- add weapons to the shop
  -- fix the weapon texts for relevant weapons
  for _, id in ipairs({"Steel_Grapple_Fist", "Steel_Brute_Harpoon", "Steel_Ranged_Vortex", "Steel_Science_Confwell"}) do
    modApi:addWeaponDrop(id)
    fixWeaponTexts(id)
  end
end

function mod:load(options,version)
  local squad = { "Steel Grapple", "SteelHarpoonMech", "SteelVortexMech", "SteelConfMech" }
  modApi:addSquad(
    squad,
    "Steel Grapple",
    "These mechs behave similarly to Steel Judoka, providing an alternative flavor to the classic squad.",
    self.resourcePath.."img/icon.png"
  )
  table.insert(squad, "SteelGrappleMech")

  --[[ Grapple Mech ]]--
  -- grapple rock throw just needs to update tooltips
  self.rockThrow = not options.grappleRockThrow or options.grappleRockThrow.enabled
  local key = self.rockThrow and "Rock" or "Normal"
  Steel_Grapple_Fist.TipImage = Steel_Grapple_Fist.TipImages[key]
  Steel_Grapple_Fist_A.TipImage = Steel_Grapple_Fist_A.TipImages[key]

  --[[ Judo Mech ]]--
  -- rock throw, swaps for the version with rock throws if present
  local judoRock = not options.judoRockThrow or options.judoRockThrow.enabled
  for id, weapon in pairs(judoShifts[judoRock and "rock" or "normal"]) do
    _G[id] = weapon
  end

  --[[ Gravity Mech ]]--
  -- if time is enabled, enable upgrade A
  local gravTime = not options.timeDilation or options.timeDilation.enabled
  Science_Gravwell.Upgrades = gravTime and 1 or 0
end

return mod
