Tank = Entity:extend()

function Tank:new(level, x, y, controller, type)
  Tank.super.new(self, level, x, y, 0, TILE_SIZE*0.55, TILE_SIZE*0.3)
  self.level = level
  self.controller = controller
  self.type = type or nil

  self.da = 0
  self.turnSpeed = 5000*TILE_SIZE
  self.ds = 0
  self.moveSpeed = 1000*TILE_SIZE
  self.gunAngle = 0
  self.turretTurnSpeed = math.pi/30

  self.fireRate = 0.5
  self.fireTimer = 0
  self.knockback = 250

  self.collider = level.world:newRectangleCollider(self.x, self.y, self.w, self.h)
  self.collider:setCollisionClass('Tank')
  self.collider:setObject(self)
  self.collider:setLinearDamping(5)
  self.collider:setAngularDamping(5)
  self.collider:setActive(false)
end

function Tank:spawn(x, y)
  self.collider:setActive(true)
  self.collider:setPosition(x, y)
  self.x, self.y = x, y
  self.collider:setAngle(0)
  self.angle = 0
  self.fireTimer = 0
end

function Tank:turn(da)
  if da > math.pi then
    da = da - math.pi*2
  end
  if da < -math.pi then
    da = da + math.pi*2
  end

  self.da = da<1 and da or 1
end

function Tank:move(ds)
  self.ds = ds<1 and ds or 1
end

function Tank:setTurretTo(angle)
  local abs = math.abs(angle-self.gunAngle)
  local sign = (angle-self.gunAngle)/abs


  if abs > math.pi then
    --log('-----')
    angle = angle - sign*2*math.pi
    abs = math.abs(angle-self.gunAngle)
  end

  if self.gunAngle > math.pi*2 and angle > math.pi*2 then
    self.gunAngle = self.gunAngle - math.pi*2
    angle = angle - math.pi*2
  end
  if self.gunAngle < -math.pi*2 and angle < -math.pi*2 then
    self.gunAngle = self.gunAngle + math.pi*2
    angle = angle + math.pi*2
  end

  --log(angle..' '..self.gunAngle..' '..abs)

  local is = abs < self.turretTurnSpeed
  if is then
    self.gunAngle = angle
  else
    local sign = (angle-self.gunAngle)/abs
    self.gunAngle = self.gunAngle + sign*self.turretTurnSpeed
  end
  --local b = a<1 and angle or self.gunAngle+self.turretTurnSpeed
  --self.gunAngle = b
end

function Tank:shoot(targetX, targetY)
  if self.collider:isActive() and self.fireTimer > self.fireRate then
    local bullet = level:getBullet()

    local dx, dy = angleToDir(self.gunAngle)
    local d = self.w
    bullet:launch(d*dx+self.x, d*dy+self.y, self.gunAngle)

    self.collider:applyLinearImpulse(-self.knockback*dx, -self.knockback*dy)

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
  self.ds = 0
end

function Tank:rotation(dt)
  local dirAngle = self.da*self.turnSpeed*dt

  self.collider:applyTorque(dirAngle)

  self.angle = self.collider:getAngle()
  if self.angle > math.pi*2 then self.angle = self.angle - math.pi*2 end
  if self.angle < -math.pi*2 then self.angle = self.angle + math.pi*2 end
  self.collider:setAngle(self.angle)

  self.da = 0
end

function Tank:update(dt)
  self:rotation(dt)
  self:movement(dt)

  self.fireTimer = self.fireTimer + dt
end

function Tank:draw()
  if (self.collider:isActive()) then
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
    love.graphics.rotate(self.gunAngle)

    love.graphics.setColor(1, 1, 1)
    love.graphics.circle('line', 0, 0, self.h/2, 5)

    love.graphics.line(0, 0, self.h*1.2, 0)
    love.graphics.line(0, 0, self.h/2*math.cos(-math.pi/2.5), self.h/2*math.sin(-math.pi/2.5))
    love.graphics.line(0, 0, self.h/2*math.cos( math.pi/2.5), self.h/2*math.sin( math.pi/2.5))

    love.graphics.pop()
  end
end
