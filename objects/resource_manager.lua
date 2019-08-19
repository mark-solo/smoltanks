ResourceManager = Object:extend()

function ResourceManager:new()
  log("ResourceManager: init")

  sprites = {}
  self:loadSprites()

  -- level state = {}
end

local function stripFileToName(string)
  local res = string

  while res:find('/')~=nil do
    res = res:sub(res:find('/')+1)
  end

  return res:sub(1, res:find('%.')-1)
end

function ResourceManager:loadSprites()
  local sprite_files = {}
  recursiveEnumerate('resources/images', sprite_files)

  for _, file in ipairs(sprite_files) do
    local name = stripFileToName(file)
    sprites[name] = love.graphics.newImage(file)
    log('loadSprite: '..name..'='..file)
  end
end
