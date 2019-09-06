Tank = Entity:extend()

function Tank:new(level, x, y, controller, type)
  Tank.super.new(self, level, x, y, 0, TILE_SIZE*0.7, TILE_SIZE*0.4)
  self.level = level
  self.controller = controller
  self.type = type or nil

  self.da = 0
  self.turnSpeed = 10000*TILE_SIZE
  self.ds = 0
  self.moveSpeed = 2000*TILE_SIZE
  self.dangle = math.pi/30

  self.fireRate = 0.5
  self.fireTimer = 0

  self.gun_angle = 0
  self.collider = level.world:newRectangleCollider(self.x, self.y, self.w, self.h)
  self.collider:setCollisionClass('Tank')
  self.collider:setObject(self)
  self.collider:setLinearDamping(5)
  self.collider:setAngularDamping(5)
end

function Tank:turn(da)
  self.da = da<1 and da or 1
end

function Tank:move(ds)
  self.ds = ds<1 and ds or 1
end

function Tank:setTurretTo(angle)
  local abs = math.abs(angle-self.gun_angle)
  local sign = (angle-self.gun_angle)/abs


  if abs > math.pi then
    --log('-----')
    angle = angle - sign*2*math.pi
    abs = math.abs(angle-self.gun_angle)
  end

  if self.gun_angle > math.pi*2 and angle > math.pi*2 then
    self.gun_angle = self.gun_angle - math.pi*2
    angle = angle - math.pi*2
  end
  if self.gun_angle < -math.pi*2 and angle < -math.pi*2 then
    self.gun_angle = self.gun_angle + math.pi*2
    angle = angle + math.pi*2
  end

  --log(angle..' '..self.gun_angle..' '..abs)

  local is = abs < self.dangle
  if is then
    self.gun_angle = angle
  else
    local sign = (angle-self.gun_angle)/abs
    self.gun_angle = self.gun_angle + sign*self.dangle
  end
  --local b = a<1 and angle or self.gun_angle+self.dangle
  --self.gun_angle = b
end

function Tank:shoot(targetX, targetY)
  if self.fireTimer > self.fireRate then
    local bullet = level:getBullet()

    local dx, dy = angleToDir(self.gun_angle)
    local d = self.w+bullet.w+10
    bullet:launch(d*dx+self.x, d*dy+self.y, self.gun_angle)

    local knockback = 500
    self.collider:applyLinearImpulse(-knockback*dx, -knockback*dy)

    self.fireTimer = 0
  end
end

function Tank:input()
  self.controller:input(self)
end

function Tank:movement(dt)
  local dx, dy = angleToDir(self.angle)
  local dirX = self.ds*dx*self.moveSpeed*dt
  local dirY = self.ds*dy*self.moveSpeed*dt

  self.collider:applyForce(dirX, dirY)

  self.x, self.y = self.collider:getPosition()
end

function Tank:rotation(dt)
  local dirAngle = self.da*self.turnSpeed*dt

  self.collider:applyTorque(dirAngle)

  self.angle = self.collider:getAngle()
end

function Tank:update(dt)
  self:rotation(dt)
  self:movement(dt)

  self.fireTimer = self.fireTimer + dt
end

function Tank:draw()
  love.graphics.push()
  love.graphics.translate(self.x, self.y)
  love.graphics.rotate(self.angle)

  love.graphics.setColor(1, 1, 1)
  love.graphics.line(0, 0, self.w/2, 0)
  love.graphics.line(0, 0, self.w/2, self.h/2)
  love.graphics.line(0, 0, self.w/2, -self.h/2)
  love.graphics.rectangle('line', -self.w/2, -self.h/2, self.w, self.h)

  love.graphics.pop()


  love.graphics.push()
  love.graphics.translate(self.x, self.y)

  local mouseX, mouseY = love.mouse.getPosition()
  love.graphics.rotate(self.gun_angle)

  love.graphics.setColor(1, 1, 1)
  love.graphics.circle('line', 0, 0, self.h/2, 5)

  love.graphics.line(0, 0, self.h*1.2, 0)
  love.graphics.line(0, 0, self.h/2*math.cos(-math.pi/2.5), self.h/2*math.sin(-math.pi/2.5))
  love.graphics.line(0, 0, self.h/2*math.cos( math.pi/2.5), self.h/2*math.sin( math.pi/2.5))

  love.graphics.pop()
end
