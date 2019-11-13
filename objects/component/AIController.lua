AIController = Object:extend()

function AIController:new()
end

function AIController:init(tank)
  tank.targetMoveTo = nil
  tank.targetShootAt = nil

  tank.circleSensor = AIController.makeCircleSensor(10, {'Tank'}, TILE_SIZE*2)
  tank.lineSensors = {}
  table.insert(tank.lineSensors, {sensor=AIController.makeLineSensor(4, {'All'}, -math.pi/4, TILE_SIZE*0.5), correction={ 0.5, -0.1}}) -- this is horrible
  table.insert(tank.lineSensors, {sensor=AIController.makeLineSensor(4, {'All'},  math.pi/4, TILE_SIZE*0.5), correction={-0.5, -0.1}})
  table.insert(tank.lineSensors, {sensor=AIController.makeLineSensor(3, {'All'}, -math.pi/8, TILE_SIZE*0.6), correction={ 1.1, -1.5}})
  table.insert(tank.lineSensors, {sensor=AIController.makeLineSensor(3, {'All'},  math.pi/8, TILE_SIZE*0.6), correction={-1.2, -1.5}})
  table.insert(tank.lineSensors, {sensor=AIController.makeLineSensor(2, {'All'},          0, TILE_SIZE*0.6), correction={ 0.4, -1.5}})
  tank.staySensor = AIController.makeStaySensor(120)

  tank.myTeam = find(tank.level.blueTeam, tank) == nil and tank.level.redTeam or tank.level.blueTeam
end

function AIController:reset(tank)
  tank.targetMoveTo = nil
  tank.targetShootAt = nil
  tank.path = nil

  tank.circleSensor.reset()
  for _, sensor in ipairs(tank.lineSensors) do
    sensor.sensor.reset()
  end
  tank.staySensor.reset()
end

function AIController:input(tank)
  -- sense

  tank.circleSensor.update(tank)
  for _, sensor in ipairs(tank.lineSensors) do
    sensor.sensor.update(tank)
  end
  tank.staySensor.update(tank)

  -- act
  if tank.targetMoveTo == nil then
    tank.targetMoveTo = AIController.getTargetMoveTo(tank)
  else

    if not tank.path or tank.path == nil then
      tank.path = self:requestPath(tank, tank.targetMoveTo.x, tank.targetMoveTo.y)
    else
      self:courseCorrent(tank)
      self:unstuckIfStuck(tank)
      self:moveAlongPath(tank)

      if tank.targetMoveTo == nil or self:isCloseToTarget(tank, tank.targetMoveTo.x, tank.targetMoveTo.x, TILE_SIZE) then
        tank.targetMoveTo = AIController.getTargetMoveTo(tank)
        if tank.targetMoveTo ~= nil then
          tank.path = self:requestPath(tank, tank.targetMoveTo.x, tank.targetMoveTo.y)
        end
      end
    end
  end

  tank.lastCellIndex = currentIndex
end

