AIController = Object:extend()

function AIController:new()
  self.targetX = TILE_SIZE*10
  self.targetY = TILE_SIZE*5
end

function AIController:input(tank)
  tank:setTurretTo(dirToAngle(self.targetX-tank.x, self.targetY-tank.y))
  local dirAngle = dirToAngle(self.targetX-tank.x, self.targetY-tank.y)-tank.angle
  tank:turn(dirAngle)

  if not self:isCloseToTarget(tank, TILE_SIZE/2) then
    tank:move(1)
  end

  tank.path = tank.level:aStar(tank.level.map:pointToIndex(tank.level.map:worldToPoint(tank.x, tank.y)), tank.level.map:pointToIndex(tank.level.map:worldToPoint(self.targetX, self.targetY)))
end

function AIController:draw(tank)
  if tank.path then
    love.graphics.setColor(0, 1, 0)
    for _, point in ipairs(tank.path) do
      local x, y = tank.level.map:indexToPoint(point)
      love.graphics.ellipse('fill', (x+0.5)*TILE_SIZE, (y+0.5)*TILE_SIZE, 5, 5)
    end
  end
end

-- sensors

function AIController:isCloseToTarget(tank, distance)
  local distance = distance or TILE_SIZE
  local real_distance = math.sqrt(math.pow(tank.x-self.targetX, 2), math.pow(tank.y-self.targetY, 2))
  return real_distance < distance
end
