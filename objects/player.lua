Player = Object:extend()

function Player:new(x, y, w, h)
  self.x = x or love.graphics.getWidth()/2
  self.y = y or love.graphics.getHeight()/2
  self.w = w or 90
  self.h = h or 50
  self.angle = 0

  self.da = 0
  self.turnSpeed = 10000000
  self.ds = 0
  self.moveSpeed = 1000000

  self.collider = world:newRectangleCollider(self.x, self.y, self.w, self.h)
  self.collider:setObject(self)
  local _, _, mass, _ = self.collider:computeMass(1)
  --self.collider:setMass(mass)
  self.collider:setLinearDamping(5)
  self.collider:setAngularDamping(5)
end

function Player:turn(da)
  self.da = da
end

function Player:move(ds)
  self.ds = ds
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
end

function Player:draw()
  love.graphics.push()
  love.graphics.translate(self.x, self.y)
  love.graphics.rotate(self.angle)

  love.graphics.setColor(1, 1, 1)
  love.graphics.line(0, 0, 0, self.h/2)
  love.graphics.rectangle('line', -self.w/2, -self.h/2, self.w, self.h)

  love.graphics.pop()

  --

  love.graphics.push()
  love.graphics.translate(self.x, self.y)

  local mouseX, mouseY = love.mouse.getPosition()
  local gun_angle = math.atan2(mouseY-self.y, mouseX-self.x)
  love.graphics.line(0, 0, 75*math.cos(gun_angle), 75*math.sin(gun_angle))
  love.graphics.line(0, 0, 25*math.cos(gun_angle-math.pi/2.5), 25*math.sin(gun_angle-math.pi/2.5))
  love.graphics.line(0, 0, 25*math.cos(gun_angle+math.pi/2.5), 25*math.sin(gun_angle+math.pi/2.5))

  love.graphics.rotate(gun_angle)
  love.graphics.circle('line', 0, 0, 25, 5)

  love.graphics.pop()
end
