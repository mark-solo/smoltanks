Level = Object:extend()

function Level:new()
  self.level = {}
  self.size = 20

  -- walls
  walls = {}
  table.insert(walls, world:newRectangleCollider(0, -TILE_SIZE, self.size*TILE_SIZE, TILE_SIZE))
  table.insert(walls, world:newRectangleCollider(0, self.size*TILE_SIZE, self.size*TILE_SIZE, TILE_SIZE))
  table.insert(walls, world:newRectangleCollider(-TILE_SIZE, 0, TILE_SIZE, self.size*TILE_SIZE))
    table.insert(walls, world:newRectangleCollider(self.size*TILE_SIZE, 0, TILE_SIZE, self.size*TILE_SIZE))
  --box = world:newRectangleCollider(love.graphics.getWidth()/2-50, love.graphics.getHeight()/2-30, 100, 60)
  for _, wall in ipairs(walls) do wall:setType('static') end
end

function Level:draw()
  for i=1,self.size do
    for j=1,self.size do
      love.graphics.setColor(1, 1, 1, 0.2)
      love.graphics.rectangle('line', (i-1)*TILE_SIZE, (j-1)*TILE_SIZE, TILE_SIZE, TILE_SIZE)
      love.graphics.print((j-1)*self.size+(i-1), (i-1)*TILE_SIZE, (j-1)*TILE_SIZE)
    end
  end
end
