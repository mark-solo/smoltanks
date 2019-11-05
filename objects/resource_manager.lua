ResourceManager = Object:extend()

function ResourceManager:new()
  log("ResourceManager: init")

  sprites = {}
  self:loadSprites()

  maps = {}
  self:loadLevels()

  inputConfigs = {}
  self:loadControls()
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
  function test(r, g, b)
    if (r==0 and g==0 and b==0) then return 1 end
    if (r==1 and g==1 and b==1) then return 0 end

    if (r==1 and g==0 and b==0) then return 10 end
    if (r==1 and g==1 and b==0) then return 11 end

    if (r==0 and g==0 and b==1) then return 20 end
    if (r==0 and g==1 and b==1) then return 21 end
  end

  local level_files = {}
  recursiveEnumerate('resources/levels', level_files)

  for _, file in ipairs(level_files) do
    local name = stripFileToName(file)
    local imageData = love.image.newImageData(file)

    local sizeX = imageData:getWidth()
    local sizeY = imageData:getHeight()
    local map = {}

    for i=1,sizeY do
      local row = {}
      for j=1,sizeX do
        local r, g, b = imageData:getPixel(j-1, i-1)
        local num = test(r, g, b)

        table.insert(row, num)
      end
      table.insert(map, row)
    end

    --levels[name] = Level(map, sizeX, sizeY)
    maps[name] = Map(map, sizeX, sizeY)
  end
end

function ResourceManager:loadControls()
  local filePath = 'resources/controlsPresets.json'
  local contents, size = love.filesystem.read(filePath)

  if contents == nil then
    local defaultInput = Input()
    defaultInput:bind('up', 'forward')
  	defaultInput:bind('down', 'back')
  	defaultInput:bind('left', 'left')
  	defaultInput:bind('right', 'right')
  	defaultInput:bind('w', 'dup')
  	defaultInput:bind('s', 'ddown')

    input = defaultInput
  else
    local json = json.decode(contents)
    for name, preset in pairs(json) do
      local newInput = Input()
      for action, button in pairs(preset) do
        newInput:bind(button, action)
      end

      --inputConfigs[name] = newInput
      --inputConfigs[#inputConfigs] = newInput
      table.insert(inputConfigs, {name=name, preset=newInput})
    end

    input = inputConfigs[#inputConfigs]
  end


end
