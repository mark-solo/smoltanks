MenuScene = Scene:extend()

function MenuScene:new()
  self.ui = {}
  -----
  self.ui.main_panel = Panel(true)
  self.ui.main_panel:addElement(Button(100, 100,
                                      function() gameScene:newGame(self.gameParameters) end,
                                      "play"))
  self.ui.main_panel:addElement(Button(100, 120,
                                      function()
                                        self.ui.main_panel:setActive(false)
                                        self.ui.controls_panel:setActive(true)
                                      end,
                                      "settings"))
  -----
  self.ui.controls_panel = Panel()

  self.ui.controls_panel:addElement(Button(300, 100,
                                          function()
                                            local index = find(inputConfigs, input)
                                            index = (index-2) % #inputConfigs + 1
                                            input = inputConfigs[index]
                                            self.ui.controls_panel:getElement('controlsLabel').text = input.name
                                          end,
                                          "<",
                                          20, 20))
  self.ui.controls_panel:addElement(Label(330, 100,
                                          input.name,
                                          50, 20), 'controlsLabel')
  self.ui.controls_panel:addElement(Button(390, 100,
                                          function()
                                            local index = find(inputConfigs, input)
                                            index = index % #inputConfigs + 1
                                            input = inputConfigs[index]
                                            self.ui.controls_panel:getElement('controlsLabel').text = input.name
                                          end,
                                          ">",
                                          20, 20))
  self.ui.controls_panel:addElement(Button(330, 130,
                                          function()
                                            self.ui.main_panel:setActive(true)
                                            self.ui.controls_panel:setActive(false)
                                          end,
                                          "back",
                                          50, 20))

  --------------------

  self.gameParameters = {
    map = 'level01',
    playerOnTeam = 'red'
  }
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
  if DEBUG then
    draw_log(0, 0)
  end

  for _, button in pairs(self.ui) do
    button:draw()
  end
end
