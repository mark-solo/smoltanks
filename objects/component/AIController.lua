AIController = Object:extend()

function AIController:new()
  self.targetX = TILE_SIZE*8
  self.targetY = TILE_SIZE*2
end

function AIController:input(tank)
  tank:setTurretTo(dirToAngle(self.targetX-tank.x, self.targetY-tank.y))
  tank:turn(dirToAngle(self.targetX-tank.x, self.targetY-tank.y)-tank.angle)

  if not self:isCloseToTarget(tank) then
    tank:move(1)
  end
end

-- sensors

function AIController:isCloseToTarget(tank, distance)
  local distance = distance or TILE_SIZE
  local real_distance = math.sqrt(math.pow(tank.x-self.targetX, 2), math.pow(tank.y-self.targetY, 2))
  return real_distance < distance
end
