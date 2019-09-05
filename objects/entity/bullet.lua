Bullet = Entity:extend()

function Bullet:new(level)
  Bullet.super.new(self, level, x, y, angle, TILE_SIZE*0.2, TILE_SIZE*0.1)
  self.tag = tag or nil

  self.bumpForce = 500

  self.collider = level.world:newRectangleCollider(self.x, self.y, self.w, self.h)
  self.collider:setAngle(self.angle)
  self.collider:setCollisionClass('Bullet')
  self.collider:setCategory(1, 2)
  self.collider:setMask(2)
  self.collider:setObject(self)
  --self.collider:setBullet(true)
  self.collider:setActive(false)
  --self.collider:setSensor(true)
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
  --self.collider:applyLinearImpulse(dx*self.bumpForce, dy*self.bumpForce)
end

function Bullet:update(dt)
  --self.angle = self.collider:getAngle()
  self.x, self.y = self.collider:getPosition()
  local dx = math.cos(self.angle)
  local dy = math.sin(self.angle)
  --self.collider:applyForce(dx*self.bumpForce, dy*self.bumpForce)
  self.collider:setLinearVelocity(dx*self.bumpForce, dy*self.bumpForce)

  if self.collider:enter('Player') or self.collider:exit('Player') then
    local collision_data = self.collider:getEnterCollisionData('Player')
    local player = collision_data.collider:getObject()

    self.collider:setActive(false)
  end

  if self.collider:enter('Wall') or self.collider:exit('Wall') then -- did i hit anything?
    self.collider:setActive(false)
  end

  --if #self.collider:getContacts()>0 then
  --  self.collider:setActive(false)
  --end
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
