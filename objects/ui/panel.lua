Panel = Object:extend()

function Panel:new(active)
  self.active = active or false
  self.elements = {}
end

function Panel:addElement(element, pos)
  if pos == nil then
    table.insert(self.elements, element)
  else
    self.elements[pos] = element
  end
end

function Panel:getElement(elementName)
  return self.elements[elementName]
end

function Panel:setActive(value)
  self.active = value
end

function Panel:update()
  if self.active then
    for _, element in pairs(self.elements) do
      if element.update then
        element:update()
      end
    end
  end
end

function Panel:draw()
  if self.active then
    for _, element in pairs(self.elements) do
      element:draw()
    end
  end
end
