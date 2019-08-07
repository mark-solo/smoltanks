Player = Object:extend()

function Player:new(x, y, w, h)
  self.x = x or love.graphics.getWidth()/2
  self.y = y or love.graphics.getHeight()/2
  self.w = w or 50
  self.h = h or 100
  self.angle = 0

  self.da = 0
  self.turnSpeed = 10
  self.ds = 0
  self.moveSpeed = 100
end

function Player:turn(da)
  self.da = da
end

function Player:move(ds)
  self.ds = ds
end

function Player:update(dt)
  self.angle = self.angle + self.da*self.turnSpeed*dt

  local dx = math.cos(self.angle)
  local dy = math.sin(self.angle)
  self.x = self.x + self.ds*dx*self.moveSpeed*dt
  self.y = self.y + self.ds*dy*self.moveSpeed*dt

  self.da = 0
  self.ds = 0
end

function Player:draw()
  love.graphics.push()

  love.graphics.translate(self.x, self.y)
  love.graphics.rotate(self.angle-math.pi/2)

  love.graphics.setColor(1, 1, 1)
  love.graphics.line(0, 0, 0, self.h/2)
  love.graphics.rectangle('line', -self.w/2, -self.h/2, self.w, self.h)

  love.graphics.pop()
end
