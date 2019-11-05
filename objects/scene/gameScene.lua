GameScene = Scene:extend() -- controls game logic

function GameScene:new()
  self.timer = 0
  self.state = self.init

  self.entities = {}
  self.redTeam = {}
  self.blueTeam = {}

  self:initEntities()

  log('entities: '..inspect(self.entities, {depth=1}))
  self.gameParameters = {
    map = 'level01',
    playerOnTeam = 'blue'
  }
end

--------------------

function GameScene:newGame(gameParameters)
  Scene.setScene(gameScene)
  self.gameParameters = gameParameters
  self.state = self.init
end

--------------------

function GameScene:init(dt)
  self:loadMap(self.gameParameters.map)
  self.redTeam = {}
  self.blueTeam = {}

  if self.gameParameters.playerOnTeam == 'red' then
    table.insert(self.redTeam, self.entities['player'])
  elseif self.gameParameters.playerOnTeam == 'blue' then
    table.insert(self.blueTeam, self.entities['player'])
  end

  local c = 1
  for i=#self.redTeam, #self.map.redSpawns-1 do
    table.insert(self.redTeam, self.tanks[c])
    c = c + 1
  end

  for i=#self.blueTeam, #self.map.blueSpawns-1 do
    table.insert(self.blueTeam, self.tanks[c])
    c = c + 1
  end

  return self.game
end

function GameScene:reset(dt)
  return self.test
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

function GameScene:winOrLose(dt)

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
  camera:apply()
  if self.map then self.map:draw() end

  love.graphics.setLineWidth(5)
  love.graphics.setColor(1, 0, 0)
  for _, tank in ipairs(self.redTeam) do love.graphics.circle("line", tank.x, tank.y, TILE_SIZE/4, 6) end
  love.graphics.setColor(0, 0, 1)
  for _, tank in ipairs(self.blueTeam) do love.graphics.circle("line", tank.x, tank.y, TILE_SIZE/4, 6) end
  love.graphics.setLineWidth(1)

  for _, entity in pairs(self.entities) do
    entity:draw()
  end

  if DEBUG then
    draw_log(cameraToWorld(0, 0))

    if self.map then
      local cx, cy = worldToPoint(cameraToWorld(love.mouse.getPosition()))
      love.graphics.setColor(1, 1, 0)
      love.graphics.print(cx..' '..cy..' '..self.map:pointToNum(cx, cy)..' '..self.map:pointToIndex(cx, cy), cx*TILE_SIZE, cy*TILE_SIZE)
    end
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
  for i=1,20 do
    local aiTank = Tank(self, aiController)
    table.insert(self.entities, aiTank)
    table.insert(self.tanks, aiTank)
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
