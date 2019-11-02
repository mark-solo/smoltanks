MenuScene = Scene:extend()

function MenuScene:new()
  self.ui = {}
  self.ui.main_panel = Panel(true)
  self.ui.main_panel:addButton(Button(100, 100,
                                      function() Scene.setScene(gameScene) end,
                                      "play"))
  self.ui.main_panel:addButton(Button(100, 120,
                                      function()
                                        self.ui.main_panel:setActive(false)
                                        self.ui.options_panel:setActive(true)
                                      end,
                                      "settings"))

  self.ui.options_panel = Panel(false)
  self.ui.options_panel:addButton(Button(200, 120,
                                      function()
                                        self.ui.main_panel:setActive(true)
                                        self.ui.options_panel:setActive(false)
                                      end,
                                      "back"))
end

function MenuScene:input()
  if input:pressed('space') then Scene.setScene(gameScene) end
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
