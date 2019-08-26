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

end

function Bullet:draw()

end
