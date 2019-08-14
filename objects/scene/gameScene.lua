GameScene = Scene:extend()

local player

function GameScene:new()
  box = world:newRectangleCollider(love.graphics.getWidth()/2-50, love.graphics.getHeight()/2-20, 100, 40)
  box:applyAngularImpulse(5000)
  box:setMass(100)
  box:setLinearDamping(5)
  box:setAngularDamping(5)
  --box:setType('static')

  player = Player(100, 100)
end

function GameScene:input()
  local ds = 0
  local da = 0

  if input:down('forward') then ds = ds + 1 end
  if input:down('back') then ds = ds - 1 end
  if input:down('right') then da = da + 1 end
  if input:down('left') then da = da - 1 end

  player:move(ds)
  player:turn(da)
end

function GameScene:update(dt)
  player:update(dt)
end

function GameScene:render()
  world:draw(128)

  player:draw()
end
