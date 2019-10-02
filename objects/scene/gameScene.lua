GameScene = Scene:extend() -- controls game logic

function GameScene:new()
  --level = levels[levelName]

  self.entities = {}

  self.spawnPoints = {}
  -- TODO: write functions for plugging in and out maps
  --self.map = Map(self, map, sizeX, sizeY)
  self:loadMap('level01')
  --for _, spawnPoint in ipairs(self.spawnPoints) do table.insert(self.entities, spawnPoint) end

  self:initEntities()

  log('entities: '..inspect(self.entities, {depth=1}))
end

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
  for i=1,5 do
    local aiTank = Tank(self, aiController)
    --self.entities['aitank'] = aiTank
    table.insert(self.entities, aiTank)
    table.insert(self.tanks, aiTank)
  end


  for _, tank in ipairs(self.tanks) do
    if (self:getFreeSpawnPoint()~=nil) then
      local spawnPoint = nil

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

-- new
-- insertMap
-- resetGame

function GameScene:loadMap(mapName)
  self.map = maps[mapName]:insert(self)
end

function GameScene:reset()
  if self.map==nil then
    log('don\'t have map to make things happen')
    return nil
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
  --level:update(dt)
  self.map:update(dt)

  for _, entity in pairs(self.entities) do
    entity:update(dt)
  end

  camera:setPos(self:getEntity('player').x, self:getEntity('player').y)
end

function GameScene:render()
  --level:draw()

  self.map:draw()

  for _, entity in pairs(self.entities) do
    entity:draw()

    if DEBUG and entity:is(Tank) and entity.controller.draw then
      entity.controller:draw(entity)
    end
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

--

function GameScene:recontructPath(came_from, current)
  local total_path = {}

  local c = current
  while c~=nil do
    table.insert(total_path, 1, c)
    c = came_from[c]
  end

  return total_path
end

function GameScene:heuristic(current, goal)
  local cx, cy = self.map:indexToPoint(current)
  local gx, gy = self.map:indexToPoint(goal)

  local dx = cx-gx
  local dy = cy-gy

  return math.sqrt(dx*dx+dy*dy)
end

function GameScene:getNodeWithLowestScore(open, fScore)
  local minIndex = -1
  local min = 99999

  for i=1,#open do
    if min >= (fScore[open[i]] or 9999) then
      minIndex = i
      min = fScore[open[i]]
    end
  end

  return open[minIndex]
end

function GameScene:getNeighbours(node)
  local neighbours = {}
  local x, y = self.map:indexToPoint(node)

  for i=-1,1,2 do
    if self.map:pointToNum(x+i, y)==0 then
      table.insert(neighbours, self.map:pointToIndex(x+i, y))
    end
    if self.map:pointToNum(x, y+i)==0 then
      table.insert(neighbours, self.map:pointToIndex(x, y+i))
    end
  end

  return neighbours
end

function GameScene:aStar(start, goal)
  -- TODO: check start and goal for walkability and move if needed

  local open = {}
  table.insert(open, start)
  local closed = {}

  local came_from = {}

  -- for node stores cost of shortest path to this node from start
  local gScore = {} -- default to infinity, please
  gScore[start] = 0

  -- f(n) = g(n) + h(n)
  local fScore = {} -- default to infinity, please
  fScore[start] = self:heuristic(start, goal)

  while #open>0 do
    local current = self:getNodeWithLowestScore(open, fScore)
    if current == goal then
      return self:recontructPath(came_from, current)
    end

    table.remove(open, find(open, current))
    table.insert(closed, current)
    local neighbours = self:getNeighbours(current)
    for _, neighbour in ipairs(neighbours) do
      if find(closed, neighbour)==nil then
        local t_gScore = (gScore[current] or 99998) + self:heuristic(current, neighbour)

        if t_gScore < (gScore[neighbour] or 99999) then
          came_from[neighbour] = current
          gScore[neighbour] = t_gScore
          fScore[neighbour] = gScore[neighbour] + self:heuristic(neighbour, goal)
          if find(open, neighbour)==nil then
            table.insert(open, neighbour)
          end
        end
      end
    end
  end

  return nil
end
