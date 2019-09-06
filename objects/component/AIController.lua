AIController = Object:extend()

function AIController:new()
  self.targetX = TILE_SIZE*5
  self.targetY = TILE_SIZE*5
end

function AIController:input(tank)
  -- check sensors
  -- decide what to do
  -- send command for action
  tank:turn(20)
  --tank.gun_angle = tank.gun_angle + 0.05
  --tank:shoot()
end

-- sensors

function AIController:isCloseToTarget(tank, targetX, targetY, distance)
  local distance = distance or TILE_SIZE
  local real_distance = math.sqrt(math.pow(tank.x-targetX, 2), math.pow(tank.y-targetY, 2))
  return real_distance < distance
end
