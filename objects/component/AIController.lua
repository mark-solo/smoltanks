AIController = Object:extend()

local player

function AIController:new()
  self.targetX = 10
  self.targetY = 5
end

function AIController:init(tank)
  local player = tank.level:getEntity('player')

  self:requestPath(tank, player.x, player.y)
end

function AIController:input(tank)
  player = tank.level:getEntity('player')

  if player.collider:isActive() then
    if not tank.path or tank.path==nil then
      tank.path = self:requestPath(tank, player.x, player.y)
    else
      self:moveAlongPath(tank)
      --self:moveTo(tank, player.x, player.y)
      self:courseCorrent(tank)
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

  local angle = math.pi/4
  local distance = TILE_SIZE/2
  local tx1, ty1 = tank.x, tank.y
  local txL, tyL = tank.x+distance*math.cos(tank.angle-angle), tank.y+distance*math.sin(tank.angle-angle)
  local txL2, tyL2 = tank.x+2*distance*math.cos(tank.angle-angle/2), tank.y+2*distance*math.sin(tank.angle-angle/2)
  local txC, tyC = tank.x+distance*math.cos(tank.angle), tank.y+distance*math.sin(tank.angle)
  local txR, tyR = tank.x+distance*math.cos(tank.angle+angle), tank.y+distance*math.sin(tank.angle+angle)
  local txR2, tyR2 = tank.x+2*distance*math.cos(tank.angle+angle/2), tank.y+2*distance*math.sin(tank.angle+angle/2)

  if self:isTouching(tank, -angle, distance) then love.graphics.setColor(1, 1, 1)
  else love.graphics.setColor(1, 1, 1, 0.5) end
  love.graphics.line(tx1, ty1, txL, tyL)

  if self:isTouching(tank, -angle/2, distance*2) then love.graphics.setColor(1, 1, 1)
  else love.graphics.setColor(1, 1, 1, 0.5) end
  love.graphics.line(tx1, ty1, txL2, tyL2)

  if self:isTouching(tank, 0, distance) then love.graphics.setColor(1, 1, 1)
  else love.graphics.setColor(1, 1, 1, 0.5) end
  love.graphics.line(tx1, ty1, txC, tyC)

  if self:isTouching(tank, angle, distance) then love.graphics.setColor(1, 1, 1)
  else love.graphics.setColor(1, 1, 1, 0.5) end
  love.graphics.line(tx1, ty1, txR, tyR)

  if self:isTouching(tank, angle/2, distance*2) then love.graphics.setColor(1, 1, 1)
  else love.graphics.setColor(1, 1, 1, 0.5) end
  love.graphics.line(tx1, ty1, txR2, tyR2)

  if self:doSeeCollider(tank, player.collider) then
    love.graphics.setColor(1, 0, 0)
    love.graphics.ellipse('fill', tank.x, tank.y, tank.h/2, tank.h/2)
  end
end

---- AI parts

-- sensors

function AIController:isCloseToTarget(tank, tx, ty, distance)
  local distance = distance or TILE_SIZE
  local real_distance = math.sqrt(math.pow(tank.x-tx, 2)+math.pow(tank.y-ty, 2))
  return real_distance < distance
end

function AIController:isTouching(tank, angle, distance)
  local tx1, ty1 = tank.x, tank.y
  local tx2, ty2 = tank.x+distance*math.cos(tank.angle+angle), tank.y+distance*math.sin(tank.angle+angle)
  local cols = world:queryLine(tx1, ty1, tx2, ty2, {'All', except={'Spawn'}})
  return #cols > 0
end

function AIController:doSeeCollider(tank, collider)
  local tx1, ty1 = tank.x, tank.y
  local tx2, ty2 = collider:getPosition()

  local cols = world:queryLine(tx1, ty1, tx2, ty2, {'All'})
  return not (#cols>1)
end

function AIController:doSee(tank, targetX, targetY)
  local cols = world:queryLine(tank.x, tank.y, targetX, targetY, {'All'})
  return not (#cols > 0)
end

-- actions

function AIController:requestPath(tank, x, y)
  local start = tank.level.map:pointToIndex(worldToPoint(tank.x, tank.y))
  local goal = tank.level.map:pointToIndex(worldToPoint(x, y))
  tank.pathIndex = 1
  return Pathfinding.getPath(tank, tank.level.map, start, goal)
end

function AIController:moveAlongPath(tank)
  local currentPoint = tank.path[tank.pathIndex]
  if currentPoint==nil then self:requestPath(tank, player.x, player.y) return end
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
      --log("path ended")
      self:requestPath(tank, player.x, player.y)
    end
  else
    tank:move(1)
  end
end

function AIController:moveTo(tank, targetX, targetY)
  tank:setTurretTo(dirToAngle(targetX-tank.x, targetY-tank.y))
  local dirAngle = dirToAngle(targetX-tank.x, targetY-tank.y)-tank.angle
  tank:turn(dirAngle)

  if not self:isCloseToTarget(tank, targetX, targetY, TILE_SIZE) then
    tank:move(1)
  end
end

function AIController:courseCorrent(tank)
  local angle = math.pi/4
  local distance = TILE_SIZE/2

  local d = 1

  if self:isTouching(tank, 0, distance) then tank:turn(d) tank.ds = 0 end
  if self:isTouching(tank, -angle, distance) then tank:turn(d) end
  if self:isTouching(tank, angle, distance) then tank:turn(-d) end

  if self:isTouching(tank, -angle/2, distance*2) then tank:turn(d) end
  if self:isTouching(tank, angle/2, distance*2) then tank:turn(-d) end
end
