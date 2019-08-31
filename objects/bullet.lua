Bullet = Object:extend()

function Bullet:new(level, x, y, angle, w, h, tag)
  self.level = level
  self.x = x or 0
  self.y = y or 0
  self.w = w or TILE_SIZE*0.2
  self.h = h or TILE_SIZE*0.1
  self.angle = angle or 0
  self.tag = tag or nil

  self.bumpForce = 20

  self.collider = level.world:newCircleCollider(self.x, self.y, self.h/2)
  self.collider:setAngle(self.angle)
  self.collider:setCollisionClass('Bullet')
  self.collider:setObject(self)
  --self.collider:setBullet(true)
  self.collider:setActive(false)
end

function Bullet:launch(x, y, angle)
  local dx = math.cos(angle)
  local dy = math.sin(angle)

  self.x = x
  self.y = y
  self.angle = angle
  self.collider:setPosition(x, y)
  self.collider:setAngle(angle)

  self.collider:setActive(true)
  self.collider:applyLinearImpulse(dx*self.bumpForce, dy*self.bumpForce)
end

function Bullet:update(dt)
  self.angle = self.collider:getAngle()
  self.x, self.y = self.collider:getPosition()

  if self.collider:enter('Player') or self.collider:exit('Player') then
    local collision_data = self.collider:getEnterCollisionData('Player')
    local player = collision_data.collider:getObject()

    self.collider:setActive(false)
  end

  if self.collider:enter('Wall') or self.collider:exit('Wall') then -- did i hit anything?
    self.collider:setActive(false)
  end
end

function Bullet:draw()
  if self.collider:isActive() then
    love.graphics.push()
    love.graphics.translate(self.x, self.y)
    love.graphics.rotate(self.angle)

    love.graphics.setColor(1, 0, 0)
    love.graphics.rectangle('fill', -self.w/2, -self.h/2, self.w, self.h)

    love.graphics.pop()
  end
end
