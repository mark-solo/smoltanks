ResourceManager = Object:extend()

function ResourceManager:new()
  log("ResourceManager: init")

  sprites = {}
  self:loadSprites()

  levels = {}
  self:loadLevels()

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

function ResourceManager:loadLevels()
  local sizeX = 20
  local sizeY = 10
  local map = {}

  for i=1,sizeY do
    local row = {}
    for j=1,sizeX do
      local num = math.random()>0.9 and 1 or 0
      table.insert(row, num)
    end
    table.insert(map, row)
  end

  levels['test'] = Level(map, sizeX, sizeY)
end
