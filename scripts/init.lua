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
end

function mod:init()
end

function mod:load(options,version)
end

return mod
