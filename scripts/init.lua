local mod = {
  id = "steel_grapple",
  name = "Steel Grapple",
  version = "0.0.1",
  requirements = {},
  icon = "img/icon.png",
  rockThrow = true,
  judoBaseRange = 1,
}

--- Options for prime shift, will be set based on config
local judo_shift_options
local gravwellA

--[[--
  Helper function to load mod scripts

  @param  name   Script path relative to mod directory
]]
function mod:loadScript(path)
  return require(self.scriptPath..path)
end

function mod:metadata()
  modApi:addGenerationOption(
    "rockThrow",
    "Rock Throw",
    "If checked, judo mech is allowed to target mountains, throwing a rock instead of a unit",
    { enabled = true }
  )
  modApi:addGenerationOption(
    "judoBaseRange",
    "Base Judo Throw Range",
    "Judo mech's base throw range without upgrades",
    {
      value = 1, -- default
      values = { 1, 2 }
    }
  )
  modApi:addGenerationOption(
    "judoUpgradeA",
    "Judo First Upgrade",
    "Determines the first upgrade for the judo mech.",
    {
      value = "ally", -- default
      values = { "ally", "range", "master" },
      strings = { "Ally Immune (vanilla)", "+1 Range", "Judo Master" }
    }
  )
  modApi:addGenerationOption(
    "judoUpgradeB",
    "Judo Second Upgrade",
    "Determines the second upgrade for the judo mech.",
    {
      value = "damage", -- default
      values = { "damage", "range", "strength" },
      strings = { "+2 Damage (vanilla)", "+2 Range", "Strength" }
    }
  )
  modApi:addGenerationOption(
    "timeDilation",
    "Gravity Time Dilation",
    "If checked, gravity mech can upgrade the gravity well to make an enemy attack last",
    { enabled = true }
  )
  modApi:addGenerationOption(
    "directionalShot",
    "Gravity Directional Upgrade",
    "If checked, gravity mech can upgrade the gravity well to allow pushing instead of just pulling",
    { enabled = true }
  )
end

function mod:init()
  self:loadScript("weaponPreview/api")
  self.modApiExt = self:loadScript("modApiExt/modApiExt")
  self.modApiExt:init()
  -- judo script returns upgrade option tables
  judo_shift_options = self:loadScript("skills/judo")
  -- gravwell script returns default A upgrade, config may overwrite it
  gravwellA = self:loadScript("skills/gravity")

  -- sprites
  local sprites = self:loadScript("libs/sprites")
  sprites.addAnimation("combat/icons", "steel_time_icon",   {PosX = -10, PosY = 22})
  sprites.addAnimation("combat/icons", "steel_notime_icon", {PosX = -10, PosY = 22})
end

function mod:load(options,version)
  self.modApiExt:load(self, options, version)
  self:loadScript("weaponPreview/api"):load()

  -- update from config
  -- rock throw
  self.rockThrow = options.rockThrow.enabled
  local image = self.rockThrow and "Mountain" or "Normal"
  Prime_Shift.TipImage = Prime_Shift.TipImages[image]

  -- judo base range
  self.judoBaseRange = options.judoBaseRange.value

  -- judo mech upgrades
  local upgrades = {
    A = shallow_copy(judo_shift_options.A[options.judoUpgradeA.value]),
    B = shallow_copy(judo_shift_options.B[options.judoUpgradeB.value])
  }
  -- set mountain tips if relevant
  for _, upgrade in pairs(upgrades) do
    if upgrade.TipImages then
      upgrade.TipImage = upgrade.TipImages[image]
    end
  end

  -- create actual upgrades
  -- both A and B may boost range, so add if thats the case
  upgrades.AB = shallow_copy(upgrades.A)
  if upgrades.A.RangeBoost and upgrades.B.RangeBoost then
    upgrades.AB.RangeBoost = upgrades.A.RangeBoost + upgrades.B.RangeBoost
  end
  Prime_Shift_A  = Prime_Shift:new(upgrades.A)
  Prime_Shift_B  = Prime_Shift:new(upgrades.B)
  Prime_Shift_AB = Prime_Shift_B:new(upgrades.AB)

  -- upgrade costs
  if options.judoUpgradeA.value == "master" then
    Prime_Shift.UpgradeCost[1] = 2
  else
    Prime_Shift.UpgradeCost[1] = 1
  end

  -- set texts
  Weapon_Texts.Prime_Shift_Upgrade1 = upgrades.A.UpgradeName
  Weapon_Texts.Prime_Shift_Upgrade2 = upgrades.B.UpgradeName
  Weapon_Texts.Prime_Shift_A_UpgradeDescription = upgrades.A.UpgradeDescription
  Weapon_Texts.Prime_Shift_B_UpgradeDescription = upgrades.B.UpgradeDescription


  --[[ Gravity Mech ]]--

  local gravTime = not options.timeDilation or options.timeDilation.enabled
  local gravDir = not options.directionalShot or options.directionalShot.enabled
  -- if time is enabled, restore upgrade A
  if gravTime then
    Science_Gravwell_A = gravwellA
    Science_Gravwell.UpgradeCost[1] = 1
  -- if directional and not time, replace upgrade A
  elseif gravDir then
    Science_Gravwell_A = Science_Gravwell_B
    Science_Gravwell.UpgradeCost[1] = 2
  end
  -- upgrade count based on how many enabled
  Science_Gravwell.Upgrades = (gravTime and 1 or 0) + (gravDir and 1 or 0)
  -- correct weapon texts
  Weapon_Texts.Science_Gravwell_Upgrade1 = Science_Gravwell_A.UpgradeName
  Weapon_Texts.Science_Gravwell_A_UpgradeDescription = Science_Gravwell_A.UpgradeDescription
end

return mod
