Map = Object:extend()

function Map:new(level, map, sizeX, sizeY)
  self.level = level
  self.map = map
  self.size = {}
  self.size.x = sizeX or 20
  self.size.y = sizeY or 10
  --self.background -- cached image

  -- walls
  local walls = {}
  table.insert(walls, self.level.world:newRectangleCollider(0, -TILE_SIZE, self.size.x*TILE_SIZE, TILE_SIZE))
  table.insert(walls, self.level.world:newRectangleCollider(0, self.size.y*TILE_SIZE, self.size.x*TILE_SIZE, TILE_SIZE))
  table.insert(walls, self.level.world:newRectangleCollider(-TILE_SIZE, 0, TILE_SIZE, self.size.y*TILE_SIZE))
  table.insert(walls, self.level.world:newRectangleCollider(self.size.x*TILE_SIZE, 0, TILE_SIZE, self.size.y*TILE_SIZE))
  --box = world:newRectangleCollider(love.graphics.getWidth()/2-50, love.graphics.getHeight()/2-30, 100, 60)
  for _, wall in ipairs(walls) do wall:setType('static') wall:setCollisionClass('Wall') end

  self.spawnPoints = {}

  -- blocks
  for i=1,self.size.x do
    for j=1,self.size.y do
      local num = self:pointToNum(i-1, j-1)
      if (num==1) then
        local block = self.level.world:newRectangleCollider((i-1)*TILE_SIZE, (j-1)*TILE_SIZE, TILE_SIZE, TILE_SIZE)
        block:setType('static')
        block:setCollisionClass('Wall')
      elseif num==11 or num==21 then
        local spawn = self.level.world:newRectangleCollider((i-1)*TILE_SIZE, (j-1)*TILE_SIZE, TILE_SIZE, TILE_SIZE)
        spawn:setType('static')
        spawn:setCollisionClass('Spawn')
        spawn:setSensor(true)
        table.insert(self.spawnPoints, spawn)
      end
    end
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

  for i=1,self.size.x do
    for j=1,self.size.y do
      local num = self:pointToNum(i-1, j-1)
      --if num==1 then love.graphics.setColor(1, 0, 0, 1)
      --else love.graphics.setColor(1, 1, 1, 0.5) end
      local color = colorsToDraw[num]
      love.graphics.setColor(color[1], color[2], color[3])
      love.graphics.rectangle('line', (i-1)*TILE_SIZE, (j-1)*TILE_SIZE, TILE_SIZE, TILE_SIZE)
      love.graphics.print((j-1)*self.size.x+(i-1), (i-1)*TILE_SIZE, (j-1)*TILE_SIZE)
    end
  end
end

function Map:pointToNum(x, y)
  local row = self.map[y+1] or -1
  return row~=-1 and row[x+1] or -1
end

function Map:pointToIndex(x, y)
  return y*self.size.x+x
end

function Map:indexToPoint(index)
  local y = math.floor(index/self.size.x)
  local x = math.fmod(index, self.size.x)
  return x, y
end
