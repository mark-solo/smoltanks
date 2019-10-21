GameScene = Scene:extend() -- controls game logic

function GameScene:new()
  self.timer = 0
  self.state = self.init

  self.entities = {}
  self.redTeam = {}
  self.blueTeam = {}

  log('entities: '..inspect(self.entities, {depth=1}))
end

--------------------

function GameScene:init(dt)
  self:initEntities()

  return self.reset
end

function GameScene:reset(dt)
  self:loadMap('level01')

  return self.game
end

function GameScene:game(dt)
  self:spawnTanksIfNeeded(self.redTeam, self.map.redSpawns)
  self:spawnTanksIfNeeded(self.blueTeam, self.map.blueSpawns)
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

--------------------

function GameScene:input()
  for _, entity in pairs(self.entities) do
    if entity.input then
      entity:input()
    end
  end
end

function GameScene:update(dt)
  local next_state = self:state(dt)

  if next_state then
    self.state = next_state
    log('new gamestate')
  end
  --if self.state == self.game then log("huh") end

  self.timer = self.timer + dt
end

function GameScene:render()
  --level:draw()
  camera:apply()
  if self.map then self.map:draw() end

  for _, entity in pairs(self.entities) do
    entity:draw()
  end

  if self.map and DEBUG then
    local cx, cy = worldToPoint(cameraToWorld(love.mouse.getPosition()))
    love.graphics.setColor(1, 1, 0)
    love.graphics.print(cx..' '..cy..' '..self.map:pointToNum(cx, cy)..' '..self.map:pointToIndex(cx, cy), cx*TILE_SIZE, cy*TILE_SIZE)
  end
end

function GameScene:onEnter()
  log("gameScene loaded")
end

--------------------

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
  --table.insert(self.tanks, playerTank)

  local aiController = AIController()
  for i=1,10 do
    local aiTank = Tank(self, aiController)
    table.insert(self.entities, aiTank)
    table.insert(self.tanks, aiTank)
  end

  table.insert(self.redTeam, self.entities['player'])
  for i=1,2 do
    table.insert(self.redTeam, self.tanks[i])
  end

  for i=#self.redTeam+1, #self.redTeam+3 do
    table.insert(self.blueTeam, self.tanks[i])
  end
end

function GameScene:loadMap(mapName)
  maps[mapName]:insert(self)
end

function GameScene:spawnTanksIfNeeded(tanks, spawnpoints)
  for _, tank in ipairs(tanks) do
    if not tank.collider:isActive() and self.map:getSpawnpoint(spawnpoints)~=nil then
      local spawnPoint = nil

      -- TODO: make fix for when all spawnPoints are busy
      while spawnPoint==nil or spawnPoint:isBusy() do
        local num = math.random(#spawnpoints)
        spawnPoint = spawnpoints[num]
        log(((spawnPoint==nil or spawnPoint:isBusy()) and "|" or "O").." "..num)
      end

      spawnPoint.tank = tank
      --tank:spawn(spawnPoint.x+TILE_SIZE/2, spawnPoint.y+TILE_SIZE/2)
    end
  end
end

--------------------

function GameScene:getEntity(entityName)
  return self.entities[entityName]
end

function GameScene:getBullet()
  local bullet = table.remove(self.bullets, 1)
  table.insert(self.bullets, bullet)
  return bullet
end
