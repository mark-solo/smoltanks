Player = Object:extend()

function Player:new(level, x, y, w, h)
  self.x = x or love.graphics.getWidth()/2
  self.y = y or love.graphics.getHeight()/2
  self.w = w or TILE_SIZE*0.7
  self.h = h or TILE_SIZE*0.4
  self.angle = 0

  self.da = 0
  self.turnSpeed = 10000*TILE_SIZE
  self.ds = 0
  self.moveSpeed = 2000*TILE_SIZE

  self.fireRate = 0.5
  self.fireTimer = 0

  self.collider = level.world:newRectangleCollider(self.x, self.y, self.w, self.h)
  self.collider:setCollisionClass('Player')
  self.collider:setObject(self)
  self.collider:setLinearDamping(5)
  self.collider:setAngularDamping(5)
end

function Player:turn(da)
  self.da = da
end

function Player:move(ds)
  self.ds = ds
end

function Player:shoot()
  if self.fireTimer > self.fireRate then
    local bullet = level:getBullet()

    local mouseX, mouseY = love.mouse.getPosition()
    local gun_angle = math.atan2(mouseY-self.y+camera.y-love.graphics.getHeight()/2, mouseX-self.x+camera.x-love.graphics.getWidth()/2)

    local dx = math.cos(gun_angle)
    local dy = math.sin(gun_angle)
    local d = self.w+bullet.w+10
    bullet:launch(d*dx+self.x, d*dy+self.y, gun_angle)

    local knockback = 500
    self.collider:applyLinearImpulse(-knockback*dx, -knockback*dy)

    self.fireTimer = 0
  end
end

function Player:input()
  local ds = 0
  local da = 0

  if input:down('forward') then ds = ds + 1 end
  if input:down('back') then ds = ds - 1 end
  if input:down('right') then da = da + 1 end
  if input:down('left') then da = da - 1 end

  self:move(ds)
  self:turn(da)

  if input:pressed('dup') then camera.scale = camera.scale*0.5 end
	if input:pressed('ddown') then camera.scale = camera.scale*2 end

  if love.mouse.isDown(1) then
    self:shoot()
  end
end

function Player:movement(dt)
  local dx = math.cos(self.angle)
  local dy = math.sin(self.angle)
  local dirX = self.ds*dx*self.moveSpeed*dt
  local dirY = self.ds*dy*self.moveSpeed*dt

  self.collider:applyForce(dirX, dirY)

  self.x, self.y = self.collider:getPosition()
end

function Player:rotation(dt)
  local dirAngle = self.da*self.turnSpeed*dt

  self.collider:applyTorque(dirAngle)

  self.angle = self.collider:getAngle()
end

function Player:update(dt)
  self:rotation(dt)
  self:movement(dt)

  self.fireTimer = self.fireTimer + dt
end

function Player:draw()
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
  local gun_angle = math.atan2(mouseY-self.y+camera.y-love.graphics.getHeight()/2, mouseX-self.x+camera.x-love.graphics.getWidth()/2)
  love.graphics.rotate(gun_angle)

  love.graphics.setColor(1, 1, 1)
  love.graphics.circle('line', 0, 0, self.h/2, 5)

  love.graphics.line(0, 0, self.h*1.2, 0)
  love.graphics.line(0, 0, self.h/2*math.cos(-math.pi/2.5), self.h/2*math.sin(-math.pi/2.5))
  love.graphics.line(0, 0, self.h/2*math.cos( math.pi/2.5), self.h/2*math.sin( math.pi/2.5))

  love.graphics.pop()
end
