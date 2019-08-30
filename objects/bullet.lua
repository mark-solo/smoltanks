Bullet = Object:extend()

function Bullet:new(level, x, y, angle, w, h, tag)
  self.level = level
  self.x = x or 0
  self.y = y or 0
  self.w = w or TILE_SIZE*0.2
  self.h = h or TILE_SIZE*0.1
  self.angle = angle or 0
  self.tag = tag or nil

  self.da = 0
  self.turnSpeed = 10000*TILE_SIZE
  self.ds = 0
  self.moveSpeed = 2000*TILE_SIZE

  self.collider = level.world:newRectangleCollider(self.x, self.y, self.w, self.h)
  self.collider:setObject(self)
  self.collider:setLinearDamping(5)
  self.collider:setAngularDamping(5)
end

function Bullet:launch(impulse)
  local dx = math.cos(self.angle)
  local dy = math.sin(self.angle)
  self.collider:applyLinearImpulse(dx*impulse, dy*impulse)
end

function Bullet:update(dt)
  self.angle = self.collider:getAngle()
  self.x, self.y = self.collider:getPosition()
end

function Bullet:draw()
  love.graphics.push()
  love.graphics.translate(self.x, self.y)
  love.graphics.rotate(self.angle)

  love.graphics.setColor(1, 0, 0)
  love.graphics.rectangle('fill', -self.w/2, -self.h/2, self.w, self.h)

  love.graphics.pop()
end
