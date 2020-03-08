local mod = {
  id = "steel_grapple",
  name = "Steel Grapple",
  version = "1.0.0",
  requirements = {},
  icon = "img/icon.png",
  rockThrow = true
}

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
    "replaceUpgrade",
    "Judo Range Upgrade",
    "Determines how the judo mech can upgrade range.",
    {
      value = "both", -- default
      values = { "none", "ally", "damage", "both" },
      strings = { "None", "Ally Immune", "Replace Damage", "Boost From Both Upgrades" }
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
  self:loadScript("skills/judo")
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
  for _, weapon in pairs({"Prime_Shift", "Prime_Shift_B"}) do
    _G[weapon].TipImage = _G[weapon].TipImages[image]
  end

  -- judo base range, need to set all options
  local baseRange = options.judoBaseRange.value
  for _, weapon in pairs({
    "Prime_Shift",
    "Prime_Shift_A_Friendly", "Prime_Shift_A_Master",
    "Prime_Shift_B_Damage",   "Prime_Shift_B_Range",
    "Prime_Shift_AB_Base",    "Prime_Shift_AB_Master",
    "Prime_Shift_AB_Range",   "Prime_Shift_AB_Both"
  }) do
    _G[weapon].Range = baseRange + _G[weapon].RangeBoost
  end

  -- judo range upgrade choice
  local replaceUpgrade = options.replaceUpgrade.value
  -- ally means we replace ally immune with judo master
  if replaceUpgrade == "ally" then
    Prime_Shift_A = Prime_Shift_A_Master
    Prime_Shift_AB = Prime_Shift_AB_Master
    Prime_Shift.UpgradeCost[1] = 2
    Weapon_Texts.Prime_Shift_Upgrade1 = "Judo Master"
    Weapon_Texts.Prime_Shift_A_UpgradeDescription = "Deals no damage to allies and boosts throw range by 1."
  else
    Prime_Shift_A = Prime_Shift_A_Friendly
    Prime_Shift.UpgradeCost[1] = 1
    Weapon_Texts.Prime_Shift_Upgrade1 = "Ally Immune"
    Weapon_Texts.Prime_Shift_A_UpgradeDescription = "Deals no damage to allies."
  end

  -- damage means we replace damage with range
  if replaceUpgrade == "damage" then
    Prime_Shift_B = Prime_Shift_B_Range
    Prime_Shift_AB = Prime_Shift_AB_Range
    Weapon_Texts.Prime_Shift_Upgrade2 = "+2 Range"
    Weapon_Texts.Prime_Shift_B_UpgradeDescription = "Increases throw range by 2."
  else
    Prime_Shift_B = Prime_Shift_B_Damage
    Weapon_Texts.Prime_Shift_Upgrade2 = "+2 Damage"
    Weapon_Texts.Prime_Shift_B_UpgradeDescription = "Increases damage by 2."
  end

  -- none is vanilla behavior
  if replaceUpgrade == "none" then
    Prime_Shift_AB = Prime_Shift_AB_Base
  end

  -- both gives a range boost when both are upgraded
  if replaceUpgrade == "both" then
    Prime_Shift_AB = Prime_Shift_AB_Both
    Weapon_Texts.Prime_Shift_Description = "Grab a unit and toss it behind you. Apply both upgrades to increase throw range by 1."
  else
    Weapon_Texts.Prime_Shift_Description = "Grab a unit and toss it behind you."
  end

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
