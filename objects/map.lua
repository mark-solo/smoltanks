Map = Object:extend()

function Map:new(map, sizeX, sizeY, texture)
  self.map = map
  self.w = sizeX
  self.h = sizeY

  local sw, sh = sprites['tiles']:getDimensions()
  local airQuad = love.graphics.newQuad(0, 0, sh, sh, sw, sh)
  local wallQuad = love.graphics.newQuad(sh, 0, sh, sh, sw, sh)
  self.background = love.graphics.newSpriteBatch(sprites['tiles'])
  for i=1, self.w do
    for j=1, self.h do
      local num = self:pointToNum(i-1, j-1)
      local x, y = (i-1)*TILE_SIZE, (j-1)*TILE_SIZE
      --local sx, sy = n/TILE_SIZE, n/TILE_SIZE;
      if num == 0 then
        self.background:add(airQuad, x, y)
      elseif num == 1 then
        self.background:add(wallQuad, x, y)
      end
    end
  end

  -- walls
  self.walls = {}
  table.insert(self.walls, world:newRectangleCollider(0, -TILE_SIZE, self.w*TILE_SIZE, TILE_SIZE))
  table.insert(self.walls, world:newRectangleCollider(0, self.h*TILE_SIZE, self.w*TILE_SIZE, TILE_SIZE))
  table.insert(self.walls, world:newRectangleCollider(-TILE_SIZE, 0, TILE_SIZE, self.h*TILE_SIZE))
  table.insert(self.walls, world:newRectangleCollider(self.w*TILE_SIZE, 0, TILE_SIZE, self.h*TILE_SIZE))
  --box = world:newRectangleCollider(love.graphics.getWidth()/2-50, love.graphics.getHeight()/2-30, 100, 60)
  for _, wall in ipairs(self.walls) do wall:setType('static') wall:setCollisionClass('Wall') wall:setActive(false) end
  self.wallsLayer = love.graphics.newSpriteBatch(sprites['tiles'])
  for i=1, self.w+1 do
    self.wallsLayer:add(wallQuad, -TILE_SIZE, (i-2)*TILE_SIZE)
    self.wallsLayer:add(wallQuad, self.w*TILE_SIZE, (i-1)*TILE_SIZE)
  end
  for i=1, self.h+1 do
    self.wallsLayer:add(wallQuad, (i-1)*TILE_SIZE, -TILE_SIZE)
    self.wallsLayer:add(wallQuad, (i-2)*TILE_SIZE, self.h*TILE_SIZE)
  end

  -- blocks, spawnPoints [& flags]
  self.blocks = {}
  self.spawnPoints = {}
  self.redSpawns = {}
  self.blueSpawns = {}
  self.flags = {}
  self.redFlags = {}
  self.blueFlags = {}
  for i=1,self.w do
    for j=1,self.h do
      local num = self:pointToNum(i-1, j-1)
      if (num==1) then
        local block = world:newRectangleCollider((i-1)*TILE_SIZE, (j-1)*TILE_SIZE, TILE_SIZE, TILE_SIZE)
        block:setType('static')
        block:setCollisionClass('Wall')
        block:setActive(false)
        table.insert(self.blocks, block)
      elseif num==10 or num==20 then
        local flag = Flag(self, i-1, j-1, num==10 and 'red' or 'blue')
        flag:setActive(false)
        table.insert(self.flags, flag)
        if num == 10 then table.insert(self.redFlags, flag) end
        if num == 20 then table.insert(self.blueFlags, flag) end
      elseif num==11 or num==21 then
        local spawnPoint = SpawnPoint(self, i-1, j-1, num==11 and 'red' or 'blue')
        spawnPoint:setActive(false)
        table.insert(self.spawnPoints, spawnPoint)
        if num == 11 then table.insert(self.redSpawns, spawnPoint) end
        if num == 21 then table.insert(self.blueSpawns, spawnPoint) end
      end
    end
  end
end

function Map:insert(scene)
  if scene.map~=nil then
    scene.map:eject()
  end

  scene.map = self

  for _, wall in ipairs(self.walls) do wall:setActive(true) end
  for _, block in ipairs(self.blocks) do block:setActive(true) end
  for _, spawnPoint in ipairs(self.spawnPoints) do spawnPoint:setActive(true) end
  for _, flag in ipairs(self.flags) do  flag:reset() end

  log("map insert")

  return self
end

function Map:eject()
  for _, wall in ipairs(self.walls) do wall:setActive(false) end
  for _, block in ipairs(self.blocks) do block:setActive(false) end
  for _, spawnPoint in ipairs(self.spawnPoints) do spawnPoint:setActive(false) end
  for _, flag in ipairs(self.flags) do flag:setActive(false) end

  log("map eject")
end

function Map:update(dt)
  for _, spawnPoint in ipairs(self.spawnPoints) do
    spawnPoint:update(dt)
  end
end

function Map:draw()
  love.graphics.setColor(1, 1, 1)
  love.graphics.draw(self.background)
  love.graphics.draw(self.wallsLayer)

  for _, spawnPoint in ipairs(self.flags) do
    spawnPoint:draw()
  end
end

function Map:drawPreview(x, y, w, h)
  love.graphics.setColor(1, 1, 1)
  local realw, realh = self.w*TILE_SIZE, self.h*TILE_SIZE
  local sw, sh = w/realw, h/realh

  love.graphics.draw(self.background, x, y, 0, sw, sh)
end

--

function Map:pointToNum(x, y)
  local row = self.map[y+1] or -1
  return row~=-1 and row[x+1] or -1
end

function Map:pointToIndex(x, y)
  return y*self.w+x
end

function Map:indexToPoint(index)
  local y = math.floor(index/self.w)
  local x = math.fmod(index, self.w)
  return x, y
end

--

function Map:isWalkable(x, y)
  local num = self:pointToNum(x, y)
  return num==0
end

function Map:getSpawnpoint(spawnpoints)
  for _, spawnPoint in ipairs(spawnpoints) do
    if not spawnPoint:isBusy() then
      return spawnPoint
    end
  end

  return nil
end
