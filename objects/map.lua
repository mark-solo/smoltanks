Map = Object:extend()

function Map:new(level, map, sizeX, sizeY)
  self.level = level
  self.map = map
  self.size = {}
  self.size.x = sizeX or 20
  self.size.y = sizeY or 10
  --self.background -- cached image

  -- walls
  walls = {}
  table.insert(walls, self.level.world:newRectangleCollider(0, -TILE_SIZE, self.size.x*TILE_SIZE, TILE_SIZE))
  table.insert(walls, self.level.world:newRectangleCollider(0, self.size.y*TILE_SIZE, self.size.x*TILE_SIZE, TILE_SIZE))
  table.insert(walls, self.level.world:newRectangleCollider(-TILE_SIZE, 0, TILE_SIZE, self.size.y*TILE_SIZE))
  table.insert(walls, self.level.world:newRectangleCollider(self.size.x*TILE_SIZE, 0, TILE_SIZE, self.size.y*TILE_SIZE))
  --box = world:newRectangleCollider(love.graphics.getWidth()/2-50, love.graphics.getHeight()/2-30, 100, 60)
  for _, wall in ipairs(walls) do wall:setType('static') wall:setCollisionClass('Wall') end

  -- blocks
  for i=1,self.size.x do
    for j=1,self.size.y do
      local num = self:pointToNum(i, j)
      if (num==1) then
        local block = self.level.world:newRectangleCollider((i-1)*TILE_SIZE, (j-1)*TILE_SIZE, TILE_SIZE, TILE_SIZE)
        block:setType('static')
        block:setCollisionClass('Wall')
      end
    end
  end
end

function Map:draw()
  for i=1,self.size.x do
    for j=1,self.size.y do
      local num = self:pointToNum(i, j)
      if num==1 then love.graphics.setColor(1, 0, 0, 1)
      else love.graphics.setColor(1, 1, 1, 0.5) end
      love.graphics.rectangle('line', (i-1)*TILE_SIZE, (j-1)*TILE_SIZE, TILE_SIZE, TILE_SIZE)
      love.graphics.print((j-1)*self.size.x+(i-1), (i-1)*TILE_SIZE, (j-1)*TILE_SIZE)
    end
  end
end

function Map:pointToNum(x, y)
  local row = self.map[y]
  return row[x]
end

function Map:worldToPoint(x, y)

end
