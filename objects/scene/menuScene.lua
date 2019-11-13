MenuScene = Scene:extend()

function MenuScene:new()
  self.gameParameters = {
    map = 1,
    playerOnTeam = 'red'
  }

  --------------------

  self.ui = {}
  -----
  self.ui.main_panel = Panel(true)
  self.ui.main_panel:addElement(Button(TILE_SIZE/2, 5*TILE_SIZE,
                                      function() gameScene:newGame(self.gameParameters) end,
                                      "PLAY"))
  self.ui.main_panel:addElement(Button(TILE_SIZE/2, 5.5*TILE_SIZE,
                                      function()
                                        self.ui.controls_panel:toggle()
                                      end,
                                      "SETTINGS"))
  self.ui.main_panel:addElement(Button(TILE_SIZE/2, 6*TILE_SIZE,
                                      function()
                                        love.window.close()
                                      end,
                                      "EXIT"))

  self.ui.main_panel:addElement(Label(5.1*TILE_SIZE, 4.25*TILE_SIZE,
                                      maps[self.gameParameters.map].name,
                                      1.3*TILE_SIZE, 0.35*TILE_SIZE),
                                      'mapsLabel')
  self.ui.main_panel:addElement(Button(4.5*TILE_SIZE, 4.25*TILE_SIZE,
                                      function()
                                        self.gameParameters.map = (self.gameParameters.map-1-1) % #maps + 1
                                        self.ui.main_panel:getElement('mapsLabel').text = maps[self.gameParameters.map].name
                                      end,
                                      "<",
                                      TILE_SIZE/2))
  self.ui.main_panel:addElement(Button(6.5*TILE_SIZE, 4.25*TILE_SIZE,
                                      function()
                                        self.gameParameters.map = (self.gameParameters.map-1+1) % #maps + 1
                                        self.ui.main_panel:getElement('mapsLabel').text = maps[self.gameParameters.map].name
                                      end,
                                      ">",
                                      TILE_SIZE/2))
  -----
  self.ui.controls_panel = Panel()
  self.ui.controls_panel:addElement(Label(3*TILE_SIZE, 5*TILE_SIZE,
                                          input.name,
                                          1.5*TILE_SIZE, TILE_SIZE*0.85),
                                          'controlsLabel')
  self.ui.controls_panel:addElement(Button(3*TILE_SIZE, 6*TILE_SIZE,
                                          function()
                                            local index = find(inputConfigs, input)
                                            index = (index-1-1) % #inputConfigs + 1
                                            input = inputConfigs[index]
                                            self.ui.controls_panel:getElement('controlsLabel').text = input.name
                                          end,
                                          "<",
                                          TILE_SIZE/2))
  self.ui.controls_panel:addElement(Button(4*TILE_SIZE, 6*TILE_SIZE,
                                          function()
                                            local index = find(inputConfigs, input)
                                            index = (index-1+1) % #inputConfigs + 1
                                            input = inputConfigs[index]
                                            self.ui.controls_panel:getElement('controlsLabel').text = input.name
                                          end,
                                          ">",
                                          TILE_SIZE/2))
end

function MenuScene:input()
  --if input:pressed('space') then gameScene:newGame(self.gameParameters) end
end

function MenuScene:update(dt)
  for _, button in pairs(self.ui) do
    button:update()
  end
end

function MenuScene:render()
  local map = maps[self.gameParameters.map].map:drawPreview(4.5*TILE_SIZE, 1.5*TILE_SIZE,
                                          2.5*TILE_SIZE, 2.5*TILE_SIZE)

  if DEBUG then
    draw_log(0, 0)
  end

  for _, button in pairs(self.ui) do
    button:draw()
  end
end
