Level = Object:extend() -- store and init entities

function Level:new(map, sizeX, sizeY)
  self.world = wf.newWorld(0, 0, true)
  self.world:addCollisionClass('Tank')
  self.world:addCollisionClass('Bullet', {ignores = {'Bullet'}})
  self.world:addCollisionClass('Wall')
  self.world:addCollisionClass('Spawn')

  self.entities = {}

  self.spawnPoints = {}
  self.map = Map(self, map, sizeX, sizeY)
  for _, spawnPoint in ipairs(self.spawnPoints) do table.insert(self.entities, spawnPoint) end

  self.bullets = {}
  for i=1,20 do
    local bullet = Bullet(self)
    table.insert(self.bullets, bullet)
    table.insert(self.entities, bullet)
  end

  local playerController = PlayerController()
  self.entities['player'] = Tank(self, TILE_SIZE, TILE_SIZE, playerController)
  local aiController = AIController()
  self.entities['aitank'] = Tank(self, 2*TILE_SIZE, TILE_SIZE, aiController)

  log('entities: '..inspect(self.entities, {depth=1}))
end

function Level:getEntity(entityName)
  return self.entities[entityName]
end

function Level:input()
  for _, entity in pairs(self.entities) do
    if entity.input then
      entity:input()
    end
  end
end

function Level:update(dt)
  for _, entity in pairs(self.entities) do
    entity:update(dt)
  end

  self.world:update(dt)
end

function Level:draw()
  self.map:draw()

  for _, entity in pairs(self.entities) do
    entity:draw()

    if DEBUG and entity:is(Tank) and entity.controller.draw then
      entity.controller:draw(entity)
    end
  end

  if (DEBUG) then
    self.world:draw(0.2)

    local cx, cy = worldToPoint(cameraToWorld(love.mouse.getPosition()))
    love.graphics.setColor(1, 1, 0)
    love.graphics.print(cx..' '..cy..' '..self.map:pointToNum(cx, cy)..' '..self.map:pointToIndex(cx, cy), cx*TILE_SIZE, cy*TILE_SIZE)
  end
end

-- pool functions

function Level:getBullet()
  local bullet = table.remove(self.bullets, 1)
  table.insert(self.bullets, bullet)
  return bullet
end

-- pathfinding functions

function Level:recontructPath(came_from, current)
  local total_path = {}

  local c = current
  while c~=nil do
    table.insert(total_path, 1, c)
    c = came_from[c]
  end

  return total_path
end

function Level:heuristic(current, goal)
  local cx, cy = self.map:indexToPoint(current)
  local gx, gy = self.map:indexToPoint(goal)

  local dx = cx-gx
  local dy = cy-gy

  return math.sqrt(dx*dx+dy*dy)
end

function Level:getNodeWithLowestScore(open, fScore)
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

function Level:getNeighbours(node)
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

function Level:aStar(start, goal)
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
    print(inspect(open))
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
