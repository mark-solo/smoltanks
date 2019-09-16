AIController = Object:extend()

function AIController:new()
  self.targetX = 10
  self.targetY = 5
end

function AIController:input(tank)
  local player = tank.level:getEntity('player')

  if not tank.path then
    --tank.path = self:getPathTo(tank, (self.targetX+0.5)*TILE_SIZE, (self.targetY+0.5)*TILE_SIZE)
    tank.path = self:getPathTo(tank, player.x, player.y)
    tank.pathIndex = 1
  else
    local currentPoint = tank.path[tank.pathIndex]
    local cx, cy = tank.level.map:indexToPoint(currentPoint)
    local cx = (cx+0.5)*TILE_SIZE
    local cy = (cy+0.5)*TILE_SIZE

    --tank:setTurretTo(dirToAngle(cx-tank.x, cy-tank.y))
    tank:setTurretTo(dirToAngle(player.x-tank.x, player.y-tank.y))
    --tank:shoot()
    local dirAngle = dirToAngle(cx-tank.x, cy-tank.y)-tank.angle
    tank:turn(dirAngle)

    if self:isCloseToTarget(tank, cx, cy, TILE_SIZE) then
      if tank.pathIndex+1 <= #tank.path then
        tank.pathIndex = tank.pathIndex + 1
      else
        tank.path = self:getPathTo(tank, player.x, player.y)
        tank.pathIndex = 1
      end
    else
      tank:move(1)
    end
  end
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

function AIController:isCloseToTarget(tank, tx, ty, distance)
  local distance = distance or TILE_SIZE
  local real_distance = math.sqrt(math.pow(tank.x-tx, 2)+math.pow(tank.y-ty, 2))
  return real_distance < distance
end

function AIController:getPathTo(tank, x, y)
  local start = tank.level.map:pointToIndex(tank.level.map:worldToPoint(tank.x, tank.y))
  local goal = tank.level.map:pointToIndex(tank.level.map:worldToPoint(x, y))
  return tank.level:aStar(start, goal)
end
