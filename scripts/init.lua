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

--[[--
  Adds a sprite to the game

  @param path      Base sprite path
  @param filename  File to add
]]
function addSprite(path, filename)
  modApi:appendAsset(
    string.format("img/%s/%s.png", path, filename),
    string.format("%simg/%s/%s.png", mod.resourcePath, path, filename)
  )
end

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
end

function mod:init()
  self:loadScript("weaponPreview/api")
  self.modApiExt = self:loadScript("modApiExt/modApiExt")
  self.modApiExt:init()
  judo_shift_options = self:loadScript("skills/judo")
  self:loadScript("skills/gravity")

  addSprite("combat/icons", "icon_time_glow")
  addSprite("combat/icons", "icon_notime_glow")
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

  -- upgrade gravwell upgrade number
  for _, weapon in pairs({"Science_Gravwell", "Science_Gravwell_A"}) do
    if options.timeDilation.enabled then
      _G[weapon].Upgrades = 1
      _G[weapon].UpgradeCost = {1}
    else
      _G[weapon].Upgrades = 0
      _G[weapon].UpgradeCost = {}
    end
  end
end

return mod
