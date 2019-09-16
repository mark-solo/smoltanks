Bullet = Entity:extend()

function Bullet:new(level)
  Bullet.super.new(self, level, x, y, angle, TILE_SIZE*0.2, TILE_SIZE*0.1)
  self.tag = tag or nil

  self.bumpForce = 500

  self.collider = level.world:newRectangleCollider(self.x, self.y, self.w, self.h)
  self.collider:setAngle(self.angle)
  self.collider:setCollisionClass('Bullet')
<<<<<<< HEAD
  self.collider:setMass(1)
=======
  self.collider:setMass(2)
>>>>>>> 776659a1dd64e4c22359d993b90630a650532cd0
  self.collider:setObject(self)
  self.collider:setActive(false)
end

function Bullet:launch(x, y, angle)
  local dx, dy = angleToDir(angle)

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
  local dx, dy = angleToDir(self.angle)
  self.collider:setAngle(self.angle)
  self.collider:setLinearVelocity(dx*self.bumpForce, dy*self.bumpForce)

  if self.collider:enter('Tank') or self.collider:exit('Tank') then
    local collision_data = self.collider:getEnterCollisionData('Tank')
    local tank = collision_data.collider:getObject()

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
