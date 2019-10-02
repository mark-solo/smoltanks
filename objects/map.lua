Map = Object:extend()

function Map:new(map, sizeX, sizeY)
  self.map = map
  self.w = sizeX or 20
  self.h = sizeY or 10
  --self.background -- cached image

  -- walls
  self.walls = {}
  table.insert(self.walls, world:newRectangleCollider(0, -TILE_SIZE, self.w*TILE_SIZE, TILE_SIZE))
  table.insert(self.walls, world:newRectangleCollider(0, self.h*TILE_SIZE, self.w*TILE_SIZE, TILE_SIZE))
  table.insert(self.walls, world:newRectangleCollider(-TILE_SIZE, 0, TILE_SIZE, self.h*TILE_SIZE))
  table.insert(self.walls, world:newRectangleCollider(self.w*TILE_SIZE, 0, TILE_SIZE, self.h*TILE_SIZE))
  --box = world:newRectangleCollider(love.graphics.getWidth()/2-50, love.graphics.getHeight()/2-30, 100, 60)
  for _, wall in ipairs(self.walls) do wall:setType('static') wall:setCollisionClass('Wall') wall:setActive(false) end

  -- blocks, spawnPoints [& flags]
  self.blocks = {}
  self.spawnPoints = {}
  self.flags = {}
  for i=1,self.w do
    for j=1,self.h do
      local num = self:pointToNum(i-1, j-1)
      if (num==1) then
        local block = world:newRectangleCollider((i-1)*TILE_SIZE, (j-1)*TILE_SIZE, TILE_SIZE, TILE_SIZE)
        block:setType('static')
        block:setCollisionClass('Wall')
        block:setActive(false)
        table.insert(self.blocks, block)
      elseif num==11 or num==21 then
        local spawnPoint = SpawnPoint(self.level, i-1, j-1)
        spawnPoint:setActive(false)
        table.insert(self.spawnPoints, spawnPoint)
      end
    end
  end
end

function Map:insert(scene)
  -- if levels current map is not null
  --   eject current map
  -- set current map to new map
  -- insert this map, i.e.:
  --   1. enable all walls, blocks and spawnPoints

  if scene.map~=nil then
    scene.map:eject()
  end

  scene.map = self

  for _, wall in ipairs(self.walls) do wall:setActive(true) end
  for _, block in ipairs(self.blocks) do block:setActive(true) end
  for _, spawnPoint in ipairs(self.spawnPoints) do spawnPoint:setActive(true) end
  for _, flag in ipairs(self.flags) do flag:setActive(true) end

  log("map insert")

  return self
end

function Map:eject()
  -- disable all walls, blocks and spawnPoints

  log("map eject")
end

function Map:update(dt)
  for _, spawnPoint in ipairs(self.spawnPoints) do
    spawnPoint:update(dt)
  end
end

function Map:draw()
  local colorsToDraw = {}
  colorsToDraw[0] = {0, 0, 0}
  colorsToDraw[1] = {1, 1, 1}
  colorsToDraw[10] = {1, 0, 0}
  colorsToDraw[20] = {0, 0, 1}
  colorsToDraw[11] = {1, 1, 0}
  colorsToDraw[21] = {0, 1, 1}

  for i=1,self.w do
    for j=1,self.h do
      local num = self:pointToNum(i-1, j-1)
      --if num==1 then love.graphics.setColor(1, 0, 0, 1)
      --else love.graphics.setColor(1, 1, 1, 0.5) end
      local color = colorsToDraw[num]
      love.graphics.setColor(color[1], color[2], color[3])
      love.graphics.rectangle('line', (i-1)*TILE_SIZE, (j-1)*TILE_SIZE, TILE_SIZE, TILE_SIZE)
      love.graphics.print((j-1)*self.w+(i-1), (i-1)*TILE_SIZE, (j-1)*TILE_SIZE)
    end
  end

  for _, spawnPoint in ipairs(self.spawnPoints) do
    spawnPoint:draw()
  end
end

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
