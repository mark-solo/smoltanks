AIController = Object:extend()

function AIController:new()
  self.targetX = TILE_SIZE*10
  self.targetY = TILE_SIZE*5
end

function AIController:input(tank)
  tank:setTurretTo(dirToAngle(self.targetX-tank.x, self.targetY-tank.y))
  local dirAngle = dirToAngle(self.targetX-tank.x, self.targetY-tank.y)-tank.angle
  if dirAngle > math.pi then
    dirAngle = dirAngle - math.pi*2
  end
  if dirAngle < -math.pi then
    dirAngle = dirAngle + math.pi*2
  end
  tank:turn(dirAngle)

  if not self:isCloseToTarget(tank, TILE_SIZE/2) then
    tank:move(1)
  end

  -- if not tank.path or tank.path==nil then
    -- local start = tank.level.map:pointToIndex(tank.level.map:worldToPoint(tank.x, tank.y))
    -- local goal = tank.level.map:pointToIndex(tank.level.map:worldToPoint(self.targetX, self.targetY))
    -- local path = tank.level:aStar(start, goal)
    -- --log('path '..inspect(path))
    -- local sx, sy = tank.level.map:worldToPoint(tank.x, tank.y)
    -- log(math.floor(tank.x)..':'..math.floor(tank.y)..' '..sx..':'..sy..' '..start..' '..math.floor(tank.level:heuristic(start, goal)))
    -- tank.path = path
  -- end

  tank.path = tank.level:aStar(tank.level.map:pointToIndex(tank.level.map:worldToPoint(tank.x, tank.y)), tank.level.map:pointToIndex(tank.level.map:worldToPoint(self.targetX, self.targetY)))
  --log(inspect(tank.path))
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
