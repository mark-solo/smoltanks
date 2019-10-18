GameScene = Scene:extend() -- controls game logic

function GameScene:new()
  self.timer = 0
  self.state = self.game

  self.entities = {}

  self:loadMap('level01')

  self:initEntities()

  log('entities: '..inspect(self.entities, {depth=1}))
end

-- function states

function GameScene:init(dt)

end

function GameScene:reset(dt)

end

function GameScene:game(dt)
  self:spawnTanksIfNeeded()
  Pathfinding.update(dt)
  self.map:update(dt)

  for _, entity in pairs(self.entities) do
    entity:update(dt)
  end

  camera:setPos(self:getEntity('player').x, self:getEntity('player').y)
end

function GameScene:final(dt)

end

function GameScene:test(dt)
  if self.timer > 1 then
    log("hello test "..self.timer, "error")
    self.timer = 0
  end
end

--

function GameScene:initEntities()
  self.bullets = {}
  for i=1,20 do
    local bullet = Bullet(self)
    table.insert(self.bullets, bullet)
    table.insert(self.entities, bullet)
  end

  self.tanks = {}
  local playerController = PlayerController()
  local playerTank = Tank(self, playerController)
  self.entities['player'] = playerTank
  table.insert(self.tanks, playerTank)

  local aiController = AIController()
  for i=1,2 do
    local aiTank = Tank(self, aiController)
    table.insert(self.entities, aiTank)
    table.insert(self.tanks, aiTank)
  end

  --self:spawnTanksIfNeeded()
end

function GameScene:onEnter()
  log("gameScene loaded")
end

function GameScene:loadMap(mapName)
  maps[mapName]:insert(self)
end

function GameScene:reset()
  if self.map==nil then
    log('don\'t have map to make things happen')
    return nil
  end
end

function GameScene:spawnTanksIfNeeded()
  for _, tank in ipairs(self.tanks) do
    if not tank.collider:isActive() and self:getFreeSpawnPoint()~=nil then
      local spawnPoint = nil

      -- TODO: make fix for when all spawnPoints are busy
      while spawnPoint==nil or spawnPoint:isBusy() do
        local num = math.random(#self.map.spawnPoints)
        spawnPoint = self.map.spawnPoints[num]
        log(((spawnPoint==nil or spawnPoint:isBusy()) and "|" or "O").." "..num)
      end

      spawnPoint.tank = tank
      --tank:spawn(spawnPoint.x+TILE_SIZE/2, spawnPoint.y+TILE_SIZE/2)
    end
  end
end

function GameScene:getEntity(entityName)
  return self.entities[entityName]
end

function GameScene:input()
  --level:input()

  for _, entity in pairs(self.entities) do
    if entity.input then
      entity:input()
    end
  end
end

function GameScene:update(dt)
  local next_state = self:state(dt)

  if next_state then self.state = next_state end
  if self.state == self.game then log("huh") end

  self.timer = self.timer + dt
end

function GameScene:render()
  --level:draw()
  camera:apply()
  self.map:draw()

  for _, entity in pairs(self.entities) do
    entity:draw()
  end

  if (DEBUG) then
    local cx, cy = worldToPoint(cameraToWorld(love.mouse.getPosition()))
    love.graphics.setColor(1, 1, 0)
    love.graphics.print(cx..' '..cy..' '..self.map:pointToNum(cx, cy)..' '..self.map:pointToIndex(cx, cy), cx*TILE_SIZE, cy*TILE_SIZE)
  end
end

--

function GameScene:getBullet()
  local bullet = table.remove(self.bullets, 1)
  table.insert(self.bullets, bullet)
  return bullet
end

function GameScene:getFreeSpawnPoint()
  for _, spawnPoint in ipairs(self.map.spawnPoints) do
    if not spawnPoint:isBusy() then
      return spawnPoint
    end
  end

  return nil
end