function AIController:draw(tank)
  if tank.path then
    love.graphics.setColor(0, 1, 0, 0.5)
    for i=1,#tank.path-1 do
      local x1, y1 = tank.level.map:indexToPoint(tank.path[i])
      local x2, y2 = tank.level.map:indexToPoint(tank.path[i+1])

      love.graphics.line((x1+0.5)*TILE_SIZE, (y1+0.5)*TILE_SIZE,
                         (x2+0.5)*TILE_SIZE, (y2+0.5)*TILE_SIZE)
    end

    for _, point in ipairs(tank.path) do
      local x, y = tank.level.map:indexToPoint(point)
      love.graphics.ellipse('fill', (x+0.5)*TILE_SIZE, (y+0.5)*TILE_SIZE, 5, 5)
    end
  end

  love.graphics.setColor(1, 1, 1)
  love.graphics.print(#tank.circleSensor.result-1, tank.x, tank.y-TILE_SIZE)
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

----------

function AIController.getTargetMoveTo(tank)
  local target = AIController.getEnemyFlag(tank)
  if target ~= nil then return target end

  target = AIController.getEnemy(tank)
  if target ~= nil then return target end

  local target = AIController.getFriendlyFlag(tank)
  if target ~= nil then return target end

  target = AIController.getRandomPoint(tank)
  return target
end

function AIController.getTargetShootAt1(tank)
  local target = AIController.seeFlag(tank)
  if target ~= nil then return target end

  target = AIController.seeEnemy(tank)
  return target
end

-----

function AIController.getEnemyFlag(tank)
  local flagsToChooseFrom = tank.myTeam == tank.level.redTeam and
                              tank.level.map.blueFlags or
                              tank.level.map.redFlags

  if #flagsToChooseFrom == 0 then return nil end

  local indexOfFlag = math.random(#flagsToChooseFrom)
  return flagsToChooseFrom[indexOfFlag]
end

function AIController.getEnemy(tank)
  if tank.sensor == nil then return nil end

  local aroundMe = tank.sensor.circleSensor.result
  local enemiesAroundMe = {}

  for _, collider in ipairs(aroundMe) do
    if find(tank.myTeam, collider:getObject()) ~= -1 then
      table.insert(enemiesAroundMe, collider:getObject())
    end
  end

  local indexOfEnemy = math.random(#enemiesAroundMe)
  return enemiesAroundMe[indexOfEnemy]
end

function AIController.getFriendlyFlag(tank)
  local flagsToChooseFrom = tank.myTeam == tank.level.redTeam and
                              tank.level.map.redFlags or
                              tank.level.map.blueFlags

  if #flagsToChooseFrom == 0 then return nil end

  local indexOfFlag = math.random(#flagsToChooseFrom)
  local aBitOf = {}
  aBitOf.x = flagsToChooseFrom[indexOfFlag].x + math.random(-3, 3)*TILE_SIZE
  aBitOf.y = flagsToChooseFrom[indexOfFlag].y + math.random(-3, 3)*TILE_SIZE

  return aBitOf
end

function AIController.getRandomPoint(tank)
  local aBitOf = {}
  aBitOf.x = tank.x + math.random(-3, 3)*TILE_SIZE
  aBitOf.y = tank.y + math.random(-3, 3)*TILE_SIZE

  return aBitOf
end

function AIController.seeFlag(tank)

end

function AIController.seeEnemy(tank)
  -- body...
end

----------

function AIController.makeBasicSensor(refreshRate, collisionClasses)
  local sensor = {}
  sensor.refreshRate = refreshRate or 60
  sensor.refreshTimer = 0
  sensor.collisionClasses = collisionClasses or {'All'}
  sensor.result = {}

  sensor.update = function(tank)
    sensor.refreshTimer = sensor.refreshTimer + 1
    if sensor.refreshTimer > sensor.refreshRate then
      sensor.check(tank)
      sensor.refreshTimer = 0
    end
  end

  sensor.check = function(tank)
    sensor.result = {}
  end

  sensor.reset = function()
    sensor.refreshTimer = 0
    sensor.result = {}
  end

  return sensor
end

function AIController.makeStaySensor(refreshRate)
  local sensor = AIController.makeBasicSensor(refreshRate)
  sensor.lastCellIndex = nil

  sensor.check = function(tank)
    local currentIndex = tank.level.map:pointToIndex(worldToPoint(tank.x, tank.y))
    sensor.result = currentIndex == sensor.lastCellIndex
    sensor.lastCellIndex = currentIndex
  end

  sensor.reset = function()
    sensor.refreshTimer = 0
    sensor.result = false
    sensor.lastCellIndex = nil
  end

  return sensor
end

function AIController.makeCircleSensor(refreshRate, collisionClasses, radius)
  local sensor = AIController.makeBasicSensor(refreshRate, collisionClasses)
  sensor.radius = radius or TILE_SIZE

  sensor.check = function(tank)
    sensor.result = world:queryCircleArea(tank.x, tank.y, sensor.radius, sensor.collisionClasses)
  end

  return sensor
end

function AIController.makeLineSensor(refreshRate, collisionClasses, angle, length)
  local sensor = AIController.makeBasicSensor(refreshRate, collisionClasses)
  sensor.angle = angle or 0
  sensor.length = length

  sensor.check = function(tank)
    local tx = tank.x + sensor.length*math.cos(tank.angle+sensor.angle)
    local ty = tank.y + sensor.length*math.sin(tank.angle+sensor.angle)
    sensor.result = world:queryLine(tank.x, tank.y, tx, ty, sensor.collisionClasses)
  end

  return sensor
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
  if currentPoint==nil then
    log("path ended", "warning")
    tank.targetMoveTo = nil
    return
  end

  local cx, cy = tank.level.map:indexToPoint(currentPoint)
  local cx = (cx+0.5)*TILE_SIZE
  local cy = (cy+0.5)*TILE_SIZE

  --tank:setTurretTo(dirToAngle(cx-tank.x, cy-tank.y))
  --tank:setTurretTo(dirToAngle(player.x-tank.x, player.y-tank.y))
  --tank:shoot()
  local dirAngle = dirToAngle(cx-tank.x, cy-tank.y)-tank.angle
  tank:turn(dirAngle)

  if self:isCloseToTarget(tank, cx, cy, TILE_SIZE/2) then
    if tank.pathIndex+1 <= #tank.path then
      tank.pathIndex = tank.pathIndex + 1
    else
      log("path ended", "warning")
      tank.targetMoveTo = nil
      return
      --self:requestPath(tank, tank.targetMoveTo.x, tank.targetMoveTo.y)
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
  for _, sensor in ipairs(tank.lineSensors) do
    if #sensor.sensor.result>0 then
      local turnAngle, moveSpeed = sensor.correction[1], sensor.correction[2]
      tank:turn(turnAngle)
      tank:move(moveSpeed)
    end
  end
end

function AIController:unstuckIfStuck(tank)
  -- if not self:isCloseToTarget(tank, tank.targetMoveTo.x, tank.targetMoveTo.y, TILE_SIZE*2) then
  --   if tank.beenHereTimer > self.framesToBeStuckInOnePlace then
  --     log('im stuck', 'warning')
  --     self:requestPath(tank, tank.targetMoveTo.x, tank.targetMoveTo.y)
  --     tank.beenHereTimer = 0
  --   end
  -- end

  --if not self:isCloseToTarget(tank, tank.targetMoveTo.x, tank.targetMoveTo.y, TILE_SIZE*2) then
    --if tank.staySensor.result and not tank.path==nil then
    if tank.staySensor.result then
      log('im stuck', 'warning')
      self:requestPath(tank, tank.targetMoveTo.x, tank.targetMoveTo.y)
    end
  --end
end
